-- Add e2e_request_id column to event_queue table for request tracking
-- This enables end-to-end request tracking from client through events to notifications

-- Add e2e_request_id column to event_queue table
ALTER TABLE public.event_queue ADD COLUMN IF NOT EXISTS e2e_request_id VARCHAR(50);

-- Create index for better performance on e2e_request_id lookups
CREATE INDEX IF NOT EXISTS idx_event_queue_e2e_request_id ON public.event_queue(e2e_request_id);

-- Add comment for documentation
COMMENT ON COLUMN public.event_queue.e2e_request_id IS 'End-to-end request tracking ID from client to enable request correlation and debugging across the event processing pipeline';