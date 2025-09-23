-- Migration: Create Event Triggers and Webhook Functions
-- Description: Set up triggers to create events and webhook notifications
-- Version: 1.0
-- Date: 2025-09-23

-- Create function to notify webhook on event queue insert
CREATE OR REPLACE FUNCTION public.notify_event_queue_webhook()
RETURNS TRIGGER AS $$
DECLARE
  webhook_payload JSONB;
  webhook_url TEXT;
  webhook_secret TEXT;
BEGIN
  -- Get webhook configuration from app settings
  SELECT 
    COALESCE(current_setting('app.webhook_url', true), 'https://api.foodq.com/api/notifications/process') as url,
    COALESCE(current_setting('app.webhook_secret', true), 'default-webhook-secret') as secret
  INTO webhook_url, webhook_secret;
  
  -- Prepare webhook payload
  webhook_payload := jsonb_build_object(
    'eventId', NEW.id,
    'eventType', NEW.event_type,
    'eventName', NEW.event_name,
    'eventVersion', NEW.event_version,
    'payload', NEW.payload,
    'metadata', NEW.metadata,
    'timestamp', NEW.created_at,
    'status', NEW.status
  );
  
  -- Try to send webhook notification using pg_net extension (if available)
  BEGIN
    -- Check if pg_net extension is available
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_net') THEN
      -- Send HTTP POST request
      PERFORM net.http_post(
        url := webhook_url,
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'X-Webhook-Secret', webhook_secret,
          'X-Event-Type', NEW.event_type,
          'X-Event-Id', NEW.id::text
        ),
        body := webhook_payload,
        timeout_milliseconds := 30000
      );
    ELSE
      -- Fallback: Use NOTIFY for local development/testing
      PERFORM pg_notify('event_queue_webhook', webhook_payload::text);
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- Log error but don't fail the transaction
      RAISE WARNING 'Failed to send webhook notification: %', SQLERRM;
      
      -- Update event status to indicate webhook failure
      UPDATE public.event_queue
      SET 
        status = 'failed',
        error_message = 'Webhook notification failed: ' || SQLERRM,
        error_details = jsonb_build_object(
          'error', SQLERRM,
          'timestamp', CURRENT_TIMESTAMP,
          'webhook_url', webhook_url
        )
      WHERE id = NEW.id;
  END;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for webhook notification on event queue insert
CREATE TRIGGER event_queue_webhook_trigger
AFTER INSERT ON public.event_queue
FOR EACH ROW
EXECUTE FUNCTION public.notify_event_queue_webhook();

-- Create function to automatically create order events
CREATE OR REPLACE FUNCTION public.create_order_event()
RETURNS TRIGGER AS $$
DECLARE
  business_info RECORD;
  customer_info RECORD;
  event_payload JSONB;
BEGIN
  -- Get business and customer information
  SELECT b.name, b.owner_id, b.latitude, b.longitude, b.address
  INTO business_info
  FROM public.businesses b
  WHERE b.id = NEW.business_id;
  
  SELECT u.email, u.raw_user_meta_data->>'name' as name
  INTO customer_info
  FROM auth.users u
  WHERE u.id = NEW.user_id;
  
  IF TG_OP = 'INSERT' THEN
    -- Create ORDER_CREATED event
    INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
    VALUES (
      'ORDER_CREATED',
      'New order created',
      jsonb_build_object(
        'orderId', NEW.id,
        'orderNumber', NEW.order_number,
        'businessId', NEW.business_id,
        'businessName', business_info.name,
        'businessOwnerId', business_info.owner_id,
        'customerId', NEW.user_id,
        'customerName', customer_info.name,
        'customerEmail', customer_info.email,
        'amount', NEW.total_amount,
        'items', NEW.items,
        'status', NEW.status,
        'paymentMethod', NEW.payment_method,
        'pickupTime', NEW.pickup_time,
        'location', jsonb_build_object(
          'latitude', business_info.latitude,
          'longitude', business_info.longitude,
          'address', business_info.address
        ),
        'createdAt', NEW.created_at
      ),
      jsonb_build_object(
        'source', 'order_trigger',
        'version', '1.0',
        'triggerType', 'INSERT'
      )
    );
    
  ELSIF TG_OP = 'UPDATE' THEN
    -- Check for status changes
    IF OLD.status != NEW.status THEN
      -- Determine event type based on new status
      DECLARE
        event_type_name TEXT;
        event_description TEXT;
      BEGIN
        CASE NEW.status
          WHEN 'paid' THEN
            event_type_name := 'ORDER_PAID';
            event_description := 'Order payment confirmed';
          WHEN 'confirmed' THEN
            event_type_name := 'ORDER_CONFIRMED';
            event_description := 'Order confirmed by business';
          WHEN 'preparing' THEN
            event_type_name := 'ORDER_PREPARING';
            event_description := 'Order is being prepared';
          WHEN 'ready' THEN
            event_type_name := 'ORDER_READY';
            event_description := 'Order is ready for pickup';
          WHEN 'completed' THEN
            event_type_name := 'ORDER_COMPLETED';
            event_description := 'Order completed';
          WHEN 'cancelled' THEN
            event_type_name := 'ORDER_CANCELLED';
            event_description := 'Order cancelled';
          ELSE
            event_type_name := 'ORDER_UPDATED';
            event_description := 'Order status updated';
        END CASE;
        
        -- Create status change event
        INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
        VALUES (
          event_type_name,
          event_description,
          jsonb_build_object(
            'orderId', NEW.id,
            'orderNumber', NEW.order_number,
            'businessId', NEW.business_id,
            'businessName', business_info.name,
            'businessOwnerId', business_info.owner_id,
            'customerId', NEW.user_id,
            'customerName', customer_info.name,
            'oldStatus', OLD.status,
            'newStatus', NEW.status,
            'amount', NEW.total_amount,
            'verificationCode', NEW.verification_code,
            'qrCode', NEW.qr_code,
            'pickupTime', NEW.pickup_time,
            'completedAt', NEW.completed_at,
            'location', jsonb_build_object(
              'latitude', business_info.latitude,
              'longitude', business_info.longitude,
              'address', business_info.address
            ),
            'updatedAt', NEW.updated_at
          ),
          jsonb_build_object(
            'source', 'order_trigger',
            'version', '1.0',
            'triggerType', 'UPDATE',
            'previousStatus', OLD.status
          )
        );
      END;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for order events
