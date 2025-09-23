-- Migration: Create Push Tokens Table
-- Description: Store FCM tokens and device information
-- Version: 1.0
-- Date: 2025-09-23

-- Create push_tokens table
CREATE TABLE IF NOT EXISTS public.push_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- FCM token details
  fcm_token TEXT NOT NULL,
  platform VARCHAR(10) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  
  -- Device information
  device_id TEXT,
  device_model TEXT,
  device_name TEXT,
  app_version TEXT,
  os_version TEXT,
  
  -- Status tracking
  is_active BOOLEAN DEFAULT true,
  last_used_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Error tracking for FCM failures
  failure_count INTEGER DEFAULT 0,
  last_failure_at TIMESTAMP WITH TIME ZONE,
  last_failure_reason TEXT,
  consecutive_failures INTEGER DEFAULT 0,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CONSTRAINT unique_user_token UNIQUE(user_id, fcm_token),
  CONSTRAINT valid_platform CHECK (platform IN ('ios', 'android', 'web')),
  CONSTRAINT reasonable_failure_count CHECK (failure_count >= 0 AND failure_count <= 1000)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_push_tokens_user 
ON public.push_tokens(user_id, is_active);

CREATE INDEX IF NOT EXISTS idx_push_tokens_token 
ON public.push_tokens(fcm_token) WHERE is_active = true;

CREATE INDEX IF NOT EXISTS idx_push_tokens_platform 
ON public.push_tokens(platform, is_active);

CREATE INDEX IF NOT EXISTS idx_push_tokens_failures 
ON public.push_tokens(consecutive_failures, last_failure_at DESC) 
WHERE consecutive_failures > 0;

CREATE INDEX IF NOT EXISTS idx_push_tokens_last_used 
ON public.push_tokens(last_used_at DESC);

-- Enable RLS
ALTER TABLE public.push_tokens ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only manage their own tokens
CREATE POLICY "Users can manage own push tokens" ON public.push_tokens
FOR ALL USING (auth.uid() = user_id);

-- Service role can access all tokens
CREATE POLICY "Service role can access all push tokens" ON public.push_tokens
FOR ALL USING (auth.role() = 'service_role');

-- Grant permissions
GRANT ALL ON public.push_tokens TO authenticated;
GRANT ALL ON public.push_tokens TO service_role;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_push_tokens_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER push_tokens_updated_at
BEFORE UPDATE ON public.push_tokens
FOR EACH ROW
EXECUTE FUNCTION public.update_push_tokens_updated_at();

