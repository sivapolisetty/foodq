-- Rollback: Remove e2e_request_id column from orders table
-- The e2e_request_id should be stored in event_queue table instead

-- Remove the incorrectly added e2e_request_id column from orders table
ALTER TABLE orders DROP COLUMN IF EXISTS e2e_request_id;

-- Remove the index if it exists
DROP INDEX IF EXISTS idx_orders_e2e_request_id;