CREATE TRIGGER order_event_trigger
AFTER INSERT OR UPDATE ON public.orders
FOR EACH ROW
EXECUTE FUNCTION public.create_order_event();

-- Create function to create deal events with location awareness
CREATE OR REPLACE FUNCTION public.create_deal_event()
RETURNS TRIGGER AS $$
DECLARE
  business_location RECORD;
  deal_discount NUMERIC;
BEGIN
  -- Get business location and details
  SELECT 
    b.name, b.owner_id, b.latitude, b.longitude, b.address,
    b.city, b.state, b.phone, b.email
  INTO business_location
  FROM public.businesses b
  WHERE b.id = NEW.business_id;
  
  -- Calculate discount percentage
  IF NEW.original_price > 0 THEN
    deal_discount := ROUND(((NEW.original_price - NEW.discounted_price) / NEW.original_price * 100)::numeric, 0);
  ELSE
    deal_discount := 0;
  END IF;
  
  IF TG_OP = 'INSERT' THEN
    -- Create DEAL_CREATED event
    INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
    VALUES (
      'DEAL_CREATED',
      'New deal created',
      jsonb_build_object(
        'dealId', NEW.id,
        'businessId', NEW.business_id,
        'businessName', business_location.name,
        'businessOwnerId', business_location.owner_id,
        'title', NEW.title,
        'description', NEW.description,
        'category', NEW.category,
        'originalPrice', NEW.original_price,
        'discountedPrice', NEW.discounted_price,
        'discount', deal_discount,
        'imageUrl', NEW.image_url,
        'quantityAvailable', NEW.quantity_available,
        'quantityTotal', NEW.quantity_total,
        'expiresAt', NEW.expires_at,
        'isActive', NEW.is_active,
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
        ),
        'createdAt', NEW.created_at
      ),
      jsonb_build_object(
        'source', 'deal_trigger',
        'version', '1.0',
        'notificationRadius', 5, -- Default 5km radius
        'triggerType', 'INSERT'
      )
    );
    
    -- Check if deal is expiring soon (within 4 hours) and create expiring event
    IF NEW.expires_at <= CURRENT_TIMESTAMP + INTERVAL '4 hours' THEN
      INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
      VALUES (
        'DEAL_EXPIRING',
        'Deal expiring soon',
        jsonb_build_object(
          'dealId', NEW.id,
          'businessId', NEW.business_id,
          'businessName', business_location.name,
          'title', NEW.title,
          'discount', deal_discount,
          'expiresAt', NEW.expires_at,
          'expiresIn', EXTRACT(EPOCH FROM (NEW.expires_at - CURRENT_TIMESTAMP)),
          'quantityAvailable', NEW.quantity_available,
          'location', jsonb_build_object(
            'latitude', business_location.latitude,
            'longitude', business_location.longitude,
            'address', business_location.address
          )
        ),
        jsonb_build_object(
          'source', 'deal_trigger',
          'version', '1.0',
          'urgency', 'high',
          'notificationRadius', 3 -- Smaller radius for urgent notifications
        )
      );
    END IF;
    
  ELSIF TG_OP = 'UPDATE' THEN
    -- Check for quantity changes (sold out)
    IF OLD.quantity_available > 0 AND NEW.quantity_available = 0 AND NEW.is_active = true THEN
      INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
      VALUES (
        'DEAL_SOLD_OUT',
        'Deal sold out',
        jsonb_build_object(
          'dealId', NEW.id,
          'businessId', NEW.business_id,
          'businessName', business_location.name,
          'title', NEW.title,
          'totalSold', NEW.quantity_total,
          'soldOutAt', CURRENT_TIMESTAMP
        ),
        jsonb_build_object(
          'source', 'deal_trigger',
          'version', '1.0',
          'triggerType', 'UPDATE'
        )
      );
    END IF;
    
    -- Check for status changes (deactivated)
    IF OLD.is_active = true AND NEW.is_active = false THEN
      INSERT INTO public.event_queue (event_type, event_name, payload, metadata)
      VALUES (
        'DEAL_EXPIRED',
        'Deal expired or deactivated',
        jsonb_build_object(
          'dealId', NEW.id,
          'businessId', NEW.business_id,
          'title', NEW.title,
          'deactivatedAt', CURRENT_TIMESTAMP,
          'reason', CASE 
            WHEN NEW.expires_at <= CURRENT_TIMESTAMP THEN 'expired'
            ELSE 'manually_deactivated'
          END
        ),
        jsonb_build_object(
          'source', 'deal_trigger',
          'version', '1.0',
          'triggerType', 'UPDATE'
        )
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for deal events
CREATE TRIGGER deal_event_trigger
AFTER INSERT OR UPDATE ON public.deals
FOR EACH ROW
EXECUTE FUNCTION public.create_deal_event();

-- Create function to update event queue status
CREATE OR REPLACE FUNCTION public.update_event_queue_status(
  p_event_id UUID,
  p_status VARCHAR(20),
  p_error_message TEXT DEFAULT NULL,
  p_error_details JSONB DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
  updated_count INTEGER;
BEGIN
  UPDATE public.event_queue
  SET 
    status = p_status,
    processed_at = CASE WHEN p_status = 'processed' THEN CURRENT_TIMESTAMP ELSE processed_at END,
    error_message = p_error_message,
    error_details = p_error_details,
    retry_count = CASE WHEN p_status = 'retry' THEN retry_count + 1 ELSE retry_count END,
    next_retry_at = CASE 
      WHEN p_status = 'retry' THEN CURRENT_TIMESTAMP + (INTERVAL '1 minute' * POWER(2, retry_count + 1))
      ELSE next_retry_at 
    END
  WHERE id = p_event_id;
  
  GET DIAGNOSTICS updated_count = ROW_COUNT;
  RETURN updated_count > 0;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get pending events for processing
CREATE OR REPLACE FUNCTION public.get_pending_events(p_limit INTEGER DEFAULT 10)
RETURNS TABLE(
  id UUID,
  event_type VARCHAR(100),
  event_name VARCHAR(200),
  payload JSONB,
  metadata JSONB,
  created_at TIMESTAMP WITH TIME ZONE,
  retry_count INTEGER
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    eq.id,
    eq.event_type,
    eq.event_name,
    eq.payload,
    eq.metadata,
    eq.created_at,
    eq.retry_count
  FROM public.event_queue eq
  WHERE eq.status IN ('pending', 'retry')
    AND (eq.next_retry_at IS NULL OR eq.next_retry_at <= CURRENT_TIMESTAMP)
    AND eq.retry_count < eq.max_retries
  ORDER BY eq.created_at ASC
  LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Grant execute permissions
GRANT EXECUTE ON FUNCTION public.update_event_queue_status TO service_role;
GRANT EXECUTE ON FUNCTION public.get_pending_events TO service_role;

-- Comments for documentation
COMMENT ON FUNCTION public.notify_event_queue_webhook IS 'Sends webhook notification when new event is queued';
COMMENT ON FUNCTION public.create_order_event IS 'Automatically creates events for order status changes';
COMMENT ON FUNCTION public.create_deal_event IS 'Automatically creates events for deal creation and updates';
COMMENT ON FUNCTION public.update_event_queue_status IS 'Updates event processing status from webhook handler';
COMMENT ON FUNCTION public.get_pending_events IS 'Gets pending events for processing';