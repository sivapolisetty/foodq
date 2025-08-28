-- Create or update the business user mapping
-- This ensures the test business user is properly associated with Mario's Pizza

-- First, ensure the business exists with the correct owner
UPDATE businesses 
SET owner_id = 'f0337be4-1399-4363-8652-3534df397078',
    is_approved = true,
    onboarding_completed = true,
    updated_at = NOW()
WHERE id = '550e8400-e29b-41d4-a716-446655440001';

-- Create or update the app_user with business association
INSERT INTO app_users (
  id,
  email,
  name,
  user_type,
  business_id,
  profile_image_url,
  created_at,
  updated_at,
  country
) VALUES (
  'f0337be4-1399-4363-8652-3534df397078',
  'sivapolisetty813@gmail.com',
  'SIVA POLISETTY',
  'business',
  '550e8400-e29b-41d4-a716-446655440001',
  'https://lh3.googleusercontent.com/a/ACg8ocICkIYgiBdk44793A2W71JLHDghorMem3v6k6VqK2zbgz9vtQ=s96-c',
  NOW(),
  NOW(),
  'United States'
) ON CONFLICT (id) DO UPDATE SET
  business_id = EXCLUDED.business_id,
  user_type = EXCLUDED.user_type,
  updated_at = NOW();

-- Ensure notification preferences are set
UPDATE app_users 
SET notification_preferences = '{"sms":false,"push":true,"email":true}'::jsonb
WHERE id = 'f0337be4-1399-4363-8652-3534df397078'
AND notification_preferences IS NULL;