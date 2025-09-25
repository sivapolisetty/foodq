-- Fix push_tokens table schema
-- This script can be run directly in Supabase SQL Editor

-- Step 1: Check if push_tokens table exists, if not create it
CREATE TABLE IF NOT EXISTS push_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES app_users(id) ON DELETE CASCADE,
  fcm_token TEXT NOT NULL,
  platform TEXT NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
  device_id TEXT,
  device_model TEXT,
  device_name TEXT,
  app_version TEXT,
  os_version TEXT,
  is_active BOOLEAN DEFAULT true,
  consecutive_failures INTEGER DEFAULT 0,
  last_used_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, fcm_token)
);

-- Step 2: If table already exists, ensure fcm_token column exists
DO $$ 
BEGIN
  -- Check if we need to rename 'token' column to 'fcm_token'
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'push_tokens' 
    AND column_name = 'token'
  ) AND NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'push_tokens' 
    AND column_name = 'fcm_token'
  ) THEN
    -- Rename token to fcm_token
    ALTER TABLE push_tokens RENAME COLUMN token TO fcm_token;
  END IF;
  
  -- Add missing columns if they don't exist
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'push_tokens' AND column_name = 'platform') THEN
    ALTER TABLE push_tokens ADD COLUMN platform TEXT DEFAULT 'android';
    ALTER TABLE push_tokens ALTER COLUMN platform SET NOT NULL;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'push_tokens' AND column_name = 'is_active') THEN
    ALTER TABLE push_tokens ADD COLUMN is_active BOOLEAN DEFAULT true;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'push_tokens' AND column_name = 'consecutive_failures') THEN
    ALTER TABLE push_tokens ADD COLUMN consecutive_failures INTEGER DEFAULT 0;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'push_tokens' AND column_name = 'last_used_at') THEN
    ALTER TABLE push_tokens ADD COLUMN last_used_at TIMESTAMPTZ DEFAULT NOW();
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'push_tokens' AND column_name = 'device_model') THEN
    ALTER TABLE push_tokens ADD COLUMN device_model TEXT;
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'push_tokens' AND column_name = 'device_id') THEN
    ALTER TABLE push_tokens ADD COLUMN device_id TEXT;
  END IF;
END $$;

-- Step 3: Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_push_tokens_user_id ON push_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_push_tokens_fcm_token ON push_tokens(fcm_token);
CREATE INDEX IF NOT EXISTS idx_push_tokens_active ON push_tokens(is_active) WHERE is_active = true;

-- Step 4: Enable Row Level Security
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

-- Step 5: Create RLS policies
DROP POLICY IF EXISTS "Users can view their own push tokens" ON push_tokens;
CREATE POLICY "Users can view their own push tokens" ON push_tokens
  FOR SELECT USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own push tokens" ON push_tokens;
CREATE POLICY "Users can insert their own push tokens" ON push_tokens
  FOR INSERT WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own push tokens" ON push_tokens;
CREATE POLICY "Users can update their own push tokens" ON push_tokens
  FOR UPDATE USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own push tokens" ON push_tokens;
CREATE POLICY "Users can delete their own push tokens" ON push_tokens
  FOR DELETE USING (auth.uid() = user_id);

-- Step 6: Insert a test token for testing (optional - remove in production)
-- This creates a test token for the test user we've been using
INSERT INTO push_tokens (
  user_id,
  fcm_token,
  platform,
  device_model,
  is_active
) VALUES (
  '123e4567-e89b-12d3-a456-426614174000', -- Test user ID from our auth.ts
  'test-fcm-token-for-notifications',
  'android',
  'Test Device',
  true
) ON CONFLICT (user_id, fcm_token) DO UPDATE
  SET last_used_at = NOW(),
      is_active = true;

-- Step 7: Verify the table structure
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'push_tokens'
ORDER BY ordinal_position;

-- Step 8: Check if we have any tokens
SELECT COUNT(*) as token_count FROM push_tokens;