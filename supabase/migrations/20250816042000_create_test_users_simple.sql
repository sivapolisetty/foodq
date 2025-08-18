-- Create test user entries directly in app_users for local development
-- These are pre-defined user IDs that can be used when testing locally

-- First remove the foreign key constraint since we can't modify auth schema
ALTER TABLE app_users DROP CONSTRAINT IF EXISTS app_users_id_fkey;

-- Insert test users directly into app_users with known UUIDs
-- These can be used when testing the API locally
INSERT INTO app_users (id, name, email, user_type, created_at, updated_at) VALUES
    ('11111111-1111-1111-1111-111111111111', 'Test Customer 1', 'test.customer1@example.com', 'customer', NOW(), NOW()),
    ('22222222-2222-2222-2222-222222222222', 'Test Customer 2', 'test.customer2@example.com', 'customer', NOW(), NOW()),
    ('33333333-3333-3333-3333-333333333333', 'Test Business 1', 'test.business1@example.com', 'business', NOW(), NOW()),
    ('44444444-4444-4444-4444-444444444444', 'Test Business 2', 'test.business2@example.com', 'business', NOW(), NOW()),
    ('55555555-5555-5555-5555-555555555555', 'Test Admin', 'test.admin@example.com', 'customer', NOW(), NOW())
ON CONFLICT (id) DO NOTHING;

-- Add comment explaining these are test users
COMMENT ON TABLE app_users IS 'Application users table. In hybrid mode, contains test users with known IDs for local development.';

-- Create a helper function to get test user IDs
CREATE OR REPLACE FUNCTION get_test_user_id(user_number INT DEFAULT 1)
RETURNS UUID AS $$
BEGIN
    RETURN CASE user_number
        WHEN 1 THEN '11111111-1111-1111-1111-111111111111'::UUID
        WHEN 2 THEN '22222222-2222-2222-2222-222222222222'::UUID
        WHEN 3 THEN '33333333-3333-3333-3333-333333333333'::UUID
        WHEN 4 THEN '44444444-4444-4444-4444-444444444444'::UUID
        WHEN 5 THEN '55555555-5555-5555-5555-555555555555'::UUID
        ELSE '11111111-1111-1111-1111-111111111111'::UUID
    END;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_test_user_id IS 'Helper function to get test user IDs for local development';