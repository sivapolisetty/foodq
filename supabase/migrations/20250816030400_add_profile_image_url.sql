-- Add profile_image_url column to app_users table
ALTER TABLE app_users ADD COLUMN IF NOT EXISTS profile_image_url TEXT;

-- Grant necessary permissions
GRANT ALL PRIVILEGES ON TABLE app_users TO service_role;
GRANT ALL PRIVILEGES ON TABLE app_users TO authenticated;
GRANT SELECT ON TABLE app_users TO anon;

-- Force schema reload
NOTIFY pgrst, 'reload schema';