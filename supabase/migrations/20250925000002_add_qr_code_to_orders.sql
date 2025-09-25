-- Update order workflow to simplified 3-state flow
-- Orders: pending → confirmed → completed

-- Update order status constraints for simplified workflow
ALTER TABLE public.orders DROP CONSTRAINT IF EXISTS orders_status_check;
ALTER TABLE public.orders ADD CONSTRAINT orders_status_check 
CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled'));