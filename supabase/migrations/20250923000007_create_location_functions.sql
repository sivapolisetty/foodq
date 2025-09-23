-- Migration: Create Location-Based Notification Functions
-- Description: Functions for location-aware notifications and scheduled tasks
-- Version: 1.0
-- Date: 2025-09-23

-- Create function to send daily location-based deal notifications
CREATE OR REPLACE FUNCTION public.send_daily_location_deals()
RETURNS TABLE(
  total_users INTEGER,
  total_notifications INTEGER,
  avg_deals_per_user NUMERIC
) AS $$
DECLARE
  user_record RECORD;
  deal_record RECORD;
  deals_array JSONB;
  user_count INTEGER := 0;
  notification_count INTEGER := 0;
  total_deals INTEGER := 0;
BEGIN
  -- Process each user with an active home location
  FOR user_record IN 
    SELECT DISTINCT 
      ul.user_id,
      ul.latitude,
      ul.longitude,
      ul.notification_radius_km,
      ul.address,
      ul.city,
      u.email,
      u.raw_user_meta_data->>'name' as name
    FROM public.user_locations ul
    JOIN auth.users u ON ul.user_id = u.id
    WHERE ul.active = true
      AND ul.location_type = 'home'
      AND u.email_confirmed_at IS NOT NULL -- Only confirmed users
  LOOP
    user_count := user_count + 1;
    deals_array := '[]'::jsonb;
    
    -- Find deals near user's home location that expire in the next 24 hours
    FOR deal_record IN
      SELECT 
        d.id,
        d.title,
        d.description,
        d.original_price,
        d.discounted_price,
        d.image_url,
        d.expires_at,
        d.quantity_available,
        b.name as business_name,
        b.address as business_address,
        ROUND((ST_Distance(
          ST_MakePoint(b.longitude, b.latitude)::geography,
          ST_MakePoint(user_record.longitude, user_record.latitude)::geography
        ) / 1000)::numeric, 2) as distance_km,
        ROUND(((d.original_price - d.discounted_price) / d.original_price * 100)::numeric, 0) as discount_percent
      FROM public.deals d
      JOIN public.businesses b ON d.business_id = b.id
      WHERE d.is_active = true
        AND d.quantity_available > 0
        AND d.expires_at > CURRENT_TIMESTAMP
        AND d.expires_at < CURRENT_TIMESTAMP + INTERVAL '24 hours'
        AND ST_DWithin(
          ST_MakePoint(b.longitude, b.latitude)::geography,
          ST_MakePoint(user_record.longitude, user_record.latitude)::geography,
          user_record.notification_radius_km * 1000 -- Convert km to meters
        )
      ORDER BY distance_km ASC, discount_percent DESC
      LIMIT 5 -- Max 5 deals per user
    LOOP
      deals_array := deals_array || jsonb_build_object(
        'dealId', deal_record.id,
        'title', deal_record.title,
        'description', deal_record.description,
        'businessName', deal_record.business_name,
        'businessAddress', deal_record.business_address,
        'originalPrice', deal_record.original_price,
        'discountedPrice', deal_record.discounted_price,
        'discountPercent', deal_record.discount_percent,
        'distance', deal_record.distance_km,
        'imageUrl', deal_record.image_url,
        'expiresAt', deal_record.expires_at,
        'quantityAvailable', deal_record.quantity_available
      );
      total_deals := total_deals + 1;
    END LOOP;
    
    -- If user has deals nearby, create location-based deal event
    IF jsonb_array_length(deals_array) > 0 THEN
      INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
      VALUES (
        'LOCATION_BASED_DEAL',
        'Daily deal digest',
        jsonb_build_object(
          'userId', user_record.user_id,
          'userName', user_record.name,
          'userEmail', user_record.email,
          'userLocation', jsonb_build_object(
            'address', user_record.address,
            'city', user_record.city,
            'latitude', user_record.latitude,
            'longitude', user_record.longitude,
            'radiusKm', user_record.notification_radius_km
          ),
          'deals', deals_array,
          'dealCount', jsonb_array_length(deals_array)
        ),
        jsonb_build_object(
          'source', 'scheduled_job',
          'version', '1.0',
          'schedule', 'daily_digest',
          'jobRunAt', CURRENT_TIMESTAMP
        )
      );
      notification_count := notification_count + 1;
    END IF;
  END LOOP;
  
  -- Return statistics
  RETURN QUERY SELECT 
    user_count as total_users,
    notification_count as total_notifications,
    CASE WHEN notification_count > 0 THEN ROUND((total_deals::NUMERIC / notification_count), 2) ELSE 0 END as avg_deals_per_user;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to find deals near location with advanced filtering
