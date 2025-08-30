-- Simplify Order Flow to Two States with Verification Codes
-- Migration: 2025-08-29 - Simplified Order States

-- Add new fields for verification system
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS verification_code VARCHAR(6) NOT NULL DEFAULT '',
ADD COLUMN IF NOT EXISTS qr_data TEXT,
ADD COLUMN IF NOT EXISTS confirmed_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS completed_at TIMESTAMPTZ;

-- Update status constraints to only allow simplified states
ALTER TABLE orders 
DROP CONSTRAINT IF EXISTS orders_status_check;

ALTER TABLE orders 
ADD CONSTRAINT orders_status_check 
CHECK (status IN ('confirmed', 'completed', 'cancelled'));

-- Create unique index on verification_code to ensure uniqueness
CREATE UNIQUE INDEX IF NOT EXISTS idx_orders_verification_code 
ON orders(verification_code) WHERE verification_code != '';

-- Create function to generate 6-character verification code
CREATE OR REPLACE FUNCTION generate_verification_code() 
RETURNS VARCHAR(6) AS $$
DECLARE
  chars TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  code VARCHAR(6) := '';
  i INTEGER;
BEGIN
  -- Generate 6-character code
  FOR i IN 1..6 LOOP
    code := code || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
  END LOOP;
  
  -- Ensure uniqueness by checking if code already exists
  WHILE EXISTS (SELECT 1 FROM orders WHERE verification_code = code) LOOP
    code := '';
    FOR i IN 1..6 LOOP
      code := code || substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    END LOOP;
  END LOOP;
  
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-generate verification code on insert
CREATE OR REPLACE FUNCTION set_verification_code()
RETURNS TRIGGER AS $$
BEGIN
  -- Generate verification code if not provided
  IF NEW.verification_code = '' OR NEW.verification_code IS NULL THEN
    NEW.verification_code := generate_verification_code();
  END IF;
  
  -- Set confirmed_at timestamp when status is confirmed
  IF NEW.status = 'confirmed' AND OLD.confirmed_at IS NULL THEN
    NEW.confirmed_at := NOW();
  END IF;
  
  -- Set completed_at timestamp when status changes to completed
  IF NEW.status = 'completed' AND (OLD IS NULL OR OLD.status != 'completed') THEN
    NEW.completed_at := NOW();
  END IF;
  
  -- Generate QR data JSON
  NEW.qr_data := json_build_object(
    'order_id', NEW.id,
    'verification_code', NEW.verification_code,
    'business_id', NEW.business_id,
    'total_amount', NEW.total_amount,
    'created_at', NEW.created_at
  )::text;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_set_verification_code ON orders;
CREATE TRIGGER trigger_set_verification_code
  BEFORE INSERT OR UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION set_verification_code();

-- Update existing orders to have verification codes (for testing)
UPDATE orders 
SET 
  verification_code = generate_verification_code(),
  status = 'confirmed',
  confirmed_at = created_at
WHERE verification_code = '' OR verification_code IS NULL;

-- Create index for faster verification lookups
CREATE INDEX IF NOT EXISTS idx_orders_business_status 
ON orders(business_id, status);

CREATE INDEX IF NOT EXISTS idx_orders_user_status 
ON orders(user_id, status);