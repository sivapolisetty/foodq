-- KraveKart Deal Management Database Schema
-- Run this in your Supabase SQL Editor

-- Create businesses table
CREATE TABLE IF NOT EXISTS businesses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    owner_id UUID NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    email VARCHAR(255),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create deals table
CREATE TABLE IF NOT EXISTS deals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    original_price DECIMAL(10, 2) NOT NULL,
    discounted_price DECIMAL(10, 2) NOT NULL,
    discount_percentage INTEGER NOT NULL,
    business_id UUID NOT NULL REFERENCES businesses(id) ON DELETE CASCADE,
    image_url TEXT,
    is_active BOOLEAN DEFAULT true,
    valid_from TIMESTAMP DEFAULT NOW(),
    valid_until TIMESTAMP NOT NULL,
    terms_conditions TEXT,
    max_redemptions INTEGER DEFAULT 0, -- 0 means unlimited
    current_redemptions INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    CONSTRAINT deals_business_fk FOREIGN KEY (business_id) REFERENCES businesses(id)
);

-- Create deal categories table
CREATE TABLE IF NOT EXISTS deal_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    icon_url TEXT,
    color_code VARCHAR(7) DEFAULT '#2E7D32', -- Yindii green
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create deal_category_mapping table (many-to-many)
CREATE TABLE IF NOT EXISTS deal_category_mapping (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deal_id UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES deal_categories(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(deal_id, category_id)
);

-- Create deal redemptions table (for tracking customer usage)
CREATE TABLE IF NOT EXISTS deal_redemptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    deal_id UUID NOT NULL REFERENCES deals(id) ON DELETE CASCADE,
    customer_id UUID NOT NULL,
    redeemed_at TIMESTAMP DEFAULT NOW(),
    redemption_code VARCHAR(50) UNIQUE,
    status VARCHAR(20) DEFAULT 'active', -- active, used, expired
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_deals_business_id ON deals(business_id);
CREATE INDEX IF NOT EXISTS idx_deals_active ON deals(is_active);
CREATE INDEX IF NOT EXISTS idx_deals_valid_dates ON deals(valid_from, valid_until);
CREATE INDEX IF NOT EXISTS idx_businesses_owner_id ON businesses(owner_id);
CREATE INDEX IF NOT EXISTS idx_businesses_active ON businesses(is_active);
CREATE INDEX IF NOT EXISTS idx_deal_redemptions_deal_id ON deal_redemptions(deal_id);
CREATE INDEX IF NOT EXISTS idx_deal_redemptions_customer_id ON deal_redemptions(customer_id);

-- Insert default categories
INSERT INTO deal_categories (name, icon_url, color_code) VALUES
('Food & Dining', 'https://example.com/icons/food.png', '#FF6B35'),
('Shopping', 'https://example.com/icons/shopping.png', '#2E7D32'),
('Entertainment', 'https://example.com/icons/entertainment.png', '#9C27B0'),
('Health & Beauty', 'https://example.com/icons/health.png', '#00BCD4'),
('Services', 'https://example.com/icons/services.png', '#FF9800'),
('Travel', 'https://example.com/icons/travel.png', '#3F51B5')
ON CONFLICT (name) DO NOTHING;

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for updated_at
CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON businesses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_deals_updated_at BEFORE UPDATE ON deals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create RLS (Row Level Security) policies
ALTER TABLE businesses ENABLE ROW LEVEL SECURITY;
ALTER TABLE deals ENABLE ROW LEVEL SECURITY;
ALTER TABLE deal_redemptions ENABLE ROW LEVEL SECURITY;

-- Businesses policies
CREATE POLICY "Business owners can manage their businesses" ON businesses
    FOR ALL USING (auth.uid() = owner_id);

CREATE POLICY "Anyone can view active businesses" ON businesses
    FOR SELECT USING (is_active = true);

-- Deals policies  
CREATE POLICY "Business owners can manage deals for their businesses" ON deals
    FOR ALL USING (
        business_id IN (
            SELECT id FROM businesses WHERE owner_id = auth.uid()
        )
    );

CREATE POLICY "Anyone can view active deals" ON deals
    FOR SELECT USING (is_active = true AND valid_from <= NOW() AND valid_until >= NOW());

-- Deal redemptions policies
CREATE POLICY "Customers can view their redemptions" ON deal_redemptions
    FOR SELECT USING (customer_id = auth.uid());

CREATE POLICY "Business owners can view redemptions for their deals" ON deal_redemptions
    FOR SELECT USING (
        deal_id IN (
            SELECT d.id FROM deals d
            JOIN businesses b ON d.business_id = b.id
            WHERE b.owner_id = auth.uid()
        )
    );

-- Grant necessary permissions
GRANT ALL ON businesses TO authenticated;
GRANT ALL ON deals TO authenticated;
GRANT ALL ON deal_categories TO authenticated;
GRANT ALL ON deal_category_mapping TO authenticated;
GRANT ALL ON deal_redemptions TO authenticated;

GRANT SELECT ON deal_categories TO anon;
GRANT SELECT ON businesses TO anon;
GRANT SELECT ON deals TO anon;