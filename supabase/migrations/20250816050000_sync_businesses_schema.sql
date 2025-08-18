-- Sync businesses table with cloud schema
-- Add missing columns and rename existing ones

-- Add business_hours column (cloud has this, local has opening_hours)
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS business_hours JSONB;

-- Copy data from opening_hours to business_hours if it exists
UPDATE businesses SET business_hours = opening_hours::jsonb WHERE opening_hours IS NOT NULL AND business_hours IS NULL;

-- Add category column (for business category/type)
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS category TEXT;

-- Copy cuisine_type to category if category is null
UPDATE businesses SET category = cuisine_type WHERE cuisine_type IS NOT NULL AND category IS NULL;

-- Add is_approved column for admin approval workflow
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS is_approved BOOLEAN DEFAULT false;

-- Add onboarding_completed column
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT false;

-- Add zip_code as alias for postal_code (some parts of API use zip_code)
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS zip_code TEXT;

-- Copy postal_code to zip_code if needed
UPDATE businesses SET zip_code = postal_code WHERE postal_code IS NOT NULL AND zip_code IS NULL;

-- Add any other missing columns that might be in cloud
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS verified_at TIMESTAMPTZ;
ALTER TABLE businesses ADD COLUMN IF NOT EXISTS verification_status TEXT DEFAULT 'pending';

-- Add comment explaining the column aliases
COMMENT ON COLUMN businesses.business_hours IS 'Business operating hours (JSON format) - alias for opening_hours';
COMMENT ON COLUMN businesses.category IS 'Business category/type - alias for cuisine_type';
COMMENT ON COLUMN businesses.zip_code IS 'Postal/ZIP code - alias for postal_code';

-- Ensure consistent column order won't break anything
COMMENT ON TABLE businesses IS 'Businesses table synced with cloud schema. Some columns have aliases for backward compatibility.';