-- Fix push_tokens table foreign key constraints
-- The table is referencing 'users' but should reference 'app_users'

-- Step 1: Drop the existing table if it has wrong constraints
DROP TABLE IF EXISTS push_tokens CASCADE;

-- Step 2: Create push_tokens table with correct foreign key to app_users
CREATE TABLE push_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL,
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
  UNIQUE(user_id, fcm_token),
  -- Correct foreign key constraint pointing to app_users, not users
  CONSTRAINT push_tokens_user_id_fkey FOREIGN KEY (user_id) 
    REFERENCES app_users(id) ON DELETE CASCADE
);

-- Step 3: Create indexes for better performance
CREATE INDEX idx_push_tokens_user_id ON push_tokens(user_id);
CREATE INDEX idx_push_tokens_fcm_token ON push_tokens(fcm_token);
CREATE INDEX idx_push_tokens_active ON push_tokens(is_active) WHERE is_active = true;

-- Step 4: Enable Row Level Security
ALTER TABLE push_tokens ENABLE ROW LEVEL SECURITY;

-- Step 5: Create RLS policies (updated to work with app_users)
-- Note: These policies assume auth.uid() matches app_users.id
CREATE POLICY "Users can view their own push tokens" ON push_tokens
  FOR SELECT USING (
    user_id IN (
      SELECT id FROM app_users WHERE id = auth.uid()
    )
  );

CREATE POLICY "Users can insert their own push tokens" ON push_tokens
  FOR INSERT WITH CHECK (
    user_id IN (
      SELECT id FROM app_users WHERE id = auth.uid()
    )
  );

CREATE POLICY "Users can update their own push tokens" ON push_tokens
  FOR UPDATE USING (
    user_id IN (
      SELECT id FROM app_users WHERE id = auth.uid()
    )
  );

CREATE POLICY "Users can delete their own push tokens" ON push_tokens
  FOR DELETE USING (
    user_id IN (
      SELECT id FROM app_users WHERE id = auth.uid()
    )
  );

-- Step 6: Service role can do everything (for backend operations)
CREATE POLICY "Service role has full access" ON push_tokens
  USING (auth.role() = 'service_role');

-- Step 7: Insert test tokens for existing users (optional - for testing)
-- First, let's check what users exist in app_users
DO $$
DECLARE
  test_user_id UUID;
BEGIN
  -- Get the first user from app_users for testing
  SELECT id INTO test_user_id FROM app_users LIMIT 1;
  
  IF test_user_id IS NOT NULL THEN
    -- Insert a test token for this user
    INSERT INTO push_tokens (
      user_id,
      fcm_token,
      platform,
      device_model,
      is_active
    ) VALUES (
      test_user_id,
      'test-fcm-token-for-notifications-' || test_user_id,
      'android',
      'Test Device',
      true
    ) ON CONFLICT (user_id, fcm_token) DO UPDATE
      SET last_used_at = NOW(),
          is_active = true;
    
    RAISE NOTICE 'Test token created for user: %', test_user_id;
  ELSE
    RAISE NOTICE 'No users found in app_users table';
  END IF;
END $$;

-- Step 8: Verify the table structure
SELECT 
  c.column_name, 
  c.data_type, 
  c.is_nullable,
  CASE 
    WHEN tc.constraint_type = 'FOREIGN KEY' THEN 'FK to ' || ccu.table_name
    WHEN tc.constraint_type = 'PRIMARY KEY' THEN 'PK'
    WHEN tc.constraint_type = 'UNIQUE' THEN 'UNIQUE'
    ELSE tc.constraint_type
  END as constraint_info
FROM information_schema.columns c
LEFT JOIN information_schema.key_column_usage kcu 
  ON c.table_name = kcu.table_name 
  AND c.column_name = kcu.column_name
LEFT JOIN information_schema.table_constraints tc 
  ON kcu.constraint_name = tc.constraint_name
LEFT JOIN information_schema.constraint_column_usage ccu
  ON tc.constraint_name = ccu.constraint_name
WHERE c.table_name = 'push_tokens'
ORDER BY c.ordinal_position;

-- Step 9: Check if we have any tokens and show sample data
SELECT 
  pt.id,
  pt.user_id,
  au.email as user_email,
  pt.platform,
  pt.is_active,
  pt.created_at
FROM push_tokens pt
LEFT JOIN app_users au ON pt.user_id = au.id
LIMIT 5;