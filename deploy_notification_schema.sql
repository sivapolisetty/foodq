-- Deploy complete notification schema to production

-- 1. Create event_queue table
CREATE TABLE IF NOT EXISTS event_queue (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_type varchar(100) NOT NULL,
    event_name varchar(200) NOT NULL,
    event_version varchar(10) DEFAULT '1.0',
    payload jsonb NOT NULL,
    metadata jsonb DEFAULT '{}',
    status varchar(20) DEFAULT 'pending',
    retry_count integer DEFAULT 0,
    max_retries integer DEFAULT 3,
    error_message text,
    error_details jsonb,
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
    processed_at timestamptz,
    next_retry_at timestamptz,
    
    CONSTRAINT check_event_type CHECK (event_type IN (
        'ORDER_CREATED', 'ORDER_PAID', 'ORDER_CONFIRMED', 'ORDER_PREPARING',
        'ORDER_READY', 'ORDER_COMPLETED', 'ORDER_CANCELLED',
        'DEAL_CREATED', 'DEAL_UPDATED', 'DEAL_EXPIRING', 'DEAL_EXPIRED',
        'BUSINESS_UPDATE', 'SYSTEM_ANNOUNCEMENT', 'LOCATION_BASED_DEAL'
    )),
    CONSTRAINT event_queue_status_check CHECK (status IN (
        'pending', 'processing', 'processed', 'failed', 'retry'
    ))
);

-- 2. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_event_queue_status 
ON event_queue(status, created_at) 
WHERE status IN ('pending', 'retry');

CREATE INDEX IF NOT EXISTS idx_event_queue_type 
ON event_queue(event_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_event_queue_retry 
ON event_queue(next_retry_at) 
WHERE status = 'retry';

CREATE INDEX IF NOT EXISTS idx_event_queue_processing 
ON event_queue(processed_at DESC) 
WHERE processed_at IS NOT NULL;

-- 3. Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id uuid DEFAULT uuid_generate_v4() PRIMARY KEY,
    event_id uuid REFERENCES event_queue(id) ON DELETE SET NULL,
    user_id uuid NOT NULL,
    title varchar(200) NOT NULL,
    body text NOT NULL,
    notification_type varchar(50) NOT NULL DEFAULT 'general',
    priority varchar(20) DEFAULT 'normal',
    fcm_message_id varchar(255),
    delivery_status varchar(20) DEFAULT 'pending',
    opened_at timestamptz,
    data jsonb DEFAULT '{}',
    created_at timestamptz DEFAULT CURRENT_TIMESTAMP,
    sent_at timestamptz,
    
    CONSTRAINT notifications_delivery_status_check CHECK (delivery_status IN (
        'pending', 'sent', 'delivered', 'failed', 'opened'
    )),
    CONSTRAINT notifications_priority_check CHECK (priority IN (
        'low', 'normal', 'high', 'critical'
    ))
);

-- 4. Create indexes for notifications
CREATE INDEX IF NOT EXISTS idx_notifications_user_id 
ON notifications(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_status 
ON notifications(delivery_status, created_at);

CREATE INDEX IF NOT EXISTS idx_notifications_type 
ON notifications(notification_type, created_at DESC);

-- 5. RLS Policies
ALTER TABLE event_queue ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

-- Event queue policies
CREATE POLICY IF NOT EXISTS "Service role can manage all events" 
ON event_queue FOR ALL 
USING (auth.role() = 'service_role');

CREATE POLICY IF NOT EXISTS "Users can view related events" 
ON event_queue FOR SELECT 
USING (auth.role() = 'authenticated');

-- Notifications policies  
CREATE POLICY IF NOT EXISTS "Users can view own notifications" 
ON notifications FOR SELECT 
USING (auth.uid() = user_id);

CREATE POLICY IF NOT EXISTS "Service role can manage all notifications" 
ON notifications FOR ALL 
USING (auth.role() = 'service_role');

-- 6. Create webhook notification function
CREATE OR REPLACE FUNCTION notify_event_queue_webhook()
RETURNS TRIGGER AS $$
BEGIN
    -- This would trigger webhook via pg_net in real implementation
    -- For now, just log the event
    RAISE LOG 'Event queue webhook triggered for event_type: %', NEW.event_type;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. Create deal event trigger function (FIXED VERSION)
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
    event_name,
    payload,
    metadata,
    status,
    created_at
  ) VALUES (
    'DEAL_CREATED',
    'Deal Created: ' || NEW.title,
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

-- 8. Create triggers
CREATE TRIGGER IF NOT EXISTS event_queue_webhook_trigger
    AFTER INSERT ON event_queue
    FOR EACH ROW
    EXECUTE FUNCTION notify_event_queue_webhook();

CREATE TRIGGER IF NOT EXISTS deal_event_trigger
    AFTER INSERT OR UPDATE ON deals
    FOR EACH ROW
    EXECUTE FUNCTION create_deal_event();

-- 9. Grant necessary permissions
GRANT ALL ON event_queue TO service_role;
GRANT ALL ON notifications TO service_role;
GRANT SELECT ON event_queue TO authenticated;
GRANT SELECT, UPDATE ON notifications TO authenticated;