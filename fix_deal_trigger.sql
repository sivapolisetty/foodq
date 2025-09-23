-- Fix the deal creation trigger function
CREATE OR REPLACE FUNCTION create_deal_event()
RETURNS TRIGGER AS $$
DECLARE
  business_location RECORD;
  deal_discount NUMERIC;
  quantity_total INTEGER;
  is_deal_active BOOLEAN;
BEGIN
  -- Get business location and contact info
  SELECT 
    latitude, longitude, address, city, state, name, owner_id, email, phone
  INTO business_location
  FROM businesses 
  WHERE id = NEW.business_id;

  -- Calculate discount percentage if we have both prices
  IF NEW.original_price IS NOT NULL AND NEW.original_price > 0 THEN
    deal_discount := ROUND(((NEW.original_price - COALESCE(NEW.discounted_price, NEW.price, NEW.original_price)) / NEW.original_price) * 100);
  ELSE
    deal_discount := 0;
  END IF;

  -- Calculate total quantity (available + sold)
  quantity_total := COALESCE(NEW.quantity_available, 0) + COALESCE(NEW.quantity_sold, 0);

  -- Determine if deal is active (status is active AND not expired)
  is_deal_active := (NEW.status = 'active' AND NEW.expires_at > CURRENT_TIMESTAMP);

  -- Create DEAL_CREATED event
  INSERT INTO event_queue (
    event_type,
    payload,
    metadata,
    status,
    created_at
  ) VALUES (
    'DEAL_CREATED',
    jsonb_build_object(
      'dealId', NEW.id,
      'businessId', NEW.business_id,
      'businessName', business_location.name,
      'businessOwnerId', business_location.owner_id,
      'title', NEW.title,
      'description', NEW.description,
      'discount', deal_discount,
      'originalPrice', NEW.original_price,
      'discountedPrice', COALESCE(NEW.discounted_price, NEW.price),
      'quantityAvailable', NEW.quantity_available,
      'quantityTotal', quantity_total,
      'expiresAt', NEW.expires_at,
      'isActive', is_deal_active,
      'location', jsonb_build_object(
        'latitude', business_location.latitude,
        'longitude', business_location.longitude,
        'address', business_location.address,
        'city', business_location.city,
        'state', business_location.state
      ),
      'businessContact', jsonb_build_object(
        'phone', business_location.phone,
        'email', business_location.email
      )
    ),
    jsonb_build_object(
      'source', 'deal_trigger',
      'version', '1.0',
      'notificationRadius', 5,
      'triggerType', TG_OP
    ),
    'pending',
    CURRENT_TIMESTAMP
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;