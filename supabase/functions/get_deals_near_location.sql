-- Function to get deals near a specific location with distance calculations
-- This function uses the Haversine formula to calculate distances

CREATE OR REPLACE FUNCTION get_deals_near_location(
  user_lat DOUBLE PRECISION,
  user_lng DOUBLE PRECISION,
  radius_km DOUBLE PRECISION DEFAULT 10,
  result_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
  -- Deal fields
  id UUID,
  business_id UUID,
  title VARCHAR(255),
  description TEXT,
  original_price DECIMAL(10,2),
  discounted_price DECIMAL(10,2),
  discount_percentage INTEGER,
  image_url TEXT,
  is_active BOOLEAN,
  valid_from TIMESTAMP WITH TIME ZONE,
  valid_until TIMESTAMP WITH TIME ZONE,
  terms_conditions TEXT,
  max_redemptions INTEGER,
  current_redemptions INTEGER,
  created_at TIMESTAMP WITH TIME ZONE,
  updated_at TIMESTAMP WITH TIME ZONE,
  
  -- Business fields
  business_name VARCHAR(255),
  business_image_url TEXT,
  business_address TEXT,
  business_phone VARCHAR(20),
  business_latitude DOUBLE PRECISION,
  business_longitude DOUBLE PRECISION,
  
  -- Distance calculations
  distance_km DOUBLE PRECISION,
  formatted_distance TEXT,
  delivery_zone TEXT,
  delivery_fee DECIMAL(10,2),
  is_delivery_available BOOLEAN,
  delivery_status TEXT,
  area_name TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
  earth_radius CONSTANT DOUBLE PRECISION := 6371; -- Earth's radius in kilometers
BEGIN
  RETURN QUERY
  WITH deal_distances AS (
    SELECT 
      d.*,
      b.name as business_name,
      b.image_url as business_image_url,
      b.address as business_address,
      b.phone as business_phone,
      b.latitude as business_latitude,
      b.longitude as business_longitude,
      
      -- Haversine formula for distance calculation
      (
        earth_radius * acos(
          cos(radians(user_lat)) * cos(radians(b.latitude)) * 
          cos(radians(b.longitude) - radians(user_lng)) + 
          sin(radians(user_lat)) * sin(radians(b.latitude))
        )
      ) as calculated_distance_km
      
    FROM deals d
    INNER JOIN businesses b ON d.business_id = b.id
    WHERE 
      d.is_active = true
      AND b.is_active = true
      AND d.valid_from <= NOW()
      AND d.valid_until >= NOW()
      AND b.latitude IS NOT NULL
      AND b.longitude IS NOT NULL
      -- Pre-filter with approximate bounding box for performance
      AND b.latitude BETWEEN (user_lat - (radius_km / 111.32)) AND (user_lat + (radius_km / 111.32))
      AND b.longitude BETWEEN (user_lng - (radius_km / (111.32 * cos(radians(user_lat))))) AND (user_lng + (radius_km / (111.32 * cos(radians(user_lat)))))
  ),
  filtered_deals AS (
    SELECT *
    FROM deal_distances
    WHERE calculated_distance_km <= radius_km
    ORDER BY calculated_distance_km ASC
    LIMIT result_limit
  )
  SELECT 
    fd.id,
    fd.business_id,
    fd.title,
    fd.description,
    fd.original_price,
    fd.discounted_price,
    fd.discount_percentage,
    fd.image_url,
    fd.is_active,
    fd.valid_from,
    fd.valid_until,
    fd.terms_conditions,
    fd.max_redemptions,
    fd.current_redemptions,
    fd.created_at,
    fd.updated_at,
    
    fd.business_name,
    fd.business_image_url,
    fd.business_address,
    fd.business_phone,
    fd.business_latitude,
    fd.business_longitude,
    
    fd.calculated_distance_km as distance_km,
    
    -- Format distance for display
    CASE 
      WHEN fd.calculated_distance_km < 1 THEN 
        ROUND(fd.calculated_distance_km * 1000)::TEXT || 'm away'
      WHEN fd.calculated_distance_km < 10 THEN 
        ROUND(fd.calculated_distance_km::NUMERIC, 1)::TEXT || 'km away'
      ELSE 
        ROUND(fd.calculated_distance_km)::TEXT || 'km away'
    END as formatted_distance,
    
    -- Determine delivery zone
    CASE 
      WHEN fd.calculated_distance_km <= 2 THEN 'express'
      WHEN fd.calculated_distance_km <= 5 THEN 'standard'
      WHEN fd.calculated_distance_km <= 10 THEN 'extended'
      ELSE 'not_available'
    END as delivery_zone,
    
    -- Calculate delivery fee
    CASE 
      WHEN fd.calculated_distance_km <= 2 THEN 0::DECIMAL(10,2)
      WHEN fd.calculated_distance_km <= 5 THEN 20::DECIMAL(10,2)
      WHEN fd.calculated_distance_km <= 10 THEN 40::DECIMAL(10,2)
      ELSE -1::DECIMAL(10,2)
    END as delivery_fee,
    
    -- Check if delivery is available
    (fd.calculated_distance_km <= 10) as is_delivery_available,
    
    -- Delivery status text
    CASE 
      WHEN fd.calculated_distance_km <= 2 THEN 'Free Delivery'
      WHEN fd.calculated_distance_km <= 5 THEN 'Delivery ₹20'
      WHEN fd.calculated_distance_km <= 10 THEN 'Delivery ₹40'
      ELSE 'Delivery Not Available'
    END as delivery_status,
    
    -- Determine area name (simplified mapping)
    CASE 
      WHEN fd.business_latitude >= 12.95 AND fd.business_latitude <= 13.05 
           AND fd.business_longitude >= 77.55 AND fd.business_longitude <= 77.65 THEN
        CASE 
          WHEN fd.business_latitude >= 12.97 AND fd.business_longitude >= 77.59 THEN 'Indiranagar'
          WHEN fd.business_latitude >= 12.96 AND fd.business_longitude <= 77.58 THEN 'MG Road'
          WHEN fd.business_latitude <= 12.96 AND fd.business_longitude >= 77.60 THEN 'Koramangala'
          ELSE 'Central Bangalore'
        END
      WHEN fd.business_latitude >= 12.85 AND fd.business_latitude <= 12.95 THEN
        CASE 
          WHEN fd.business_longitude >= 77.60 THEN 'HSR Layout'
          WHEN fd.business_longitude >= 77.55 THEN 'Jayanagar'
          ELSE 'South Bangalore'
        END
      WHEN fd.business_latitude >= 13.05 THEN 'North Bangalore'
      WHEN fd.business_longitude >= 77.65 THEN 'East Bangalore'
      WHEN fd.business_longitude <= 77.50 THEN 'West Bangalore'
      ELSE 'Bangalore'
    END as area_name
    
  FROM filtered_deals fd;
END;
$$;

-- Create an index on businesses location for better performance
CREATE INDEX IF NOT EXISTS idx_businesses_location ON businesses USING GIST (
  ll_to_earth(latitude, longitude)
) WHERE latitude IS NOT NULL AND longitude IS NOT NULL AND is_active = true;

-- Create an index on deals for active deals
CREATE INDEX IF NOT EXISTS idx_deals_active_valid ON deals (is_active, valid_from, valid_until) 
WHERE is_active = true;

-- Create composite index for deal queries
CREATE INDEX IF NOT EXISTS idx_deals_business_active ON deals (business_id, is_active, valid_from, valid_until);

-- Grant execute permission
GRANT EXECUTE ON FUNCTION get_deals_near_location TO authenticated;
GRANT EXECUTE ON FUNCTION get_deals_near_location TO anon;