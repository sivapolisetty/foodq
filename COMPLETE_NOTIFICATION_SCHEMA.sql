-- ========================================================================
-- COMPLETE NOTIFICATION SCHEMA DEPLOYMENT
-- ========================================================================
-- This file contains all notification-related migrations combined
-- Execute this ENTIRE file in the Supabase SQL Editor
-- Project: zobhorsszzthyljriiim
-- Date: 2025-09-23
-- ========================================================================

-- Migration 1: Create Event Queue Table
-- ========================================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "http" SCHEMA extensions;

-- Create event_queue table
CREATE TABLE IF NOT EXISTS public.event_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Event identification
  event_type VARCHAR(100) NOT NULL,
  event_name VARCHAR(200) NOT NULL,
  event_version VARCHAR(10) DEFAULT '1.0',
  
  -- Event payload
  payload JSONB NOT NULL,
  metadata JSONB DEFAULT '{}',
  
  -- Processing status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'processed', 'failed', 'retry')),
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  
  -- Error tracking
  error_message TEXT,
  error_details JSONB,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  processed_at TIMESTAMP WITH TIME ZONE,
  next_retry_at TIMESTAMP WITH TIME ZONE,
  
  -- Event type constraints
  CONSTRAINT check_event_type CHECK (event_type IN (
    'ORDER_CREATED', 'ORDER_PAID', 'ORDER_CONFIRMED', 'ORDER_PREPARING', 
    'ORDER_READY', 'ORDER_COMPLETED', 'ORDER_CANCELLED',
    'DEAL_CREATED', 'DEAL_UPDATED', 'DEAL_EXPIRING', 'DEAL_EXPIRED',
    'BUSINESS_UPDATE', 'SYSTEM_ANNOUNCEMENT', 'LOCATION_BASED_DEAL'
  ))
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_event_queue_status 
ON public.event_queue(status, created_at) 
WHERE status IN ('pending', 'retry');

CREATE INDEX IF NOT EXISTS idx_event_queue_type 
ON public.event_queue(event_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_event_queue_retry 
ON public.event_queue(next_retry_at) 
WHERE status = 'retry';

CREATE INDEX IF NOT EXISTS idx_event_queue_processing 
ON public.event_queue(processed_at DESC) 
WHERE processed_at IS NOT NULL;

-- Enable RLS
ALTER TABLE public.event_queue ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Allow service role to manage all events
CREATE POLICY "Service role can manage all events" ON public.event_queue
FOR ALL USING (auth.role() = 'service_role');

-- Allow authenticated users to view their related events (we'll refine this later)
CREATE POLICY "Users can view related events" ON public.event_queue
FOR SELECT USING (auth.role() = 'authenticated');

-- Grant permissions
GRANT ALL ON public.event_queue TO service_role;
GRANT SELECT ON public.event_queue TO authenticated;

-- Comments for documentation
COMMENT ON TABLE public.event_queue IS 'Core event queue that triggers all notification processing';
COMMENT ON COLUMN public.event_queue.event_type IS 'Type of event (ORDER_CREATED, DEAL_CREATED, etc.)';
COMMENT ON COLUMN public.event_queue.payload IS 'Event data in JSON format';
COMMENT ON COLUMN public.event_queue.status IS 'Processing status: pending, processing, processed, failed, retry';
COMMENT ON COLUMN public.event_queue.retry_count IS 'Number of retry attempts made';
COMMENT ON COLUMN public.event_queue.metadata IS 'Additional event metadata and context';

-- Migration 2: Create User Locations Table
-- ========================================================================

-- Create user_locations table for location-based notifications
CREATE TABLE IF NOT EXISTS public.user_locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- User reference
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Location data
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  accuracy DECIMAL(8, 2), -- GPS accuracy in meters
  
  -- Location context
  location_type VARCHAR(20) DEFAULT 'current' CHECK (location_type IN ('current', 'home', 'work', 'saved')),
  address TEXT,
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100) DEFAULT 'US',
  
  -- Timing and tracking
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  is_active BOOLEAN DEFAULT true,
  
  -- For notification radius calculations
  last_notification_check TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  UNIQUE(user_id, location_type) -- One location per type per user
);

