-- Fix RLS policies for local development
-- This ensures app_users table has proper RLS policies matching production

-- Enable RLS on app_users table
ALTER TABLE app_users ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view all profiles" ON app_users;
DROP POLICY IF EXISTS "Users can insert their own profile" ON app_users;
DROP POLICY IF EXISTS "Users can update their own profile" ON app_users;
DROP POLICY IF EXISTS "Users can delete their own profile" ON app_users;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON app_users;
DROP POLICY IF EXISTS "Enable read access for all users" ON app_users;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON app_users;
DROP POLICY IF EXISTS "Enable delete for users based on user_id" ON app_users;

-- Create comprehensive RLS policies for app_users
-- Allow authenticated users to read all profiles
CREATE POLICY "Users can view all profiles" ON app_users
    FOR SELECT USING (auth.role() = 'authenticated');

-- Allow authenticated users to insert their own profile
CREATE POLICY "Users can insert their own profile" ON app_users
    FOR INSERT WITH CHECK (auth.uid()::text = id::text);

-- Allow users to update their own profile
CREATE POLICY "Users can update their own profile" ON app_users
    FOR UPDATE USING (auth.uid()::text = id::text);

-- Allow users to delete their own profile
CREATE POLICY "Users can delete their own profile" ON app_users
    FOR DELETE USING (auth.uid()::text = id::text);

-- Additional policy for service role access
CREATE POLICY "Service role can do anything" ON app_users
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Ensure businesses table also has proper policies
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view businesses" ON businesses;
DROP POLICY IF EXISTS "Users can insert their own business" ON businesses;
DROP POLICY IF EXISTS "Users can update their own business" ON businesses;
DROP POLICY IF EXISTS "Users can delete their own business" ON businesses;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON businesses;
DROP POLICY IF EXISTS "Enable read access for all users" ON businesses;
DROP POLICY IF EXISTS "Enable update for business owners only" ON businesses;
DROP POLICY IF EXISTS "Enable delete for business owners only" ON businesses;

-- Create RLS policies for businesses
CREATE POLICY "Users can view all businesses" ON businesses
    FOR SELECT USING (true);

-- Allow authenticated users to insert businesses
CREATE POLICY "Users can insert businesses" ON businesses
    FOR INSERT TO authenticated WITH CHECK (true);

-- Allow business owners to update their businesses
CREATE POLICY "Users can update their own business" ON businesses
    FOR UPDATE USING (auth.uid()::text = owner_id::text);

-- Allow business owners to delete their businesses
CREATE POLICY "Users can delete their own business" ON businesses
    FOR DELETE USING (auth.uid()::text = owner_id::text);

-- Service role access
CREATE POLICY "Service role can do anything on businesses" ON businesses
    USING (auth.role() = 'service_role')
    WITH CHECK (auth.role() = 'service_role');

-- Grant usage on sequences
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO authenticated;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO service_role;