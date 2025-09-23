-- Migration: Create User Locations Table
-- Description: Store user locations for location-based notifications
-- Version: 1.0
-- Date: 2025-09-23

-- Enable PostGIS extension for geospatial operations
CREATE EXTENSION IF NOT EXISTS postgis;

-- Create user_locations table
CREATE TABLE IF NOT EXISTS public.user_locations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- Location details
  location_type VARCHAR(20) NOT NULL CHECK (location_type IN ('home', 'work', 'other')),
  address TEXT NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  
  -- Geospatial data for efficient querying
  geom GEOGRAPHY(POINT, 4326) GENERATED ALWAYS AS (ST_MakePoint(longitude, latitude)::geography) STORED,
  
  -- Notification preferences for this location
  notification_radius_km INTEGER DEFAULT 5 CHECK (notification_radius_km >= 1 AND notification_radius_km <= 50),
  active BOOLEAN DEFAULT true,
  
  -- Metadata
  label VARCHAR(100),
  city VARCHAR(100),
  state VARCHAR(100),
  country VARCHAR(100) DEFAULT 'US',
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Constraints
  CONSTRAINT unique_user_location_type UNIQUE (user_id, location_type),
  CONSTRAINT valid_coordinates CHECK (
    latitude >= -90 AND latitude <= 90 AND
    longitude >= -180 AND longitude <= 180
  )
);

-- Create spatial index for location queries
CREATE INDEX IF NOT EXISTS idx_user_locations_geom 
ON public.user_locations USING GIST (geom);

-- Create regular indexes
CREATE INDEX IF NOT EXISTS idx_user_locations_user 
ON public.user_locations(user_id, active);

CREATE INDEX IF NOT EXISTS idx_user_locations_type 
ON public.user_locations(location_type, active);

CREATE INDEX IF NOT EXISTS idx_user_locations_updated 
ON public.user_locations(updated_at DESC);

-- Enable RLS
ALTER TABLE public.user_locations ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Users can only manage their own locations
CREATE POLICY "Users can manage own locations" ON public.user_locations
FOR ALL USING (auth.uid() = user_id);

-- Service role can access all locations
CREATE POLICY "Service role can access all locations" ON public.user_locations
FOR ALL USING (auth.role() = 'service_role');

-- Grant permissions
GRANT ALL ON public.user_locations TO authenticated;
GRANT ALL ON public.user_locations TO service_role;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_user_locations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER user_locations_updated_at
BEFORE UPDATE ON public.user_locations
FOR EACH ROW
EXECUTE FUNCTION public.update_user_locations_updated_at();

-- Create function to find users near a location
CREATE OR REPLACE FUNCTION public.find_users_near_location(
  p_latitude DECIMAL,
  p_longitude DECIMAL,
  p_radius_km INTEGER DEFAULT 5
)
RETURNS TABLE(
  user_id UUID,
  distance_km DECIMAL,
  location_type VARCHAR,
  notification_radius_km INTEGER,
  address TEXT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    ul.user_id,
    ROUND((ST_Distance(ul.geom, ST_MakePoint(p_longitude, p_latitude)::geography) / 1000)::numeric, 2) AS distance_km,
    ul.location_type,
    ul.notification_radius_km,
    ul.address
  FROM public.user_locations ul
  WHERE ul.active = true
    AND ST_DWithin(
      ul.geom,
      ST_MakePoint(p_longitude, p_latitude)::geography,
      LEAST(p_radius_km, ul.notification_radius_km) * 1000 -- Convert km to meters
    )
  ORDER BY ST_Distance(ul.geom, ST_MakePoint(p_longitude, p_latitude)::geography);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION public.find_users_near_location TO authenticated;
GRANT EXECUTE ON FUNCTION public.find_users_near_location TO service_role;

-- Comments for documentation
COMMENT ON TABLE public.user_locations IS 'User locations for location-based notifications';
COMMENT ON COLUMN public.user_locations.geom IS 'PostGIS geography point for spatial queries';
COMMENT ON COLUMN public.user_locations.notification_radius_km IS 'Radius in km for receiving location-based notifications';
COMMENT ON FUNCTION public.find_users_near_location IS 'Find users within specified radius of a location';