-- Create indexes for location queries
CREATE INDEX IF NOT EXISTS idx_user_locations_user_id 
ON public.user_locations(user_id) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_user_locations_coordinates 
ON public.user_locations(latitude, longitude) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_user_locations_current 
ON public.user_locations(user_id, updated_at DESC) 
WHERE location_type = 'current' AND is_active = true;

-- Spatial index for efficient distance queries (requires PostGIS if available)
-- CREATE INDEX IF NOT EXISTS idx_user_locations_spatial 
-- ON public.user_locations USING GIST(ST_Point(longitude, latitude)) 
-- WHERE is_active = true;

-- Enable RLS
ALTER TABLE public.user_locations ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only manage their own locations
CREATE POLICY "Users can manage own locations" ON public.user_locations
FOR ALL USING (auth.uid() = user_id);

-- Service role can manage all locations
CREATE POLICY "Service role can manage all locations" ON public.user_locations
FOR ALL USING (auth.role() = 'service_role');

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.user_locations TO authenticated;
GRANT ALL ON public.user_locations TO service_role;

-- Create function to update user location
CREATE OR REPLACE FUNCTION public.update_user_location(
  p_latitude DECIMAL(10, 8),
  p_longitude DECIMAL(11, 8),
  p_accuracy DECIMAL(8, 2) DEFAULT NULL,
  p_location_type VARCHAR(20) DEFAULT 'current',
  p_address TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  location_id UUID;
  current_user_id UUID;
BEGIN
  current_user_id := auth.uid();
  
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;
  
  -- Insert or update user location
  INSERT INTO public.user_locations (
    user_id, latitude, longitude, accuracy, location_type, address, updated_at
  ) VALUES (
    current_user_id, p_latitude, p_longitude, p_accuracy, p_location_type, p_address, CURRENT_TIMESTAMP
  )
  ON CONFLICT (user_id, location_type)
  DO UPDATE SET
    latitude = EXCLUDED.latitude,
    longitude = EXCLUDED.longitude,
    accuracy = EXCLUDED.accuracy,
    address = EXCLUDED.address,
    updated_at = CURRENT_TIMESTAMP,
    is_active = true
  RETURNING id INTO location_id;
  
  RETURN location_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.update_user_location TO authenticated;

-- Comments
COMMENT ON TABLE public.user_locations IS 'User location data for proximity-based notifications';
COMMENT ON FUNCTION public.update_user_location IS 'Updates or inserts user location data';

-- Migration 3: Create Notifications Table
-- ========================================================================

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
  additional_deleted INTEGER;
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
  
  GET DIAGNOSTICS additional_deleted = ROW_COUNT;
  
  -- Return total deleted count
  RETURN deleted_count + additional_deleted;
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

-- Migration 4: Create Push Tokens Table  
-- ========================================================================

-- Create push_tokens table for FCM device management
CREATE TABLE IF NOT EXISTS public.push_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- User reference
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Token information
  token TEXT NOT NULL,
  platform VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  device_id VARCHAR(255),
  app_version VARCHAR(50),
  
  -- Token status
  is_active BOOLEAN DEFAULT true,
  is_valid BOOLEAN DEFAULT true,
  
  -- Usage tracking
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  last_used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Error tracking
  error_count INTEGER DEFAULT 0,
  last_error_at TIMESTAMP WITH TIME ZONE,
  last_error_message TEXT,
  
  UNIQUE(user_id, token) -- Prevent duplicate tokens per user
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_push_tokens_user_id 
ON public.push_tokens(user_id) WHERE is_active = true AND is_valid = true;

CREATE INDEX IF NOT EXISTS idx_push_tokens_active 
ON public.push_tokens(is_active, is_valid, last_used_at DESC);

CREATE INDEX IF NOT EXISTS idx_push_tokens_platform 
ON public.push_tokens(platform, is_active) WHERE is_valid = true;

-- Enable RLS
ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can manage their own tokens
CREATE POLICY "Users can manage own push tokens" ON public.push_tokens
FOR ALL USING (auth.uid() = user_id);

-- Service role can manage all tokens
CREATE POLICY "Service role can manage all push tokens" ON public.push_tokens
FOR ALL USING (auth.role() = 'service_role');

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON public.push_tokens TO authenticated;
GRANT ALL ON public.push_tokens TO service_role;

-- Create function to register push token
CREATE OR REPLACE FUNCTION public.register_push_token(
  p_token TEXT,
  p_platform VARCHAR(20),
  p_device_id VARCHAR(255) DEFAULT NULL,
  p_app_version VARCHAR(50) DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  token_id UUID;
  current_user_id UUID;
BEGIN
  current_user_id := auth.uid();
  
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'User not authenticated';
  END IF;
  
  -- Insert or update push token
  INSERT INTO public.push_tokens (
    user_id, token, platform, device_id, app_version, updated_at, last_used_at
  ) VALUES (
    current_user_id, p_token, p_platform, p_device_id, p_app_version, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
  )
  ON CONFLICT (user_id, token)
  DO UPDATE SET
    platform = EXCLUDED.platform,
    device_id = EXCLUDED.device_id,
    app_version = EXCLUDED.app_version,
    is_active = true,
    is_valid = true,
    updated_at = CURRENT_TIMESTAMP,
    last_used_at = CURRENT_TIMESTAMP,
    error_count = 0,
    last_error_at = NULL,
    last_error_message = NULL
  RETURNING id INTO token_id;
  
  RETURN token_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to mark token as invalid
CREATE OR REPLACE FUNCTION public.mark_token_invalid(
  p_token TEXT,
  p_error_message TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE public.push_tokens
  SET 
    is_valid = false,
    error_count = error_count + 1,
    last_error_at = CURRENT_TIMESTAMP,
    last_error_message = p_error_message,
    updated_at = CURRENT_TIMESTAMP
  WHERE token = p_token;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.register_push_token TO authenticated;
GRANT EXECUTE ON FUNCTION public.mark_token_invalid TO service_role;

-- Comments
COMMENT ON TABLE public.push_tokens IS 'FCM push notification tokens for user devices';
COMMENT ON FUNCTION public.register_push_token IS 'Registers or updates a push notification token';
COMMENT ON FUNCTION public.mark_token_invalid IS 'Marks a push token as invalid after delivery failure';

-- Migration 5: Create Delivery Log Table
-- ========================================================================

-- Create delivery_log table for notification analytics
CREATE TABLE IF NOT EXISTS public.delivery_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- References
  notification_id UUID REFERENCES public.notifications(id) ON DELETE CASCADE,
  event_id UUID REFERENCES public.event_queue(id) ON DELETE SET NULL,
  push_token_id UUID REFERENCES public.push_tokens(id) ON DELETE SET NULL,
  
  -- Delivery information
  channel VARCHAR(20) NOT NULL CHECK (channel IN ('fcm', 'in_app', 'email', 'sms')),
  delivery_status VARCHAR(20) NOT NULL CHECK (delivery_status IN ('pending', 'sent', 'delivered', 'failed', 'expired')),
  
  -- External service response
  external_message_id TEXT, -- FCM message ID, email ID, etc.
  external_response JSONB,
  
  -- Error tracking
  error_code VARCHAR(50),
  error_message TEXT,
  retry_count INTEGER DEFAULT 0,
  
  -- Performance metrics
  processing_time_ms INTEGER,
  queue_time_ms INTEGER,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  sent_at TIMESTAMP WITH TIME ZONE,
  delivered_at TIMESTAMP WITH TIME ZONE,
  failed_at TIMESTAMP WITH TIME ZONE
);

-- Create indexes for analytics
CREATE INDEX IF NOT EXISTS idx_delivery_log_notification 
ON public.delivery_log(notification_id);

CREATE INDEX IF NOT EXISTS idx_delivery_log_status 
ON public.delivery_log(delivery_status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_delivery_log_channel 
ON public.delivery_log(channel, delivery_status, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_delivery_log_analytics 
ON public.delivery_log(created_at DESC, channel, delivery_status);

-- Enable RLS
ALTER TABLE public.delivery_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies - Only service role needs access for analytics
CREATE POLICY "Service role can manage delivery logs" ON public.delivery_log
FOR ALL USING (auth.role() = 'service_role');

-- Grant permissions
GRANT ALL ON public.delivery_log TO service_role;

-- Create function to log delivery attempt
CREATE OR REPLACE FUNCTION public.log_delivery_attempt(
  p_notification_id UUID,
  p_channel VARCHAR(20),
  p_delivery_status VARCHAR(20),
  p_external_message_id TEXT DEFAULT NULL,
  p_external_response JSONB DEFAULT NULL,
  p_error_code VARCHAR(50) DEFAULT NULL,
  p_error_message TEXT DEFAULT NULL,
  p_processing_time_ms INTEGER DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  log_id UUID;
BEGIN
  INSERT INTO public.delivery_log (
    notification_id,
    channel,
    delivery_status,
    external_message_id,
    external_response,
    error_code,
    error_message,
    processing_time_ms,
    sent_at,
    delivered_at,
    failed_at
  ) VALUES (
    p_notification_id,
    p_channel,
    p_delivery_status,
    p_external_message_id,
    p_external_response,
    p_error_code,
    p_error_message,
    p_processing_time_ms,
    CASE WHEN p_delivery_status IN ('sent', 'delivered') THEN CURRENT_TIMESTAMP END,
    CASE WHEN p_delivery_status = 'delivered' THEN CURRENT_TIMESTAMP END,
    CASE WHEN p_delivery_status = 'failed' THEN CURRENT_TIMESTAMP END
  )
  RETURNING id INTO log_id;
  
  RETURN log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION public.log_delivery_attempt TO service_role;

-- Comments
COMMENT ON TABLE public.delivery_log IS 'Delivery tracking and analytics for all notification channels';
COMMENT ON FUNCTION public.log_delivery_attempt IS 'Logs a delivery attempt for analytics and debugging';

-- Migration 6: Create Event Triggers and Webhook Functions
-- ========================================================================

-- Create function to notify webhook on event queue insert
CREATE OR REPLACE FUNCTION public.notify_event_queue_webhook()
RETURNS TRIGGER AS $$
DECLARE
  webhook_payload JSONB;
  webhook_url TEXT;
  webhook_secret TEXT;
BEGIN
  -- Get webhook configuration from app settings
  SELECT 
    COALESCE(current_setting('app.webhook_url', true), 'https://api.foodq.com/api/notifications/process') as url,
    COALESCE(current_setting('app.webhook_secret', true), 'default-webhook-secret') as secret
  INTO webhook_url, webhook_secret;
  
  -- Prepare webhook payload
  webhook_payload := jsonb_build_object(
    'eventId', NEW.id,
    'eventType', NEW.event_type,
    'eventName', NEW.event_name,
    'eventVersion', NEW.event_version,
    'payload', NEW.payload,
    'metadata', NEW.metadata,
    'timestamp', NEW.created_at,
    'status', NEW.status
  );
  
  -- Try to send webhook notification using pg_net extension (if available)
  BEGIN
    -- Check if pg_net extension is available
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_net') THEN
      -- Send HTTP POST request
      PERFORM net.http_post(
        url := webhook_url,
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'X-Webhook-Secret', webhook_secret,
          'X-Event-Type', NEW.event_type,
          'X-Event-Id', NEW.id::text
        ),
        body := webhook_payload,
        timeout_milliseconds := 30000
      );
    ELSE
      -- Fallback: Use NOTIFY for local development/testing
      PERFORM pg_notify('event_queue_webhook', webhook_payload::text);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- Log error but don't fail the transaction
      RAISE WARNING 'Failed to send webhook notification: %', SQLERRM;
      
      -- Update event status to indicate webhook failure
      UPDATE public.event_queue
      SET 
        status = 'failed',
        error_message = 'Webhook notification failed: ' || SQLERRM,
        error_details = jsonb_build_object(
          'error', SQLERRM,
          'timestamp', CURRENT_TIMESTAMP,
          'webhook_url', webhook_url
        )
      WHERE id = NEW.id;
  END;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for webhook notification on event queue insert
CREATE TRIGGER event_queue_webhook_trigger
AFTER INSERT ON public.event_queue
FOR EACH ROW
EXECUTE FUNCTION public.notify_event_queue_webhook();

-- Create function to automatically create order events
CREATE OR REPLACE FUNCTION public.create_order_event()
RETURNS TRIGGER AS $$
DECLARE
  business_info RECORD;
  customer_info RECORD;
  event_payload JSONB;
BEGIN
  -- Get business and customer information
  SELECT b.name, b.owner_id, b.latitude, b.longitude, b.address
  INTO business_info
  FROM public.businesses b
  WHERE b.id = NEW.business_id;
  
  SELECT u.email, u.raw_user_meta_data->>'name' as name
  INTO customer_info
  FROM auth.users u
  WHERE u.id = NEW.user_id;
  
  IF TG_OP = 'INSERT' THEN
    -- Create ORDER_CREATED event
    INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
    VALUES (
      'ORDER_CREATED',
      'New order created',
      jsonb_build_object(
        'orderId', NEW.id,
        'orderNumber', NEW.order_number,
        'businessId', NEW.business_id,
        'businessName', business_info.name,
        'businessOwnerId', business_info.owner_id,
        'customerId', NEW.user_id,
        'customerName', customer_info.name,
        'customerEmail', customer_info.email,
        'amount', NEW.total_amount,
        'items', NEW.items,
        'status', NEW.status,
        'paymentMethod', NEW.payment_method,
        'pickupTime', NEW.pickup_time,
        'location', jsonb_build_object(
          'latitude', business_info.latitude,
          'longitude', business_info.longitude,
          'address', business_info.address
        ),
        'createdAt', NEW.created_at
      ),
      jsonb_build_object(
        'source', 'order_trigger',
        'version', '1.0',
        'triggerType', 'INSERT'
      )
    );
    
  ELSIF TG_OP = 'UPDATE' THEN
    -- Check for status changes
    IF OLD.status != NEW.status THEN
      -- Determine event type based on new status
      DECLARE
        event_type_name TEXT;
        event_description TEXT;
      BEGIN
        CASE NEW.status
          WHEN 'paid' THEN
            event_type_name := 'ORDER_PAID';
            event_description := 'Order payment confirmed';
          WHEN 'confirmed' THEN
            event_type_name := 'ORDER_CONFIRMED';
            event_description := 'Order confirmed by business';
          WHEN 'preparing' THEN
            event_type_name := 'ORDER_PREPARING';
            event_description := 'Order is being prepared';
          WHEN 'ready' THEN
            event_type_name := 'ORDER_READY';
            event_description := 'Order is ready for pickup';
          WHEN 'completed' THEN
            event_type_name := 'ORDER_COMPLETED';
            event_description := 'Order completed';
          WHEN 'cancelled' THEN
            event_type_name := 'ORDER_CANCELLED';
            event_description := 'Order cancelled';
          ELSE
            event_type_name := 'ORDER_UPDATED';
            event_description := 'Order status updated';
        END CASE;
        
        -- Create status change event
        INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
        VALUES (
          event_type_name,
          event_description,
          jsonb_build_object(
            'orderId', NEW.id,
            'orderNumber', NEW.order_number,
            'businessId', NEW.business_id,
            'businessName', business_info.name,
            'businessOwnerId', business_info.owner_id,
            'customerId', NEW.user_id,
            'customerName', customer_info.name,
            'oldStatus', OLD.status,
            'newStatus', NEW.status,
            'amount', NEW.total_amount,
            'verificationCode', NEW.verification_code,
            'qrCode', NEW.qr_code,
            'pickupTime', NEW.pickup_time,
            'completedAt', NEW.completed_at,
            'location', jsonb_build_object(
              'latitude', business_info.latitude,
              'longitude', business_info.longitude,
              'address', business_info.address
            ),
            'updatedAt', NEW.updated_at
          ),
          jsonb_build_object(
            'source', 'order_trigger',
            'version', '1.0',
            'triggerType', 'UPDATE',
            'previousStatus', OLD.status
          )
        );
      END;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for order events
CREATE TRIGGER order_event_trigger
AFTER INSERT OR UPDATE ON public.orders
FOR EACH ROW
EXECUTE FUNCTION public.create_order_event();

-- Create function to create deal events with location awareness
CREATE OR REPLACE FUNCTION public.create_deal_event()
RETURNS TRIGGER AS $$
DECLARE
  business_location RECORD;
  deal_discount NUMERIC;
  quantity_total INTEGER;
  is_deal_active BOOLEAN;
BEGIN
  -- Get business location and details
  SELECT 
    b.name, b.owner_id, b.latitude, b.longitude, b.address,
    b.city, b.state, b.phone, b.email
  INTO business_location
  FROM public.businesses b
  WHERE b.id = NEW.business_id;
  
  -- Calculate discount percentage
  IF NEW.original_price IS NOT NULL AND NEW.original_price > 0 THEN
    deal_discount := ROUND(((NEW.original_price - COALESCE(NEW.discounted_price, NEW.original_price)) / NEW.original_price * 100)::numeric, 0);
  ELSE
    deal_discount := 0;
  END IF;
  
  -- Calculate total quantity (available + sold)
  quantity_total := COALESCE(NEW.quantity_available, 0) + COALESCE(NEW.quantity_sold, 0);
  
  -- Determine if deal is active
  is_deal_active := (NEW.status = 'active' AND NEW.expires_at > CURRENT_TIMESTAMP);
  
  IF TG_OP = 'INSERT' THEN
    -- Create DEAL_CREATED event
    INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
    VALUES (
      'DEAL_CREATED',
      'New deal created',
      jsonb_build_object(
        'dealId', NEW.id,
        'businessId', NEW.business_id,
        'businessName', business_location.name,
        'businessOwnerId', business_location.owner_id,
        'title', NEW.title,
        'description', NEW.description,
        'originalPrice', NEW.original_price,
        'discountedPrice', NEW.discounted_price,
        'discount', deal_discount,
        'imageUrl', NEW.image_url,
        'quantityAvailable', NEW.quantity_available,
        'quantityTotal', quantity_total,
        'expiresAt', NEW.expires_at,
        'isActive', is_deal_active,
        'location', jsonb_build_object(
          'latitude', business_location.latitude,
          'longitude', business_location.longitude,
          'address', business_location.address,
          'city', business_location.city,
          'state', business_location.state
        ),
        'businessContact', jsonb_build_object(
          'phone', business_location.phone,
          'email', business_location.email
        ),
        'createdAt', NEW.created_at
      ),
      jsonb_build_object(
        'source', 'deal_trigger',
        'version', '1.0',
        'notificationRadius', 5, -- Default 5km radius
        'triggerType', 'INSERT'
      )
    );
    
    -- Check if deal is expiring soon (within 4 hours) and create expiring event
    IF NEW.expires_at <= CURRENT_TIMESTAMP + INTERVAL '4 hours' THEN
      INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
      VALUES (
        'DEAL_EXPIRING',
        'Deal expiring soon',
        jsonb_build_object(
          'dealId', NEW.id,
          'businessId', NEW.business_id,
          'businessName', business_location.name,
          'title', NEW.title,
          'discount', deal_discount,
          'expiresAt', NEW.expires_at,
          'expiresIn', EXTRACT(EPOCH FROM (NEW.expires_at - CURRENT_TIMESTAMP)),
          'quantityAvailable', NEW.quantity_available,
          'location', jsonb_build_object(
            'latitude', business_location.latitude,
            'longitude', business_location.longitude,
            'address', business_location.address
          )
        ),
        jsonb_build_object(
          'source', 'deal_trigger',
          'version', '1.0',
          'urgency', 'high',
          'notificationRadius', 3 -- Smaller radius for urgent notifications
        )
      );
    END IF;
    
  ELSIF TG_OP = 'UPDATE' THEN
    -- Check for quantity changes (sold out)
    IF OLD.quantity_available > 0 AND NEW.quantity_available = 0 AND is_deal_active = true THEN
      INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
      VALUES (
        'DEAL_SOLD_OUT',
        'Deal sold out',
        jsonb_build_object(
          'dealId', NEW.id,
          'businessId', NEW.business_id,
          'businessName', business_location.name,
          'title', NEW.title,
          'totalSold', quantity_total,
          'soldOutAt', CURRENT_TIMESTAMP
        ),
        jsonb_build_object(
          'source', 'deal_trigger',
          'version', '1.0',
          'triggerType', 'UPDATE'
        )
      );
    END IF;
    
    -- Check for status changes (deactivated)  
    DECLARE
      old_is_active BOOLEAN;
    BEGIN
      old_is_active := (OLD.status = 'active' AND OLD.expires_at > CURRENT_TIMESTAMP);
      
      IF old_is_active = true AND is_deal_active = false THEN
      INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
      VALUES (
        'DEAL_EXPIRED',
        'Deal expired or deactivated',
        jsonb_build_object(
          'dealId', NEW.id,
          'businessId', NEW.business_id,
          'title', NEW.title,
          'deactivatedAt', CURRENT_TIMESTAMP,
          'reason', CASE 
            WHEN NEW.expires_at <= CURRENT_TIMESTAMP THEN 'expired'
            ELSE 'manually_deactivated'
          END
        ),
        jsonb_build_object(
          'source', 'deal_trigger',
          'version', '1.0',
          'triggerType', 'UPDATE'
        )
      );
      END IF;
    END;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for deal events
CREATE TRIGGER deal_event_trigger
AFTER INSERT OR UPDATE ON public.deals
FOR EACH ROW
EXECUTE FUNCTION public.create_deal_event();

-- Create function to update event queue status
CREATE OR REPLACE FUNCTION public.update_event_queue_status(
  p_event_id UUID,
  p_status VARCHAR(20),
  p_error_message TEXT DEFAULT NULL,
  p_error_details JSONB DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE public.event_queue
  SET 
    status = p_status,
    processed_at = CASE WHEN p_status = 'processed' THEN CURRENT_TIMESTAMP ELSE processed_at END,
    error_message = p_error_message,
    error_details = p_error_details,
    retry_count = CASE WHEN p_status = 'retry' THEN retry_count + 1 ELSE retry_count END,
    next_retry_at = CASE 
      WHEN p_status = 'retry' THEN CURRENT_TIMESTAMP + (INTERVAL '1 minute' * POWER(2, retry_count + 1))
      ELSE next_retry_at 
    END
  WHERE id = p_event_id;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get pending events for processing
CREATE OR REPLACE FUNCTION public.get_pending_events(p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
  id UUID,
  event_type VARCHAR(100),
  event_name VARCHAR(200),
  payload JSONB,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  retry_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    eq.id,
    eq.event_type,
    eq.event_name,
    eq.payload,
    eq.metadata,
    eq.created_at,
    eq.retry_count
  FROM public.event_queue eq
  WHERE eq.status IN ('pending', 'retry')
    AND (eq.next_retry_at IS NULL OR eq.next_retry_at <= CURRENT_TIMESTAMP)
    AND eq.retry_count < eq.max_retries
  ORDER BY eq.created_at ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.update_event_queue_status TO service_role;
GRANT EXECUTE ON FUNCTION public.get_pending_events TO service_role;

-- Comments for documentation
COMMENT ON FUNCTION public.notify_event_queue_webhook IS 'Sends webhook notification when new event is queued';
COMMENT ON FUNCTION public.create_order_event IS 'Automatically creates events for order status changes';
COMMENT ON FUNCTION public.create_deal_event IS 'Automatically creates events for deal creation and updates';
COMMENT ON FUNCTION public.update_event_queue_status IS 'Updates event processing status from webhook handler';
COMMENT ON FUNCTION public.get_pending_events IS 'Gets pending events for processing';

-- ========================================================================
-- DEPLOYMENT COMPLETE!
-- ========================================================================
-- 
-- This completes the notification schema deployment.
-- 
-- NEXT STEPS:
-- 1. Verify all tables were created by running:
--    SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('event_queue', 'notifications', 'user_locations', 'push_tokens', 'delivery_log');
-- 
-- 2. Test event creation:
--    INSERT INTO public.event_queue (event_type, event_name, payload) VALUES ('SYSTEM_ANNOUNCEMENT', 'Test Event', '{"test": true}');
--
-- 3. Check webhook notifications in logs
--
-- 4. Configure your notification processor to use these tables
-- 
-- ========================================================================