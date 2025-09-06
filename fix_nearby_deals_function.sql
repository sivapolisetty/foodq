-- Drop and recreate the function with correct return types
DROP FUNCTION IF EXISTS get_nearby_deals(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, INTEGER, UUID, TEXT);

-- Create function with flexible return types that match the actual database schema
CREATE OR REPLACE FUNCTION get_nearby_deals(
  user_lat DOUBLE PRECISION,
  user_lng DOUBLE PRECISION,
  radius_meters DOUBLE PRECISION DEFAULT 10000,
  result_limit INTEGER DEFAULT 20,
  business_filter UUID DEFAULT NULL,
  search_term TEXT DEFAULT NULL
)
RETURNS TABLE (
  id UUID,
  business_id UUID,
  title VARCHAR,
  description VARCHAR,
  original_price NUMERIC,
  discounted_price NUMERIC,
  quantity_available INTEGER,
  quantity_sold INTEGER,
  image_url VARCHAR,
  allergen_info VARCHAR,
  expires_at TIMESTAMPTZ,
  status VARCHAR,
  created_at TIMESTAMPTZ,
  updated_at TIMESTAMPTZ,
  business_name VARCHAR,
  business_description VARCHAR,
  business_owner_id UUID,
  business_latitude DOUBLE PRECISION,
  business_longitude DOUBLE PRECISION,
  business_address VARCHAR,
  business_phone VARCHAR,
  distance_km DOUBLE PRECISION,
  distance_miles DOUBLE PRECISION
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    d.id,
    d.business_id,
    d.title,
    d.description,
    d.original_price,
    d.discounted_price,
    d.quantity_available,
    d.quantity_sold,
    d.image_url,
    d.allergen_info,
    d.expires_at,
    d.status,
    d.created_at,
    d.updated_at,
    b.name as business_name,
    b.description as business_description,
    b.owner_id as business_owner_id,
    b.latitude as business_latitude,
    b.longitude as business_longitude,
    b.address as business_address,
    b.phone as business_phone,
    (ST_Distance(
      ST_Point(b.longitude, b.latitude)::geography,
      ST_Point(user_lng, user_lat)::geography
    ) / 1000.0)::DOUBLE PRECISION as distance_km,
    (ST_Distance(
      ST_Point(b.longitude, b.latitude)::geography,
      ST_Point(user_lng, user_lat)::geography
    ) / 1609.34)::DOUBLE PRECISION as distance_miles
  FROM deals d
  JOIN businesses b ON d.business_id = b.id
  WHERE d.status = 'active'
    AND d.expires_at > NOW()
    AND b.latitude IS NOT NULL
    AND b.longitude IS NOT NULL
    AND ST_DWithin(
      ST_Point(b.longitude, b.latitude)::geography,
      ST_Point(user_lng, user_lat)::geography,
      radius_meters
    )
    AND (business_filter IS NULL OR d.business_id = business_filter)
    AND (search_term IS NULL OR (
      d.title ILIKE search_term OR 
      d.description ILIKE search_term
    ))
  ORDER BY 
    ST_Distance(
      ST_Point(b.longitude, b.latitude)::geography,
      ST_Point(user_lng, user_lat)::geography
    ) ASC,
    d.created_at DESC
  LIMIT result_limit;
END;
$$;

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_nearby_deals TO authenticated;
GRANT EXECUTE ON FUNCTION get_nearby_deals TO service_role;