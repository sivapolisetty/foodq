-- Migration: Create Notifications Table
-- Description: Store all notifications with delivery tracking
-- Version: 1.0
-- Date: 2025-09-23

-- Create notifications table
CREATE TABLE IF NOT EXISTS public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Link to event
  event_id UUID REFERENCES public.event_queue(id) ON DELETE SET NULL,
  event_type VARCHAR(100) NOT NULL,
  
  -- Recipient information
  recipient_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  recipient_type VARCHAR(20) NOT NULL CHECK (recipient_type IN ('customer', 'business', 'staff')),
  
  -- Message content
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  image_url TEXT,
  action_url TEXT,
  
  -- FCM specific fields
  fcm_message_id TEXT,
  fcm_response JSONB,
  
  -- Delivery channels and status
  channels TEXT[] DEFAULT ARRAY['in_app'],
  delivery_status JSONB DEFAULT '{}', -- Track status per channel: {"fcm": "sent", "in_app": "delivered"}
  
  -- Location context for location-based notifications
  location_context JSONB, -- Contains distance, business location, user location type, etc.
  
  -- Priority and tracking
  priority VARCHAR(10) DEFAULT 'normal' CHECK (priority IN ('low', 'normal', 'high', 'urgent')),
  is_read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE,
  clicked_at TIMESTAMP WITH TIME ZONE,
  
  -- Expiry
  expires_at TIMESTAMP WITH TIME ZONE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  sent_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_notifications_recipient 
ON public.notifications(recipient_id, is_read, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_event 
ON public.notifications(event_id) WHERE event_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_notifications_type 
ON public.notifications(event_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_fcm 
ON public.notifications(fcm_message_id) WHERE fcm_message_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_notifications_unread 
ON public.notifications(recipient_id, created_at DESC) WHERE is_read = false;

CREATE INDEX IF NOT EXISTS idx_notifications_priority 
ON public.notifications(priority, created_at DESC) WHERE priority IN ('high', 'urgent');

CREATE INDEX IF NOT EXISTS idx_notifications_expires 
ON public.notifications(expires_at) WHERE expires_at IS NOT NULL;

-- Enable RLS
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only see their own notifications
CREATE POLICY "Users can view own notifications" ON public.notifications
FOR SELECT USING (auth.uid() = recipient_id);

-- Users can update their own notifications (mark as read, etc.)
CREATE POLICY "Users can update own notifications" ON public.notifications
FOR UPDATE USING (auth.uid() = recipient_id);

-- Service role can manage all notifications
CREATE POLICY "Service role can manage all notifications" ON public.notifications
FOR ALL USING (auth.role() = 'service_role');

-- Grant permissions
GRANT SELECT, UPDATE ON public.notifications TO authenticated;
GRANT ALL ON public.notifications TO service_role;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_notifications_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER notifications_updated_at
BEFORE UPDATE ON public.notifications
FOR EACH ROW
EXECUTE FUNCTION public.update_notifications_updated_at();

-- Create function to mark notification as read
CREATE OR REPLACE FUNCTION public.mark_notification_read(notification_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE public.notifications
  SET 
    is_read = true,
    read_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = notification_id 
    AND recipient_id = auth.uid()
    AND is_read = false;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to mark all notifications as read for a user
CREATE OR REPLACE FUNCTION public.mark_all_notifications_read(user_id UUID DEFAULT NULL)
RETURNS INTEGER AS $$
DECLARE
  target_user_id UUID;
  updated_count INTEGER;
BEGIN
  -- Use provided user_id or current user
  target_user_id := COALESCE(user_id, auth.uid());
  
  -- Only allow users to mark their own notifications as read
  IF target_user_id != auth.uid() AND auth.role() != 'service_role' THEN
    RAISE EXCEPTION 'Access denied';
  END IF;
  
  UPDATE public.notifications
  SET 
    is_read = true,
    read_at = CURRENT_TIMESTAMP,
    updated_at = CURRENT_TIMESTAMP
  WHERE recipient_id = target_user_id
    AND is_read = false
    AND (expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP);
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get unread notification count
CREATE OR REPLACE FUNCTION public.get_unread_notification_count(user_id UUID DEFAULT NULL)
RETURNS INTEGER AS $$
DECLARE
  target_user_id UUID;
  unread_count INTEGER;
BEGIN
  -- Use provided user_id or current user
  target_user_id := COALESCE(user_id, auth.uid());
  
  -- Only allow users to get their own count
  IF target_user_id != auth.uid() AND auth.role() != 'service_role' THEN
    RAISE EXCEPTION 'Access denied';
  END IF;
  
  SELECT COUNT(*)
  INTO unread_count
  FROM public.notifications
  WHERE recipient_id = target_user_id
    AND is_read = false
    AND (expires_at IS NULL OR expires_at > CURRENT_TIMESTAMP);
  
  RETURN unread_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to cleanup expired notifications
CREATE OR REPLACE FUNCTION public.cleanup_expired_notifications()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete expired notifications older than 30 days
  DELETE FROM public.notifications
  WHERE expires_at IS NOT NULL 
    AND expires_at < CURRENT_TIMESTAMP - INTERVAL '30 days';
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  -- Also delete old read notifications (older than 90 days)
  DELETE FROM public.notifications
  WHERE is_read = true 
    AND read_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
  
  GET DIAGNOSTICS deleted_count = deleted_count + ROW_COUNT;
  
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.mark_notification_read TO authenticated;
GRANT EXECUTE ON FUNCTION public.mark_all_notifications_read TO authenticated;
GRANT EXECUTE ON FUNCTION public.get_unread_notification_count TO authenticated;
GRANT EXECUTE ON FUNCTION public.cleanup_expired_notifications TO service_role;

-- Comments for documentation
COMMENT ON TABLE public.notifications IS 'All notifications sent to users with delivery tracking';
COMMENT ON COLUMN public.notifications.delivery_status IS 'JSON object tracking delivery status per channel';
COMMENT ON COLUMN public.notifications.location_context IS 'Location data for location-based notifications';
COMMENT ON COLUMN public.notifications.data IS 'Additional notification data for app handling';
COMMENT ON FUNCTION public.mark_notification_read IS 'Mark a specific notification as read';
COMMENT ON FUNCTION public.get_unread_notification_count IS 'Get count of unread notifications for user';