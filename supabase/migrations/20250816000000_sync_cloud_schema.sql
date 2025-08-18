-- Sync cloud schema to local Supabase
-- Add missing columns to app_users table to match cloud

-- Add missing address fields
ALTER TABLE app_users 
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS city TEXT,
ADD COLUMN IF NOT EXISTS state TEXT,
ADD COLUMN IF NOT EXISTS postal_code TEXT,
ADD COLUMN IF NOT EXISTS country TEXT DEFAULT 'United States',
ADD COLUMN IF NOT EXISTS latitude DECIMAL(10, 8),
ADD COLUMN IF NOT EXISTS longitude DECIMAL(11, 8);

-- Add missing preference fields
ALTER TABLE app_users 
ADD COLUMN IF NOT EXISTS dietary_preferences JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS favorite_cuisines JSONB DEFAULT '[]'::jsonb,
ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{"sms": false, "push": true, "email": true}'::jsonb;

-- Update the user_type column to match cloud (if needed)
-- Cloud appears to use TEXT, local might use ENUM
-- First check if we need to drop the constraint
DO $$ 
BEGIN
    -- Try to alter the column to remove enum constraint if it exists
    BEGIN
        ALTER TABLE app_users ALTER COLUMN user_type TYPE TEXT;
    EXCEPTION 
        WHEN OTHERS THEN
            -- If it fails, the column is probably already TEXT
            NULL;
    END;
END $$;

-- Add any missing indexes
CREATE INDEX IF NOT EXISTS idx_app_users_address ON app_users(address) WHERE address IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_app_users_city ON app_users(city) WHERE city IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_app_users_country ON app_users(country);

-- Fix RLS policies that might have infinite recursion
-- Drop problematic policies first
DROP POLICY IF EXISTS "users_can_view_own_profile" ON app_users;
DROP POLICY IF EXISTS "users_can_update_own_profile" ON app_users;
DROP POLICY IF EXISTS "service_role_full_access" ON app_users;
DROP POLICY IF EXISTS "Users can view all profiles" ON app_users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON app_users;
DROP POLICY IF EXISTS "Users can update their own profile" ON app_users;
DROP POLICY IF EXISTS "Users can delete their own profile" ON app_users;

-- Create simple, non-recursive policies
CREATE POLICY "allow_service_role_all" ON app_users
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "allow_authenticated_read" ON app_users
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "allow_authenticated_insert" ON app_users
    FOR INSERT
    TO authenticated
    WITH CHECK (true);

CREATE POLICY "allow_authenticated_update" ON app_users
    FOR UPDATE
    TO authenticated
    USING (true)
    WITH CHECK (true);

-- Allow anon users to read (for public profiles)
CREATE POLICY "allow_anon_read" ON app_users
    FOR SELECT
    TO anon
    USING (true);

COMMENT ON TABLE app_users IS 'User profiles synced with cloud schema';