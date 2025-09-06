-- Minimal working geospatial function that returns JSONB to avoid type issues
CREATE OR REPLACE FUNCTION get_nearby_deals(
  user_lat DOUBLE PRECISION,
  user_lng DOUBLE PRECISION,
  radius_meters DOUBLE PRECISION DEFAULT 10000,
  result_limit INTEGER DEFAULT 20,
  business_filter UUID DEFAULT NULL,
  search_term TEXT DEFAULT NULL
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN (
    SELECT jsonb_agg(
      jsonb_build_object(
        'id', d.id,
        'business_id', d.business_id,
        'title', d.title,
        'description', d.description,
        'original_price', d.original_price,
        'discounted_price', d.discounted_price,
        'quantity_available', d.quantity_available,
        'quantity_sold', d.quantity_sold,
        'image_url', d.image_url,
        'allergen_info', d.allergen_info,
        'expires_at', d.expires_at,
        'status', d.status,
        'created_at', d.created_at,
        'updated_at', d.updated_at,
        'businesses', jsonb_build_object(
          'id', b.id,
          'name', b.name,
          'description', b.description,
          'owner_id', b.owner_id,
          'latitude', b.latitude,
          'longitude', b.longitude,
          'address', b.address,
          'phone', b.phone,
          'distance_km', round((ST_Distance(
            ST_Point(b.longitude, b.latitude)::geography,
            ST_Point(user_lng, user_lat)::geography
          ) / 1000.0)::numeric, 3),
          'distance_miles', round((ST_Distance(
            ST_Point(b.longitude, b.latitude)::geography,
            ST_Point(user_lng, user_lat)::geography
          ) / 1609.34)::numeric, 3)
        ),
        'distance_km', round((ST_Distance(
          ST_Point(b.longitude, b.latitude)::geography,
          ST_Point(user_lng, user_lat)::geography
        ) / 1000.0)::numeric, 3),
        'distance_miles', round((ST_Distance(
          ST_Point(b.longitude, b.latitude)::geography,
          ST_Point(user_lng, user_lat)::geography
        ) / 1609.34)::numeric, 3)
      )
    )
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
    LIMIT result_limit
  );
END;
$$;