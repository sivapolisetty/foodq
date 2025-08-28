-- Seed local database with production user for development
-- This allows production JWT tokens to work with local database

-- Insert user if not exists (using app_users table which is correct)
INSERT INTO app_users (
    id,
    name,
    email,
    user_type,
    profile_image_url,
    created_at,
    updated_at,
    country
) VALUES (
    'f0337be4-1399-4363-8652-3534df397078',
    'SIVA POLISETTY',
    'sivapolisetty813@gmail.com',
    'business',
    'https://lh3.googleusercontent.com/a/ACg8ocICkIYgiBdk44793A2W71JLHDghorMem3v6k6VqK2zbgz9vtQ=s96-c',
    NOW(),
    NOW(),
    'United States'
) ON CONFLICT (id) DO NOTHING;

-- Insert a sample restaurant onboarding request if needed
INSERT INTO restaurant_onboarding_requests (
    id,
    restaurant_name,
    cuisine_type,
    restaurant_description,
    owner_name,
    owner_email,
    owner_phone,
    address,
    zip_code,
    latitude,
    longitude,
    status,
    user_id,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'Test Restaurant',
    'American',
    'A test restaurant for local development',
    'Siva',
    'sivapolisetty813@gmail.com',
    '5517958785',
    'Test Address',
    '20171',
    0,
    0,
    'pending',
    'f0337be4-1399-4363-8652-3534df397078',
    NOW(),
    NOW()
) ON CONFLICT DO NOTHING;