-- Add OAuth provider support to app_users table
-- This migration adds fields to track authentication providers and avatar URLs

-- Add provider column to track auth method (email, google, magic_link)
ALTER TABLE app_users 
ADD COLUMN IF NOT EXISTS provider text DEFAULT 'email',
ADD COLUMN IF NOT EXISTS avatar_url text,
ADD COLUMN IF NOT EXISTS email_verified boolean DEFAULT false,
ADD COLUMN IF NOT EXISTS last_sign_in_at timestamptz;

-- Create index on provider for faster queries
CREATE INDEX IF NOT EXISTS idx_app_users_provider ON app_users(provider);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS idx_app_users_email ON app_users(email);

-- Update RLS policies to ensure users can only read/update their own data
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view own profile" ON app_users;
DROP POLICY IF EXISTS "Users can update own profile" ON app_users;
DROP POLICY IF EXISTS "Service role can do anything" ON app_users;

-- Users can view their own profile
CREATE POLICY "Users can view own profile" ON app_users
    FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile" ON app_users
    FOR UPDATE
    USING (auth.uid() = id);

-- Service role has full access (for admin operations)
CREATE POLICY "Service role can do anything" ON app_users
    FOR ALL
    USING (auth.jwt() ->> 'role' = 'service_role');

-- Create function to handle new user creation from auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
    -- Only create app_user if it doesn't exist
    INSERT INTO public.app_users (
        id,
        email,
        name,
        user_type,
        provider,
        avatar_url,
        email_verified,
        created_at,
        updated_at,
        last_sign_in_at
    )
    VALUES (
        new.id,
        new.email,
        COALESCE(new.raw_user_meta_data->>'name', split_part(new.email, '@', 1)),
        COALESCE(new.raw_user_meta_data->>'user_type', 'customer')::user_type,
        COALESCE(new.raw_user_meta_data->>'provider', 'email'),
        new.raw_user_meta_data->>'avatar_url',
        new.email_confirmed_at IS NOT NULL,
        new.created_at,
        new.created_at,
        new.last_sign_in_at
    )
    ON CONFLICT (id) DO UPDATE
    SET 
        last_sign_in_at = EXCLUDED.last_sign_in_at,
        email_verified = EXCLUDED.email_verified,
        updated_at = now();
    
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically create app_users entry when auth.users is created
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Add function to update last sign in
CREATE OR REPLACE FUNCTION public.update_last_sign_in()
RETURNS trigger AS $$
BEGIN
    UPDATE public.app_users
    SET last_sign_in_at = now()
    WHERE id = new.id;
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to update last sign in time
DROP TRIGGER IF EXISTS on_auth_user_signin ON auth.users;
CREATE TRIGGER on_auth_user_signin
    AFTER UPDATE OF last_sign_in_at ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.update_last_sign_in();

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
GRANT ALL ON ALL FUNCTIONS IN SCHEMA public TO anon, authenticated;