-- Migration: Create Delivery Log Table
-- Description: Track notification delivery across all channels
-- Version: 1.0
-- Date: 2025-09-23

-- Create delivery_log table
CREATE TABLE IF NOT EXISTS public.delivery_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  notification_id UUID NOT NULL REFERENCES public.notifications(id) ON DELETE CASCADE,
  
  -- Delivery details
  channel VARCHAR(20) NOT NULL CHECK (channel IN ('fcm', 'in_app', 'email', 'sms', 'webhook')),
  status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'sent', 'delivered', 'failed', 'bounced', 'clicked')),
  
  -- Provider/service details
  provider VARCHAR(50), -- 'fcm', 'sendgrid', 'twilio', etc.
  provider_response JSONB,
  provider_message_id TEXT,
  
  -- Error handling
  error_code TEXT,
  error_message TEXT,
  error_details JSONB,
  
  -- Timing
  attempted_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  delivered_at TIMESTAMP WITH TIME ZONE,
  response_received_at TIMESTAMP WITH TIME ZONE,
  
  -- Retry information
  retry_count INTEGER DEFAULT 0,
  next_retry_at TIMESTAMP WITH TIME ZONE,
  max_retries INTEGER DEFAULT 3,
  
  -- Additional metadata
  metadata JSONB DEFAULT '{}'
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_delivery_log_notification 
ON public.delivery_log(notification_id, channel);

CREATE INDEX IF NOT EXISTS idx_delivery_log_status 
ON public.delivery_log(status, attempted_at DESC);

CREATE INDEX IF NOT EXISTS idx_delivery_log_channel 
ON public.delivery_log(channel, status, attempted_at DESC);

CREATE INDEX IF NOT EXISTS idx_delivery_log_retry 
ON public.delivery_log(next_retry_at) 
WHERE status IN ('failed', 'pending') AND retry_count < max_retries;

CREATE INDEX IF NOT EXISTS idx_delivery_log_provider_message 
ON public.delivery_log(provider_message_id) 
WHERE provider_message_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_delivery_log_delivered 
ON public.delivery_log(delivered_at DESC) 
WHERE delivered_at IS NOT NULL;

-- Enable RLS
ALTER TABLE public.delivery_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Service role can access all delivery logs
CREATE POLICY "Service role can access all delivery logs" ON public.delivery_log
FOR ALL USING (auth.role() = 'service_role');

-- Users can view delivery logs for their own notifications
CREATE POLICY "Users can view own delivery logs" ON public.delivery_log
FOR SELECT USING (
  EXISTS (
    SELECT 1 FROM public.notifications n
    WHERE n.id = delivery_log.notification_id
    AND n.recipient_id = auth.uid()
  )
);

-- Grant permissions
GRANT SELECT ON public.delivery_log TO authenticated;
GRANT ALL ON public.delivery_log TO service_role;

-- Create function to log delivery attempt
CREATE OR REPLACE FUNCTION public.log_delivery_attempt(
  p_notification_id UUID,
  p_channel VARCHAR(20),
  p_status VARCHAR(20),
  p_provider VARCHAR(50) DEFAULT NULL,
  p_provider_message_id TEXT DEFAULT NULL,
  p_provider_response JSONB DEFAULT NULL,
  p_error_code TEXT DEFAULT NULL,
  p_error_message TEXT DEFAULT NULL,
  p_metadata JSONB DEFAULT '{}'
)
RETURNS UUID AS $$
DECLARE
  log_id UUID;
  delivery_time TIMESTAMP WITH TIME ZONE;
BEGIN
  -- Set delivery time if status is 'delivered' or 'sent'
  IF p_status IN ('delivered', 'sent') THEN
    delivery_time := CURRENT_TIMESTAMP;
  END IF;
  
  INSERT INTO public.delivery_log (
    notification_id, channel, status, provider, provider_message_id,
    provider_response, error_code, error_message, delivered_at, metadata
  )
  VALUES (
    p_notification_id, p_channel, p_status, p_provider, p_provider_message_id,
    p_provider_response, p_error_code, p_error_message, delivery_time, p_metadata
  )
  RETURNING id INTO log_id;
  
  -- Update notification delivery status
  UPDATE public.notifications
  SET 
    delivery_status = delivery_status || jsonb_build_object(p_channel, p_status),
    sent_at = CASE WHEN p_status = 'sent' AND sent_at IS NULL THEN CURRENT_TIMESTAMP ELSE sent_at END,
    delivered_at = CASE WHEN p_status = 'delivered' THEN CURRENT_TIMESTAMP ELSE delivered_at END,
    updated_at = CURRENT_TIMESTAMP
  WHERE id = p_notification_id;
  
  RETURN log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to update delivery status
