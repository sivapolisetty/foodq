-- Create missing RPC function for restaurant onboarding requests

-- Create function to get user onboarding requests
CREATE OR REPLACE FUNCTION get_user_onboarding_requests(p_user_id UUID)
RETURNS TABLE (
    id UUID,
    user_id UUID,
    restaurant_id UUID,
    restaurant_name TEXT,
    status TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    owner_name TEXT,
    owner_email TEXT,
    owner_phone TEXT,
    address TEXT,
    cuisine_type TEXT,
    restaurant_description TEXT,
    business_license TEXT,
    restaurant_photo_url TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    zip_code TEXT,
    reviewed_at TIMESTAMPTZ,
    admin_notes TEXT
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT 
        ror.id,
        ror.user_id,
        ror.restaurant_id,
        ror.restaurant_name,
        ror.status,
        ror.created_at,
        ror.updated_at,
        ror.owner_name,
        ror.owner_email,
        ror.owner_phone,
        ror.address,
        ror.cuisine_type,
        ror.restaurant_description,
        ror.business_license,
        ror.restaurant_photo_url,
        ror.latitude,
        ror.longitude,
        ror.zip_code,
        ror.reviewed_at,
        ror.admin_notes
    FROM restaurant_onboarding_requests ror
    WHERE ror.user_id = p_user_id
    ORDER BY ror.created_at DESC;
$$;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION get_user_onboarding_requests(UUID) TO authenticated;
GRANT EXECUTE ON FUNCTION get_user_onboarding_requests(UUID) TO anon;
GRANT EXECUTE ON FUNCTION get_user_onboarding_requests(UUID) TO service_role;

-- Add comment
COMMENT ON FUNCTION get_user_onboarding_requests IS 'Get restaurant onboarding requests for a specific user';