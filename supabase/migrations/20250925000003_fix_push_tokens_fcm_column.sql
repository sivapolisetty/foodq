-- Fix push_tokens table to have fcm_token column
-- The notification system expects fcm_token but the table might have a different column name

-- First, check if fcm_token column already exists
DO $$ 
BEGIN
  -- If the column doesn't exist, we need to either rename or add it
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'push_tokens' 
    AND column_name = 'fcm_token'
  ) THEN
    -- Check if there's a token column that should be renamed
    IF EXISTS (
      SELECT 1 FROM information_schema.columns 
      WHERE table_name = 'push_tokens' 
      AND column_name = 'token'
    ) THEN
      -- Rename token to fcm_token
      ALTER TABLE push_tokens RENAME COLUMN token TO fcm_token;
    ELSE
      -- Add fcm_token column if it doesn't exist at all
      ALTER TABLE push_tokens ADD COLUMN fcm_token TEXT NOT NULL;
    END IF;
  END IF;
END $$;

-- Ensure the push_tokens table has all required columns for the notification system
ALTER TABLE push_tokens 
  ALTER COLUMN fcm_token SET NOT NULL;

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_push_tokens_user_id ON push_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_push_tokens_fcm_token ON push_tokens(fcm_token);

-- Add comment to clarify the column purpose
COMMENT ON COLUMN push_tokens.fcm_token IS 'Firebase Cloud Messaging token for push notifications';