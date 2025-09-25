-- Apply missing migrations to production database

-- Step 1: Add e2e_request_id column to event_queue table
ALTER TABLE public.event_queue ADD COLUMN IF NOT EXISTS e2e_request_id VARCHAR(50);

-- Step 2: Create index for better performance on e2e_request_id lookups
CREATE INDEX IF NOT EXISTS idx_event_queue_e2e_request_id ON public.event_queue(e2e_request_id);

-- Step 3: Add comment for documentation
COMMENT ON COLUMN public.event_queue.e2e_request_id IS 'End-to-end request tracking ID from client to enable request correlation and debugging across the event processing pipeline';

-- Step 4: Fix the create_order_event trigger to use app_users instead of auth.users
CREATE OR REPLACE FUNCTION public.create_order_event()
RETURNS TRIGGER AS $$
DECLARE
  business_info RECORD;
  customer_info RECORD;
  event_payload JSONB;
  e2e_request_id_var TEXT;
BEGIN
  -- Try to get e2e_request_id from session variable
  e2e_request_id_var := current_setting('app.e2e_request_id', true);
  
  -- Get business and customer information
  SELECT b.name, b.owner_id, b.latitude, b.longitude, b.address
  INTO business_info
  FROM public.businesses b
  WHERE b.id = NEW.business_id;
  
  -- FIXED: Query app_users instead of auth.users
  SELECT u.email, u.name
  INTO customer_info
  FROM public.app_users u
  WHERE u.id = NEW.user_id;
  
  IF TG_OP = 'INSERT' THEN
    -- Create ORDER_CREATED event with e2e_request_id
    INSERT INTO public.event_queue (event_type, event_name, payload, metadata, e2e_request_id)
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
        'triggerType', 'INSERT',
        'e2eRequestId', e2e_request_id_var
      ),
      e2e_request_id_var
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
        
        -- Create status change event with e2e_request_id
        INSERT INTO public.event_queue (event_type, event_name, payload, metadata, e2e_request_id)
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
            'previousStatus', OLD.status,
            'e2eRequestId', e2e_request_id_var
          ),
          e2e_request_id_var
        );
      END;
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;