-- Create function to register or update FCM token
CREATE OR REPLACE FUNCTION public.upsert_push_token(
  p_fcm_token TEXT,
  p_platform VARCHAR(10),
  p_device_id TEXT DEFAULT NULL,
  p_device_model TEXT DEFAULT NULL,
  p_device_name TEXT DEFAULT NULL,
  p_app_version TEXT DEFAULT NULL,
  p_os_version TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  token_id UUID;
  current_user_id UUID;
BEGIN
  current_user_id := auth.uid();
  
  IF current_user_id IS NULL THEN
    RAISE EXCEPTION 'User must be authenticated';
  END IF;
  
  -- Deactivate any existing tokens for this device
  UPDATE public.push_tokens
  SET is_active = false, updated_at = CURRENT_TIMESTAMP
  WHERE user_id = current_user_id 
    AND device_id = p_device_id 
    AND device_id IS NOT NULL
    AND is_active = true;
  
  -- Insert or update the token
  INSERT INTO public.push_tokens (
    user_id, fcm_token, platform, device_id, device_model, 
    device_name, app_version, os_version, is_active, last_used_at
  )
  VALUES (
    current_user_id, p_fcm_token, p_platform, p_device_id, p_device_model,
    p_device_name, p_app_version, p_os_version, true, CURRENT_TIMESTAMP
  )
  ON CONFLICT (user_id, fcm_token) 
  DO UPDATE SET
    platform = EXCLUDED.platform,
    device_id = EXCLUDED.device_id,
    device_model = EXCLUDED.device_model,
    device_name = EXCLUDED.device_name,
    app_version = EXCLUDED.app_version,
    os_version = EXCLUDED.os_version,
    is_active = true,
    last_used_at = CURRENT_TIMESTAMP,
    failure_count = 0,
    consecutive_failures = 0,
    updated_at = CURRENT_TIMESTAMP
  RETURNING id INTO token_id;
  
  RETURN token_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to mark token as failed
CREATE OR REPLACE FUNCTION public.mark_token_failed(
  p_fcm_token TEXT,
  p_failure_reason TEXT DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  updated_count INTEGER;
  current_failures INTEGER;
BEGIN
  -- Get current failure count
  SELECT consecutive_failures INTO current_failures
  FROM public.push_tokens
  WHERE fcm_token = p_fcm_token AND is_active = true;
  
  -- Update failure tracking
  UPDATE public.push_tokens
  SET 
    failure_count = failure_count + 1,
    consecutive_failures = consecutive_failures + 1,
    last_failure_at = CURRENT_TIMESTAMP,
    last_failure_reason = p_failure_reason,
    -- Deactivate after 3 consecutive failures
    is_active = CASE WHEN consecutive_failures + 1 >= 3 THEN false ELSE is_active END,
    updated_at = CURRENT_TIMESTAMP
  WHERE fcm_token = p_fcm_token AND is_active = true;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to mark token as successful (reset failure count)
CREATE OR REPLACE FUNCTION public.mark_token_success(p_fcm_token TEXT)
RETURNS BOOLEAN AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE public.push_tokens
  SET 
    consecutive_failures = 0,
    last_used_at = CURRENT_TIMESTAMP,
    is_active = true,
    updated_at = CURRENT_TIMESTAMP
  WHERE fcm_token = p_fcm_token;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get active tokens for user
CREATE OR REPLACE FUNCTION public.get_user_active_tokens(target_user_id UUID)
RETURNS TABLE(
  fcm_token TEXT,
  platform VARCHAR(10),
  device_model TEXT,
  last_used_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    pt.fcm_token,
    pt.platform,
    pt.device_model,
    pt.last_used_at
  FROM public.push_tokens pt
  WHERE pt.user_id = target_user_id
    AND pt.is_active = true
    AND pt.consecutive_failures < 3
  ORDER BY pt.last_used_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to cleanup old inactive tokens
CREATE OR REPLACE FUNCTION public.cleanup_old_push_tokens()
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  -- Delete tokens that have been inactive for more than 90 days
  DELETE FROM public.push_tokens
  WHERE is_active = false 
    AND updated_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  -- Also delete tokens with too many failures that are old
  DELETE FROM public.push_tokens
  WHERE consecutive_failures >= 10
    AND last_failure_at < CURRENT_TIMESTAMP - INTERVAL '30 days';
  
  GET DIAGNOSTICS deleted_count = deleted_count + ROW_COUNT;
  
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.upsert_push_token TO authenticated;
GRANT EXECUTE ON FUNCTION public.mark_token_failed TO service_role;
GRANT EXECUTE ON FUNCTION public.mark_token_success TO service_role;
GRANT EXECUTE ON FUNCTION public.get_user_active_tokens TO service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_old_push_tokens TO service_role;

-- Comments for documentation
COMMENT ON TABLE public.push_tokens IS 'FCM push notification tokens for devices';
COMMENT ON COLUMN public.push_tokens.consecutive_failures IS 'Count of consecutive delivery failures (token deactivated after 3)';
COMMENT ON FUNCTION public.upsert_push_token IS 'Register or update FCM token for current user';
COMMENT ON FUNCTION public.mark_token_failed IS 'Mark token as failed delivery (deactivates after 3 failures)';
COMMENT ON FUNCTION public.get_user_active_tokens IS 'Get all active FCM tokens for a user';