CREATE OR REPLACE FUNCTION public.find_deals_near_location(
  p_latitude DECIMAL,
  p_longitude DECIMAL,
  p_radius_km INTEGER DEFAULT 5,
  p_min_discount INTEGER DEFAULT 0,
  p_max_distance_km INTEGER DEFAULT NULL,
  p_category TEXT DEFAULT NULL,
  p_max_price DECIMAL DEFAULT NULL,
  p_limit INTEGER DEFAULT 20
)
RETURNS TABLE(
  deal_id UUID,
  title TEXT,
  description TEXT,
  business_name TEXT,
  business_address TEXT,
  original_price DECIMAL,
  discounted_price DECIMAL,
  discount_percent NUMERIC,
  distance_km NUMERIC,
  image_url TEXT,
  expires_at TIMESTAMP WITH TIME ZONE,
  quantity_available INTEGER,
  business_latitude DECIMAL,
  business_longitude DECIMAL,
  estimated_savings DECIMAL
) AS $$
DECLARE
  max_distance INTEGER;
BEGIN
  -- Set maximum distance
  max_distance := COALESCE(p_max_distance_km, p_radius_km);
  
  RETURN QUERY
  SELECT 
    d.id as deal_id,
    d.title,
    d.description,
    b.name as business_name,
    b.address as business_address,
    d.original_price,
    d.discounted_price,
    ROUND(((d.original_price - d.discounted_price) / d.original_price * 100)::numeric, 0) as discount_percent,
    ROUND((ST_Distance(
      ST_MakePoint(b.longitude, b.latitude)::geography,
      ST_MakePoint(p_longitude, p_latitude)::geography
    ) / 1000)::numeric, 2) as distance_km,
    d.image_url,
    d.expires_at,
    d.quantity_available,
    b.latitude as business_latitude,
    b.longitude as business_longitude,
    (d.original_price - d.discounted_price) as estimated_savings
  FROM public.deals d
  JOIN public.businesses b ON d.business_id = b.id
  WHERE d.is_active = true
    AND d.quantity_available > 0
    AND d.expires_at > CURRENT_TIMESTAMP
    AND ST_DWithin(
      ST_MakePoint(b.longitude, b.latitude)::geography,
      ST_MakePoint(p_longitude, p_latitude)::geography,
      max_distance * 1000 -- Convert km to meters
    )
    AND ROUND(((d.original_price - d.discounted_price) / d.original_price * 100)::numeric, 0) >= p_min_discount
    AND (p_category IS NULL OR LOWER(d.category) = LOWER(p_category))
    AND (p_max_price IS NULL OR d.discounted_price <= p_max_price)
  ORDER BY distance_km ASC, discount_percent DESC, d.expires_at ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to check if user should receive location notifications
CREATE OR REPLACE FUNCTION public.should_send_location_notification(
  p_user_id UUID,
  p_deal_category TEXT DEFAULT NULL,
  p_notification_type TEXT DEFAULT 'deal'
)
RETURNS BOOLEAN AS $$
DECLARE
  user_preferences JSONB;
  last_notification TIMESTAMP WITH TIME ZONE;
  notification_frequency INTERVAL;
BEGIN
  -- Get user notification preferences (you can extend this with a preferences table)
  -- For now, we'll use some basic logic
  
  -- Check if user has been notified recently for this type
  SELECT MAX(created_at)
  INTO last_notification
  FROM public.notifications
  WHERE recipient_id = p_user_id
    AND event_type = 'LOCATION_BASED_DEAL'
    AND created_at > CURRENT_TIMESTAMP - INTERVAL '6 hours'; -- Don't spam within 6 hours
  
  IF last_notification IS NOT NULL THEN
    RETURN false;
  END IF;
  
  -- Check if user has active location
  IF NOT EXISTS (
    SELECT 1 FROM public.user_locations
    WHERE user_id = p_user_id AND active = true
  ) THEN
    RETURN false;
  END IF;
  
  -- Add more sophisticated logic here based on user preferences
  -- For now, default to true if no recent notifications
  RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to create location event for specific business
CREATE OR REPLACE FUNCTION public.create_location_event_for_business(
  p_business_id UUID,
  p_radius_km INTEGER DEFAULT 5,
  p_event_type TEXT DEFAULT 'BUSINESS_UPDATE'
)
RETURNS INTEGER AS $$
DECLARE
  business_location RECORD;
  nearby_users RECORD;
  event_count INTEGER := 0;
