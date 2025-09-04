-- PRODUCTION PostgreSQL Function for Scalable Geospatial Nearby Businesses
-- Apply this SQL in your production Supabase database (in addition to the deals function)

CREATE OR REPLACE FUNCTION get_nearby_businesses(
  user_lat DOUBLE PRECISION,
  user_lng DOUBLE PRECISION,
  radius_meters DOUBLE PRECISION DEFAULT 10000,
  result_limit INTEGER DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  result JSONB;
BEGIN
  WITH nearby_businesses AS (
    SELECT 
      b.id,
      b.name,
      b.description,
      b.owner_id,
      b.latitude,
      b.longitude,
      b.address,
      b.phone,
      b.email,
      b.category,
      b.is_approved,
      b.is_active,
      b.city,
      b.state,
      b.country,
      b.zip_code,
      b.delivery_radius,
      b.min_order_amount,
      b.accepts_cash,
      b.accepts_cards,
      b.accepts_digital,
      b.onboarding_completed,
      b.created_at,
      b.updated_at,
      round((ST_Distance(
        ST_Point(b.longitude, b.latitude)::geography,
        ST_Point(user_lng, user_lat)::geography
      ) / 1000.0)::numeric, 3) as distance_km,
      round((ST_Distance(
        ST_Point(b.longitude, b.latitude)::geography,
        ST_Point(user_lng, user_lat)::geography
      ) / 1609.34)::numeric, 3) as distance_miles
    FROM businesses b
    WHERE b.is_active = true
      AND b.latitude IS NOT NULL
      AND b.longitude IS NOT NULL
      AND ST_DWithin(
        ST_Point(b.longitude, b.latitude)::geography,
        ST_Point(user_lng, user_lat)::geography,
        radius_meters
      )
    ORDER BY 
      ST_Distance(
        ST_Point(b.longitude, b.latitude)::geography,
        ST_Point(user_lng, user_lat)::geography
      ) ASC,
      b.created_at DESC
    LIMIT result_limit
  )
  SELECT jsonb_agg(
    jsonb_build_object(
      'id', nb.id,
      'name', nb.name,
      'description', nb.description,
      'owner_id', nb.owner_id,
      'latitude', nb.latitude,
      'longitude', nb.longitude,
      'address', nb.address,
      'phone', nb.phone,
      'email', nb.email,
      'category', nb.category,
      'is_approved', nb.is_approved,
      'is_active', nb.is_active,
      'city', nb.city,
      'state', nb.state,
      'country', nb.country,
      'zip_code', nb.zip_code,
      'delivery_radius', nb.delivery_radius,
      'min_order_amount', nb.min_order_amount,
      'accepts_cash', nb.accepts_cash,
      'accepts_cards', nb.accepts_cards,
      'accepts_digital', nb.accepts_digital,
      'onboarding_completed', nb.onboarding_completed,
      'created_at', nb.created_at,
      'updated_at', nb.updated_at,
      'distance_km', nb.distance_km,
      'distance_miles', nb.distance_miles
    )
  ) INTO result
  FROM nearby_businesses nb;
  
  RETURN COALESCE(result, '[]'::jsonb);
END;
$$;

-- Grant permissions
GRANT EXECUTE ON FUNCTION get_nearby_businesses TO authenticated;
GRANT EXECUTE ON FUNCTION get_nearby_businesses TO service_role;

-- This function provides:
-- ✅ Scalable to thousands of businesses (uses ST_DWithin spatial filtering)
-- ✅ No JavaScript fallback (pure PostgreSQL processing)
-- ✅ Precise distance calculations (PostGIS ST_Distance)
-- ✅ Proper JSONB return format (no type conversion issues)
-- ✅ Spatial indexing support (geography data type)
-- ✅ Complete business data in response with distance_km and distance_miles