CREATE OR REPLACE FUNCTION public.update_delivery_status(
  p_log_id UUID,
  p_status VARCHAR(20),
  p_provider_response JSONB DEFAULT NULL,
  p_error_code TEXT DEFAULT NULL,
  p_error_message TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  updated_count INTEGER;
  delivery_time TIMESTAMP WITH TIME ZONE;
  log_record RECORD;
BEGIN
  -- Set delivery time if status is 'delivered'
  IF p_status = 'delivered' THEN
    delivery_time := CURRENT_TIMESTAMP;
  END IF;
  
  -- Update the delivery log
  UPDATE public.delivery_log
  SET 
    status = p_status,
    provider_response = COALESCE(p_provider_response, provider_response),
    error_code = p_error_code,
    error_message = p_error_message,
    delivered_at = COALESCE(delivery_time, delivered_at),
    response_received_at = CURRENT_TIMESTAMP
  WHERE id = p_log_id
  RETURNING notification_id, channel INTO log_record;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  
  -- Update notification delivery status
  IF updated_count > 0 THEN
    UPDATE public.notifications
    SET 
      delivery_status = delivery_status || jsonb_build_object(log_record.channel, p_status),
      delivered_at = CASE WHEN p_status = 'delivered' THEN CURRENT_TIMESTAMP ELSE delivered_at END,
      updated_at = CURRENT_TIMESTAMP
    WHERE id = log_record.notification_id;
  END IF;
  
  RETURN updated_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get delivery statistics
CREATE OR REPLACE FUNCTION public.get_delivery_stats(
  p_start_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP - INTERVAL '24 hours',
  p_end_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
)
RETURNS TABLE(
  channel VARCHAR(20),
  total_attempts BIGINT,
  successful_deliveries BIGINT,
  failed_deliveries BIGINT,
  avg_delivery_time_seconds NUMERIC,
  success_rate NUMERIC
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    dl.channel,
    COUNT(*) as total_attempts,
    COUNT(*) FILTER (WHERE dl.status IN ('delivered', 'sent')) as successful_deliveries,
    COUNT(*) FILTER (WHERE dl.status IN ('failed', 'bounced')) as failed_deliveries,
    AVG(EXTRACT(EPOCH FROM (dl.delivered_at - dl.attempted_at))) as avg_delivery_time_seconds,
    ROUND(
      (COUNT(*) FILTER (WHERE dl.status IN ('delivered', 'sent'))::NUMERIC / 
       NULLIF(COUNT(*), 0) * 100), 2
    ) as success_rate
  FROM public.delivery_log dl
  WHERE dl.attempted_at BETWEEN p_start_date AND p_end_date
  GROUP BY dl.channel
  ORDER BY total_attempts DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get failed deliveries for retry
CREATE OR REPLACE FUNCTION public.get_failed_deliveries_for_retry()
RETURNS TABLE(
  log_id UUID,
  notification_id UUID,
  channel VARCHAR(20),
  retry_count INTEGER,
  last_error TEXT,
  next_retry_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    dl.id as log_id,
    dl.notification_id,
    dl.channel,
    dl.retry_count,
    dl.error_message as last_error,
    dl.next_retry_at
  FROM public.delivery_log dl
  WHERE dl.status = 'failed'
    AND dl.retry_count < dl.max_retries
    AND (dl.next_retry_at IS NULL OR dl.next_retry_at <= CURRENT_TIMESTAMP)
  ORDER BY dl.attempted_at ASC
  LIMIT 100;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to cleanup old delivery logs
CREATE OR REPLACE FUNCTION public.cleanup_old_delivery_logs()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete delivery logs older than 90 days
  DELETE FROM public.delivery_log
  WHERE attempted_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.log_delivery_attempt TO service_role;
GRANT EXECUTE ON FUNCTION public.update_delivery_status TO service_role;
GRANT EXECUTE ON FUNCTION public.get_delivery_stats TO service_role;
GRANT EXECUTE ON FUNCTION public.get_failed_deliveries_for_retry TO service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_old_delivery_logs TO service_role;

-- Comments for documentation
COMMENT ON TABLE public.delivery_log IS 'Detailed log of all notification delivery attempts across channels';
COMMENT ON COLUMN public.delivery_log.provider_response IS 'Raw response from delivery provider (FCM, email service, etc.)';
COMMENT ON COLUMN public.delivery_log.metadata IS 'Additional context like user agent, IP, etc.';
COMMENT ON FUNCTION public.log_delivery_attempt IS 'Log a delivery attempt for a notification';
COMMENT ON FUNCTION public.get_delivery_stats IS 'Get delivery statistics for a time period';
COMMENT ON FUNCTION public.get_failed_deliveries_for_retry IS 'Get failed deliveries that need retry';