BEGIN
  -- Get business location
  SELECT name, latitude, longitude, address, owner_id
  INTO business_location
  FROM public.businesses
  WHERE id = p_business_id;
  
  IF business_location IS NULL THEN
    RAISE EXCEPTION 'Business not found';
  END IF;
  
  -- Find nearby users and create events
  FOR nearby_users IN
    SELECT DISTINCT ul.user_id, ul.distance_km, ul.location_type
    FROM public.find_users_near_location(
      business_location.latitude,
      business_location.longitude,
      p_radius_km
    ) ul
    WHERE public.should_send_location_notification(ul.user_id, NULL, 'business_update')
  LOOP
    INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
    VALUES (
      p_event_type,
      'Business update notification',
      jsonb_build_object(
        'businessId', p_business_id,
        'businessName', business_location.name,
        'businessOwnerId', business_location.owner_id,
        'userId', nearby_users.user_id,
        'distance', nearby_users.distance_km,
        'userLocationType', nearby_users.location_type,
        'location', jsonb_build_object(
          'latitude', business_location.latitude,
          'longitude', business_location.longitude,
          'address', business_location.address
        )
      ),
      jsonb_build_object(
        'source', 'business_location_trigger',
        'version', '1.0',
        'radiusKm', p_radius_km
      )
    );
    event_count := event_count + 1;
  END LOOP;
  
  RETURN event_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to cleanup old location data
CREATE OR REPLACE FUNCTION public.cleanup_old_location_data()
RETURNS TABLE(
  deleted_inactive_locations INTEGER,
  deleted_old_events INTEGER,
  updated_stale_locations INTEGER
) AS $$
DECLARE
  inactive_count INTEGER;
  events_count INTEGER;
  stale_count INTEGER;
BEGIN
  -- Delete inactive user locations older than 6 months
  DELETE FROM public.user_locations
  WHERE active = false 
    AND updated_at < CURRENT_TIMESTAMP - INTERVAL '6 months';
  GET DIAGNOSTICS inactive_count = ROW_COUNT;
  
  -- Delete old processed events (older than 30 days)
  DELETE FROM public.event_queue
  WHERE status = 'processed'
    AND processed_at < CURRENT_TIMESTAMP - INTERVAL '30 days';
  GET DIAGNOSTICS events_count = ROW_COUNT;
  
  -- Mark locations as stale if not updated in 90 days
  UPDATE public.user_locations
  SET active = false
  WHERE active = true
    AND updated_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
  GET DIAGNOSTICS stale_count = ROW_COUNT;
  
  RETURN QUERY SELECT inactive_count, events_count, stale_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.send_daily_location_deals TO service_role;
GRANT EXECUTE ON FUNCTION public.find_deals_near_location TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.should_send_location_notification TO service_role;
GRANT EXECUTE ON FUNCTION public.create_location_event_for_business TO authenticated, service_role;
GRANT EXECUTE ON FUNCTION public.cleanup_old_location_data TO service_role;

-- Create a view for location-based analytics
CREATE OR REPLACE VIEW public.location_notification_stats AS
SELECT 
  DATE(n.created_at) as notification_date,
  COUNT(*) as total_notifications,
  COUNT(DISTINCT n.recipient_id) as unique_recipients,
  AVG((n.location_context->>'distance_km')::FLOAT) as avg_distance_km,
  COUNT(*) FILTER (WHERE n.is_read = true) as read_notifications,
  ROUND(
    (COUNT(*) FILTER (WHERE n.is_read = true)::NUMERIC / COUNT(*) * 100), 2
  ) as read_rate_percent,
  COUNT(*) FILTER (WHERE n.clicked_at IS NOT NULL) as clicked_notifications,
  ROUND(
    (COUNT(*) FILTER (WHERE n.clicked_at IS NOT NULL)::NUMERIC / COUNT(*) * 100), 2
  ) as click_rate_percent
FROM public.notifications n
WHERE n.event_type IN ('DEAL_CREATED', 'LOCATION_BASED_DEAL')
  AND n.location_context IS NOT NULL
  AND n.created_at >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(n.created_at)
ORDER BY notification_date DESC;

-- Grant access to the view
GRANT SELECT ON public.location_notification_stats TO authenticated, service_role;

-- Comments for documentation
COMMENT ON FUNCTION public.send_daily_location_deals IS 'Send daily digest of deals near user locations';
COMMENT ON FUNCTION public.find_deals_near_location IS 'Find deals near a specific location with filtering options';
COMMENT ON FUNCTION public.should_send_location_notification IS 'Check if user should receive location-based notifications';
COMMENT ON FUNCTION public.create_location_event_for_business IS 'Create location events for users near a business';
COMMENT ON VIEW public.location_notification_stats IS 'Analytics view for location-based notification performance';