-- Fix existing push_tokens table without dropping it
-- This preserves existing data while fixing the foreign key constraint

-- Step 1: Check current foreign key constraints
SELECT
    tc.constraint_name, 
    tc.constraint_type,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
LEFT JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name = 'push_tokens' 
    AND tc.constraint_type = 'FOREIGN KEY';

-- Step 2: Drop the incorrect foreign key constraint if it exists
DO $$
BEGIN
  -- Drop constraint if it references 'users' table
  IF EXISTS (
    SELECT 1 
    FROM information_schema.constraint_column_usage 
    WHERE constraint_name = 'push_tokens_user_id_fkey' 
    AND table_name = 'users'
  ) THEN
    ALTER TABLE push_tokens DROP CONSTRAINT push_tokens_user_id_fkey;
    RAISE NOTICE 'Dropped incorrect foreign key to users table';
  END IF;
END $$;

-- Step 3: Add the correct foreign key constraint to app_users
DO $$
BEGIN
  -- Check if correct constraint already exists
  IF NOT EXISTS (
    SELECT 1 
    FROM information_schema.constraint_column_usage 
    WHERE constraint_name = 'push_tokens_user_id_fkey' 
    AND table_name = 'app_users'
  ) THEN
    -- Add correct foreign key
    ALTER TABLE push_tokens 
    ADD CONSTRAINT push_tokens_user_id_fkey 
    FOREIGN KEY (user_id) REFERENCES app_users(id) ON DELETE CASCADE;
    RAISE NOTICE 'Added correct foreign key to app_users table';
  ELSE
    RAISE NOTICE 'Correct foreign key already exists';
  END IF;
END $$;

-- Step 4: Ensure all required columns exist
DO $$ 
BEGIN
  -- Add fcm_token if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'push_tokens' AND column_name = 'fcm_token') THEN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'push_tokens' AND column_name = 'token') THEN
      ALTER TABLE push_tokens RENAME COLUMN token TO fcm_token;
    ELSE
      ALTER TABLE push_tokens ADD COLUMN fcm_token TEXT NOT NULL;
    END IF;
  END IF;
  
  -- Add other required columns if missing
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'push_tokens' AND column_name = 'platform') THEN
    ALTER TABLE push_tokens ADD COLUMN platform TEXT DEFAULT 'android' NOT NULL;
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
END $$;

-- Step 5: Create indexes if they don't exist
CREATE INDEX IF NOT EXISTS idx_push_tokens_user_id ON push_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_push_tokens_fcm_token ON push_tokens(fcm_token);
CREATE INDEX IF NOT EXISTS idx_push_tokens_active ON push_tokens(is_active) WHERE is_active = true;

-- Step 6: Show the fixed table structure
SELECT 
  c.column_name, 
  c.data_type, 
  c.is_nullable,
  CASE 
    WHEN ccu.table_name IS NOT NULL THEN 'FK -> ' || ccu.table_name || '.' || ccu.column_name
    ELSE ''
  END as foreign_key_ref
FROM information_schema.columns c
LEFT JOIN information_schema.key_column_usage kcu 
  ON c.table_name = kcu.table_name 
  AND c.column_name = kcu.column_name
LEFT JOIN information_schema.table_constraints tc 
  ON kcu.constraint_name = tc.constraint_name
  AND tc.constraint_type = 'FOREIGN KEY'
LEFT JOIN information_schema.constraint_column_usage ccu
  ON tc.constraint_name = ccu.constraint_name
WHERE c.table_name = 'push_tokens'
ORDER BY c.ordinal_position;

-- Step 7: Test by inserting a token for an existing user
DO $$
DECLARE
  test_user_id UUID;
  test_user_email TEXT;
BEGIN
  -- Get a real user from app_users
  SELECT id, email INTO test_user_id, test_user_email 
  FROM app_users 
  WHERE email IS NOT NULL
  LIMIT 1;
  
  IF test_user_id IS NOT NULL THEN
    -- Try to insert a test token
    INSERT INTO push_tokens (
      user_id,
      fcm_token,
      platform,
      device_model,
      is_active
    ) VALUES (
      test_user_id,
      'test-fcm-' || substring(test_user_id::text, 1, 8),
      'android',
      'Test Device',
      true
    ) ON CONFLICT (user_id, fcm_token) DO UPDATE
      SET last_used_at = NOW(),
          is_active = true;
    
    RAISE NOTICE 'Test token created for user: % (%)', test_user_email, test_user_id;
  ELSE
    RAISE NOTICE 'No users found in app_users table to test with';
  END IF;
END $$;

-- Step 8: Show current tokens with user info
SELECT 
  pt.id,
  pt.user_id,
  au.email as user_email,
  pt.fcm_token,
  pt.platform,
  pt.is_active,
  pt.created_at
FROM push_tokens pt
LEFT JOIN app_users au ON pt.user_id = au.id
ORDER BY pt.created_at DESC
LIMIT 10;