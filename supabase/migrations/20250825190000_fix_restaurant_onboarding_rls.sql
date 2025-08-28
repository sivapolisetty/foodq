-- Fix RLS policies for restaurant_onboarding_requests table
-- This migration ensures authenticated users can insert their own restaurant onboarding requests

-- Drop existing policies to recreate them
DROP POLICY IF EXISTS "Users can view own applications" ON restaurant_onboarding_requests;
DROP POLICY IF EXISTS "Users can insert own applications" ON restaurant_onboarding_requests;
DROP POLICY IF EXISTS "Users can update own pending applications" ON restaurant_onboarding_requests;
DROP POLICY IF EXISTS "Admins can view all applications" ON restaurant_onboarding_requests;
DROP POLICY IF EXISTS "Admins can update all applications" ON restaurant_onboarding_requests;

-- Ensure RLS is enabled
ALTER TABLE restaurant_onboarding_requests ENABLE ROW LEVEL SECURITY;

-- Policy 1: Users can view their own applications
CREATE POLICY "Users can view own applications" 
ON restaurant_onboarding_requests
FOR SELECT 
USING (
    user_id = auth.uid() OR
    user_id::text = (auth.jwt() ->> 'sub')
);

-- Policy 2: Authenticated users can insert their own applications
-- This is the critical policy that was failing
CREATE POLICY "Users can insert own applications" 
ON restaurant_onboarding_requests
FOR INSERT 
WITH CHECK (
    -- Allow if the user_id matches the authenticated user
    user_id = auth.uid() OR
    -- Also check JWT sub claim for compatibility
    user_id::text = (auth.jwt() ->> 'sub') OR
    -- Allow if user is authenticated (for cases where user_id is being set in the insert)
    (auth.uid() IS NOT NULL AND user_id = auth.uid())
);

-- Policy 3: Users can update their own pending/rejected applications
CREATE POLICY "Users can update own pending applications" 
ON restaurant_onboarding_requests
FOR UPDATE 
USING (
    (user_id = auth.uid() OR user_id::text = (auth.jwt() ->> 'sub')) 
    AND status IN ('pending', 'rejected')
);

-- Policy 4: Service role can do everything (for API endpoints)
CREATE POLICY "Service role full access" 
ON restaurant_onboarding_requests
FOR ALL 
USING (
    auth.jwt() ->> 'role' = 'service_role'
);

-- Policy 5: Admins can view all applications
CREATE POLICY "Admins can view all applications" 
ON restaurant_onboarding_requests
FOR SELECT 
USING (
    EXISTS (
        SELECT 1 FROM app_users 
        WHERE id = auth.uid() 
        AND user_type = 'admin'
    )
);

-- Policy 6: Admins can update all applications
CREATE POLICY "Admins can update all applications" 
ON restaurant_onboarding_requests
FOR UPDATE 
USING (
    EXISTS (
        SELECT 1 FROM app_users 
        WHERE id = auth.uid() 
        AND user_type = 'admin'
    )
);

-- Also ensure the user can see their own user record for the foreign key
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;

-- If policies don't exist for app_users, create basic ones
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'app_users' 
        AND policyname = 'Users can view own profile'
    ) THEN
        CREATE POLICY "Users can view own profile" 
        ON app_users 
        FOR SELECT 
        USING (
            id = auth.uid() OR 
            id::text = (auth.jwt() ->> 'sub')
        );
    END IF;
    
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'app_users' 
        AND policyname = 'Service role can view all'
    ) THEN
        CREATE POLICY "Service role can view all" 
        ON app_users 
        FOR ALL 
        USING (auth.jwt() ->> 'role' = 'service_role');
    END IF;
END $$;

-- Add missing columns if they don't exist
DO $$
BEGIN
    -- Check and add city column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='restaurant_onboarding_requests' 
                   AND column_name='city') THEN
        ALTER TABLE restaurant_onboarding_requests ADD COLUMN city VARCHAR(100);
    END IF;
    
    -- Check and add state column if missing
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name='restaurant_onboarding_requests' 
                   AND column_name='state') THEN
        ALTER TABLE restaurant_onboarding_requests ADD COLUMN state VARCHAR(100);
    END IF;
END $$;

-- Grant necessary permissions
GRANT ALL ON restaurant_onboarding_requests TO authenticated;
GRANT ALL ON restaurant_onboarding_requests TO service_role;