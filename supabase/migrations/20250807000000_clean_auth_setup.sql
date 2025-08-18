-- Clean Authentication Setup for KraveKart
-- This migration sets up a complete authentication system with Google OAuth and Magic Links

-- Drop existing auth-related tables and start clean
DROP TABLE IF EXISTS app_users CASCADE;

-- Create user_type enum if it doesn't exist
DO $$ BEGIN
    CREATE TYPE user_type AS ENUM ('customer', 'business', 'admin');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- Create app_users table with OAuth support
CREATE TABLE app_users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    name TEXT NOT NULL,
    user_type user_type DEFAULT 'customer'::user_type,
    provider TEXT DEFAULT 'email',
    avatar_url TEXT,
    phone TEXT,
    business_id UUID REFERENCES businesses(id) ON DELETE SET NULL,
    email_verified BOOLEAN DEFAULT FALSE,
    last_sign_in_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX idx_app_users_email ON app_users(email);
CREATE INDEX idx_app_users_user_type ON app_users(user_type);
CREATE INDEX idx_app_users_provider ON app_users(provider);
CREATE INDEX idx_app_users_business_id ON app_users(business_id) WHERE business_id IS NOT NULL;

-- Enable RLS (Row Level Security)
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can view their own profile
CREATE POLICY "users_can_view_own_profile" ON app_users
    FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "users_can_update_own_profile" ON app_users
    FOR UPDATE
    USING (auth.uid() = id);

-- Service role and admins have full access
CREATE POLICY "service_role_full_access" ON app_users
    FOR ALL
    USING (
        auth.jwt() ->> 'role' = 'service_role' OR
        (auth.uid() IS NOT NULL AND EXISTS (
            SELECT 1 FROM app_users u 
            WHERE u.id = auth.uid() AND u.user_type = 'admin'
        ))
    );

-- Function to handle new user registration
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
    user_name TEXT;
    user_provider TEXT;
BEGIN
    -- Extract name from metadata or email
    user_name := COALESCE(
        new.raw_user_meta_data->>'name',
        new.raw_user_meta_data->>'full_name',
        SPLIT_PART(new.email, '@', 1)
    );
    
    -- Determine provider from metadata
    user_provider := COALESCE(
        new.raw_user_meta_data->>'provider',
        CASE 
            WHEN new.raw_user_meta_data ? 'iss' AND new.raw_user_meta_data->>'iss' LIKE '%google%' THEN 'google'
            WHEN new.app_metadata ? 'provider' THEN new.app_metadata->>'provider'
            ELSE 'email'
        END
    );

    -- Insert or update app_users record
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
        user_name,
        COALESCE(new.raw_user_meta_data->>'user_type', 'customer')::user_type,
        user_provider,
        new.raw_user_meta_data->>'avatar_url',
        COALESCE(new.email_confirmed_at IS NOT NULL, FALSE),
        new.created_at,
        new.created_at,
        new.last_sign_in_at
    )
    ON CONFLICT (id) DO UPDATE
    SET 
        email = EXCLUDED.email,
        name = COALESCE(EXCLUDED.name, app_users.name),
        avatar_url = COALESCE(EXCLUDED.avatar_url, app_users.avatar_url),
        email_verified = EXCLUDED.email_verified,
        last_sign_in_at = EXCLUDED.last_sign_in_at,
        updated_at = NOW();
    
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT OR UPDATE ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to update last sign in timestamp
CREATE OR REPLACE FUNCTION public.update_user_last_sign_in()
RETURNS trigger AS $$
BEGIN
    -- Only update if last_sign_in_at changed and user exists in app_users
    IF (OLD.last_sign_in_at IS DISTINCT FROM NEW.last_sign_in_at) THEN
        UPDATE public.app_users
        SET 
            last_sign_in_at = NEW.last_sign_in_at,
            updated_at = NOW()
        WHERE id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for sign in tracking
DROP TRIGGER IF EXISTS on_auth_user_sign_in ON auth.users;
CREATE TRIGGER on_auth_user_sign_in
    AFTER UPDATE OF last_sign_in_at ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.update_user_last_sign_in();

-- Function to promote user to business owner
CREATE OR REPLACE FUNCTION public.promote_to_business_owner(
    user_id UUID,
    restaurant_id UUID
)
RETURNS VOID AS $$
BEGIN
    UPDATE app_users
    SET 
        user_type = 'business',
        business_id = restaurant_id,
        updated_at = NOW()
    WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON app_users TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.handle_new_user() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.update_user_last_sign_in() TO anon, authenticated;
GRANT EXECUTE ON FUNCTION public.promote_to_business_owner(UUID, UUID) TO authenticated;

-- Create a view for user profiles with computed fields
CREATE OR REPLACE VIEW user_profiles AS
SELECT 
    id,
    email,
    name,
    user_type,
    provider,
    avatar_url,
    phone,
    business_id,
    email_verified,
    CASE 
        WHEN user_type = 'business' THEN TRUE
        ELSE FALSE
    END as is_business,
    CASE 
        WHEN user_type = 'admin' THEN TRUE
        ELSE FALSE
    END as is_admin,
    last_sign_in_at,
    created_at,
    updated_at
FROM app_users;

-- Grant access to the view
GRANT SELECT ON user_profiles TO anon, authenticated;

-- Add RLS to the view (inherits from base table)
ALTER VIEW user_profiles SET (security_invoker = true);

COMMENT ON TABLE app_users IS 'User profiles with authentication provider support';
COMMENT ON COLUMN app_users.provider IS 'Authentication provider: email, google, magic_link';
COMMENT ON COLUMN app_users.user_type IS 'User role: customer, business, admin';
COMMENT ON COLUMN app_users.business_id IS 'Reference to business for business owners';
COMMENT ON VIEW user_profiles IS 'User profiles with computed helper fields';