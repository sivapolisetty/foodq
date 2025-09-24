-- Add onboarding_completed column to app_users table
-- This column tracks whether the user has completed their initial onboarding process

-- Add onboarding_completed column to app_users table
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT false;

-- Create index for performance on onboarding_completed lookups
CREATE INDEX IF NOT EXISTS idx_app_users_onboarding_completed ON app_users(onboarding_completed);

-- Add comment for documentation
COMMENT ON COLUMN app_users.onboarding_completed IS 'Tracks whether the user has completed their initial onboarding process (profile setup, phone number, etc.)';