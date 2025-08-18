-- Enhance user profiles with addresses and comprehensive business information
-- This migration adds address fields for both customer and business users
-- and enhances business profiles with additional important fields

-- Add address fields to app_users table
ALTER TABLE app_users 
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS city VARCHAR(100),
ADD COLUMN IF NOT EXISTS state VARCHAR(50),
ADD COLUMN IF NOT EXISTS postal_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS country VARCHAR(50) DEFAULT 'United States',
ADD COLUMN IF NOT EXISTS latitude DECIMAL(10, 8),
ADD COLUMN IF NOT EXISTS longitude DECIMAL(11, 8);

-- Add business-specific fields to app_users table for business users
ALTER TABLE app_users
ADD COLUMN IF NOT EXISTS business_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS business_license VARCHAR(100),
ADD COLUMN IF NOT EXISTS tax_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS business_category VARCHAR(100),
ADD COLUMN IF NOT EXISTS business_description TEXT,
ADD COLUMN IF NOT EXISTS business_website VARCHAR(255),
ADD COLUMN IF NOT EXISTS business_hours JSONB,
ADD COLUMN IF NOT EXISTS delivery_radius INTEGER DEFAULT 5,
ADD COLUMN IF NOT EXISTS min_order_amount DECIMAL(10, 2),
ADD COLUMN IF NOT EXISTS accepts_cash BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS accepts_cards BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS accepts_digital BOOLEAN DEFAULT false;

-- Add customer preferences fields
ALTER TABLE app_users
ADD COLUMN IF NOT EXISTS dietary_preferences TEXT[],
ADD COLUMN IF NOT EXISTS favorite_cuisines TEXT[],
ADD COLUMN IF NOT EXISTS notification_preferences JSONB DEFAULT '{"email": true, "push": true, "sms": false}'::jsonb;

-- Update businesses table to sync with enhanced user data
ALTER TABLE businesses
ADD COLUMN IF NOT EXISTS city VARCHAR(100),
ADD COLUMN IF NOT EXISTS state VARCHAR(50),
ADD COLUMN IF NOT EXISTS postal_code VARCHAR(20),
ADD COLUMN IF NOT EXISTS country VARCHAR(50) DEFAULT 'United States',
ADD COLUMN IF NOT EXISTS tax_id VARCHAR(50),
ADD COLUMN IF NOT EXISTS business_license VARCHAR(100),
ADD COLUMN IF NOT EXISTS min_order_amount DECIMAL(10, 2),
ADD COLUMN IF NOT EXISTS delivery_radius INTEGER DEFAULT 5,
ADD COLUMN IF NOT EXISTS accepts_cash BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS accepts_cards BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS accepts_digital BOOLEAN DEFAULT false;

-- Create function to sync business data between users and businesses tables
CREATE OR REPLACE FUNCTION sync_business_data()
RETURNS TRIGGER AS $$
BEGIN
    -- If this is a business user with address, update or create corresponding business record
    IF NEW.user_type = 'business' AND NEW.business_id IS NOT NULL AND NEW.address IS NOT NULL THEN
        INSERT INTO businesses (
            id,
            name,
            description,
            address,
            city,
            state,
            postal_code,
            country,
            latitude,
            longitude,
            phone,
            email,
            website,
            cuisine_type,
            opening_hours,
            tax_id,
            business_license,
            min_order_amount,
            delivery_radius,
            accepts_cash,
            accepts_cards,
            accepts_digital,
            is_active,
            created_at,
            updated_at
        ) VALUES (
            NEW.business_id,
            NEW.name,
            COALESCE(NEW.business_description, ''),
            NEW.address,
            NEW.city,
            NEW.state,
            NEW.postal_code,
            COALESCE(NEW.country, 'United States'),
            NEW.latitude,
            NEW.longitude,
            NEW.phone,
            NEW.email,
            NEW.business_website,
            NEW.business_category,
            NEW.business_hours,
            NEW.tax_id,
            NEW.business_license,
            NEW.min_order_amount,
            COALESCE(NEW.delivery_radius, 5),
            COALESCE(NEW.accepts_cash, true),
            COALESCE(NEW.accepts_cards, true),
            COALESCE(NEW.accepts_digital, false),
            true,
            NOW(),
            NOW()
        )
        ON CONFLICT (id) DO UPDATE SET
            name = EXCLUDED.name,
            description = EXCLUDED.description,
            address = EXCLUDED.address,
            city = EXCLUDED.city,
            state = EXCLUDED.state,
            postal_code = EXCLUDED.postal_code,
            country = EXCLUDED.country,
            latitude = EXCLUDED.latitude,
            longitude = EXCLUDED.longitude,
            phone = EXCLUDED.phone,
            email = EXCLUDED.email,
            website = EXCLUDED.website,
            cuisine_type = EXCLUDED.cuisine_type,
            opening_hours = EXCLUDED.opening_hours,
            tax_id = EXCLUDED.tax_id,
            business_license = EXCLUDED.business_license,
            min_order_amount = EXCLUDED.min_order_amount,
            delivery_radius = EXCLUDED.delivery_radius,
            accepts_cash = EXCLUDED.accepts_cash,
            accepts_cards = EXCLUDED.accepts_cards,
            accepts_digital = EXCLUDED.accepts_digital,
            updated_at = NOW();
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically sync business data
DROP TRIGGER IF EXISTS sync_business_data_trigger ON app_users;
CREATE TRIGGER sync_business_data_trigger
    AFTER INSERT OR UPDATE ON app_users
    FOR EACH ROW
    EXECUTE FUNCTION sync_business_data();

