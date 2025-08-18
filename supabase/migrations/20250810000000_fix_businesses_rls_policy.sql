-- Fix RLS policies for businesses table to allow authenticated users to create and manage their own business profiles

-- First, check if businesses table has owner_id column, if not add it
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='businesses' AND column_name='owner_id') THEN
        ALTER TABLE businesses ADD COLUMN owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE;
    END IF;
END $$;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view businesses" ON businesses;
DROP POLICY IF EXISTS "Users can insert their own business" ON businesses;  
DROP POLICY IF EXISTS "Users can update their own business" ON businesses;
DROP POLICY IF EXISTS "Users can delete their own business" ON businesses;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON businesses;
DROP POLICY IF EXISTS "Enable read access for all users" ON businesses;
DROP POLICY IF EXISTS "Enable update for business owners only" ON businesses;
DROP POLICY IF EXISTS "Enable delete for business owners only" ON businesses;

-- Enable RLS on businesses table
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;

-- Policy: Allow anyone to view businesses (public visibility)
CREATE POLICY "Users can view businesses" ON businesses
    FOR SELECT USING (true);

-- Policy: Allow authenticated users to create businesses
CREATE POLICY "Users can insert their own business" ON businesses
    FOR INSERT 
    WITH CHECK (auth.uid() IS NOT NULL);

-- Policy: Allow users to update their own business (if owner_id matches)
CREATE POLICY "Users can update their own business" ON businesses
    FOR UPDATE 
    USING (owner_id IS NULL OR auth.uid() = owner_id)
    WITH CHECK (owner_id IS NULL OR auth.uid() = owner_id);

-- Policy: Allow users to delete their own business (if owner_id matches)  
CREATE POLICY "Users can delete their own business" ON businesses
    FOR DELETE 
    USING (owner_id IS NULL OR auth.uid() = owner_id);

-- Also ensure app_users table has proper RLS policies
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

-- Policy: Allow anyone to view user profiles (needed for business listings)
CREATE POLICY "Users can view all profiles" ON app_users
    FOR SELECT USING (true);

-- Policy: Allow authenticated users to create their own profile
CREATE POLICY "Users can insert their own profile" ON app_users
    FOR INSERT 
    WITH CHECK (auth.uid() = id);

-- Policy: Allow users to update their own profile
CREATE POLICY "Users can update their own profile" ON app_users
    FOR UPDATE 
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Policy: Allow users to delete their own profile
CREATE POLICY "Users can delete their own profile" ON app_users
    FOR DELETE 
    USING (auth.uid() = id);