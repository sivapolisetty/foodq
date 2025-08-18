-- Restaurant Onboarding Request Schema
-- This table stores restaurant partnership applications pending admin approval

CREATE TABLE IF NOT EXISTS restaurant_onboarding_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Restaurant Information
    restaurant_name VARCHAR(255) NOT NULL,
    cuisine_type VARCHAR(100) NOT NULL,
    restaurant_description TEXT,
    restaurant_photo_url TEXT,
    
    -- Owner Information  
    owner_name VARCHAR(255) NOT NULL,
    owner_email VARCHAR(255) NOT NULL,
    owner_phone VARCHAR(50) NOT NULL,
    
    -- Location Information
    address TEXT NOT NULL,
    zip_code VARCHAR(20) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    
    -- Business Information
    business_license VARCHAR(255),
    
    -- Application Status
    status VARCHAR(50) DEFAULT 'pending' CHECK (status IN ('pending', 'under_review', 'approved', 'rejected')),
    admin_notes TEXT,
    
    -- User Reference
    user_id UUID REFERENCES app_users(id) ON DELETE CASCADE,
    
    -- Timestamps
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    reviewed_at TIMESTAMPTZ,
    
    -- Restaurant reference (populated when approved)
    restaurant_id UUID REFERENCES businesses(id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_restaurant_onboarding_status ON restaurant_onboarding_requests(status);
CREATE INDEX IF NOT EXISTS idx_restaurant_onboarding_user_id ON restaurant_onboarding_requests(user_id);
CREATE INDEX IF NOT EXISTS idx_restaurant_onboarding_created_at ON restaurant_onboarding_requests(created_at);

-- Updated timestamp trigger
CREATE OR REPLACE FUNCTION update_restaurant_onboarding_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER trigger_update_restaurant_onboarding_updated_at
    BEFORE UPDATE ON restaurant_onboarding_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_restaurant_onboarding_updated_at();

-- RLS Policies
ALTER TABLE restaurant_onboarding_requests ENABLE ROW LEVEL SECURITY;

-- Users can view and insert their own applications
CREATE POLICY "Users can view own applications" ON restaurant_onboarding_requests
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can insert own applications" ON restaurant_onboarding_requests
    FOR INSERT WITH CHECK (user_id = auth.uid());

-- Users can update their own pending/rejected applications
CREATE POLICY "Users can update own pending applications" ON restaurant_onboarding_requests
    FOR UPDATE USING (user_id = auth.uid() AND status IN ('pending', 'rejected'));

-- Admins can view and update all applications
CREATE POLICY "Admins can view all applications" ON restaurant_onboarding_requests
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM app_users 
            WHERE id = auth.uid() 
            AND user_type = 'admin'
        )
    );

CREATE POLICY "Admins can update all applications" ON restaurant_onboarding_requests
    FOR UPDATE USING (
        EXISTS (
            SELECT 1 FROM app_users 
            WHERE id = auth.uid() 
            AND user_type = 'admin'
        )
    );

-- Sample data will be inserted after migration is successful
-- Using valid user IDs from existing app_users table
DO $$
DECLARE
    user1_id UUID;
    user2_id UUID;
    user3_id UUID;
BEGIN
    -- Get some existing user IDs
    SELECT id INTO user1_id FROM app_users WHERE user_type = 'customer' LIMIT 1 OFFSET 0;
    SELECT id INTO user2_id FROM app_users WHERE user_type = 'customer' LIMIT 1 OFFSET 1;
    SELECT id INTO user3_id FROM app_users WHERE user_type = 'customer' LIMIT 1 OFFSET 2;
    
    -- Only insert if users exist
    IF user1_id IS NOT NULL AND user2_id IS NOT NULL AND user3_id IS NOT NULL THEN
        INSERT INTO restaurant_onboarding_requests (
            restaurant_name,
            cuisine_type,
            restaurant_description,
            owner_name,
            owner_email,
            owner_phone,
            address,
            zip_code,
            business_license,
            user_id,
            status
        ) VALUES 
        (
            'Spice Garden Indian Restaurant',
            'North Indian',
            'Authentic North Indian cuisine with traditional tandoor specialties and aromatic curries.',
            'Raj Kumar',
            'raj@spicegarden.com',
            '+1-555-SPICE-01',
            '123 Curry Lane, Spice District, NY',
            '10001',
            'BL-SPICE-2024-001',
            user1_id,
            'pending'
        ),
        (
            'Mama Mia Pizzeria',
            'Italian',
            'Family-owned Italian restaurant serving wood-fired pizzas and homemade pasta since 1985.',
            'Giuseppe Romano',
            'giuseppe@mamamia.com',
            '+1-555-PIZZA-02',
            '456 Pizza Boulevard, Little Italy, NY', 
            '10002',
            'BL-PIZZA-2024-002',
            user2_id,
            'under_review'
        ),
        (
            'Dragon Palace Chinese',
            'Chinese',
            'Szechuan and Cantonese dishes with fresh ingredients and traditional cooking methods.',
            'Li Wei Chen',
            'li@dragonpalace.com',
            '+1-555-DRAGON-03',
            '789 Dragon Street, Chinatown, NY',
            '10003',
            'BL-CHINESE-2024-003',
            user3_id,
            'approved'
        );
    END IF;
END $$;

-- Comment for documentation
COMMENT ON TABLE restaurant_onboarding_requests IS 'Stores restaurant partnership applications pending admin approval';
COMMENT ON COLUMN restaurant_onboarding_requests.status IS 'Application status: pending, under_review, approved, rejected';
COMMENT ON COLUMN restaurant_onboarding_requests.admin_notes IS 'Notes from admin during review process';