-- Add indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_app_users_location ON app_users USING gist (point(longitude, latitude));
CREATE INDEX IF NOT EXISTS idx_app_users_business_category ON app_users (business_category);
CREATE INDEX IF NOT EXISTS idx_app_users_city_state ON app_users (city, state);
CREATE INDEX IF NOT EXISTS idx_businesses_location ON businesses USING gist (point(longitude, latitude));

-- Add constraints for data validation
ALTER TABLE app_users
ADD CONSTRAINT check_business_fields 
CHECK (
    (user_type = 'business' AND business_id IS NOT NULL) OR 
    (user_type = 'customer' AND business_id IS NULL)
);

ALTER TABLE app_users
ADD CONSTRAINT check_coordinates 
CHECK (
    (latitude IS NULL AND longitude IS NULL) OR 
    (latitude BETWEEN -90 AND 90 AND longitude BETWEEN -180 AND 180)
);

-- Update existing business users to populate business_name from businesses table
UPDATE app_users 
SET business_name = b.name
FROM businesses b 
WHERE app_users.business_id = b.id 
AND app_users.user_type = 'business' 
AND app_users.business_name IS NULL;

-- Add comments for documentation
COMMENT ON COLUMN app_users.address IS 'Street address for user (required for both customers and businesses)';
COMMENT ON COLUMN app_users.city IS 'City name';
COMMENT ON COLUMN app_users.state IS 'State or province';
COMMENT ON COLUMN app_users.postal_code IS 'ZIP code or postal code';
COMMENT ON COLUMN app_users.country IS 'Country name, defaults to United States';
COMMENT ON COLUMN app_users.latitude IS 'Latitude coordinate for location-based services';
COMMENT ON COLUMN app_users.longitude IS 'Longitude coordinate for location-based services';
COMMENT ON COLUMN app_users.business_license IS 'Business license number (business users only)';
COMMENT ON COLUMN app_users.tax_id IS 'Tax identification number (business users only)';
COMMENT ON COLUMN app_users.business_category IS 'Category of business (e.g., Restaurant, Cafe, Fast Food)';
COMMENT ON COLUMN app_users.business_description IS 'Detailed description of the business';
COMMENT ON COLUMN app_users.business_website IS 'Business website URL';
COMMENT ON COLUMN app_users.business_hours IS 'Business operating hours in JSON format';
COMMENT ON COLUMN app_users.delivery_radius IS 'Delivery radius in miles (business users only)';
COMMENT ON COLUMN app_users.min_order_amount IS 'Minimum order amount in dollars (business users only)';
COMMENT ON COLUMN app_users.dietary_preferences IS 'Customer dietary preferences (vegetarian, vegan, etc.)';
COMMENT ON COLUMN app_users.favorite_cuisines IS 'Customer favorite cuisine types';
COMMENT ON COLUMN app_users.notification_preferences IS 'User notification preferences in JSON format';