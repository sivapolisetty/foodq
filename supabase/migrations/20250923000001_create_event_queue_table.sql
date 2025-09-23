-- Migration: Create Event Queue Table
-- Description: Core event queue table that triggers all notifications
-- Version: 1.0
-- Date: 2025-09-23

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "http" SCHEMA extensions;

-- Create event_queue table
CREATE TABLE IF NOT EXISTS public.event_queue (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  
  -- Event identification
  event_type VARCHAR(100) NOT NULL,
  event_name VARCHAR(200) NOT NULL,
  event_version VARCHAR(10) DEFAULT '1.0',
  
  -- Event payload
  payload JSONB NOT NULL,
  metadata JSONB DEFAULT '{}',
  
  -- Processing status
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'processed', 'failed', 'retry')),
  retry_count INTEGER DEFAULT 0,
  max_retries INTEGER DEFAULT 3,
  
  -- Error tracking
  error_message TEXT,
  error_details JSONB,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  processed_at TIMESTAMP WITH TIME ZONE,
  next_retry_at TIMESTAMP WITH TIME ZONE,
  
  -- Event type constraints
  CONSTRAINT check_event_type CHECK (event_type IN (
    'ORDER_CREATED', 'ORDER_PAID', 'ORDER_CONFIRMED', 'ORDER_PREPARING', 
    'ORDER_READY', 'ORDER_COMPLETED', 'ORDER_CANCELLED',
    'DEAL_CREATED', 'DEAL_UPDATED', 'DEAL_EXPIRING', 'DEAL_EXPIRED',
    'BUSINESS_UPDATE', 'SYSTEM_ANNOUNCEMENT', 'LOCATION_BASED_DEAL'
  ))
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_event_queue_status 
ON public.event_queue(status, created_at) 
WHERE status IN ('pending', 'retry');

CREATE INDEX IF NOT EXISTS idx_event_queue_type 
ON public.event_queue(event_type, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_event_queue_retry 
ON public.event_queue(next_retry_at) 
WHERE status = 'retry';

CREATE INDEX IF NOT EXISTS idx_event_queue_processing 
ON public.event_queue(processed_at DESC) 
WHERE processed_at IS NOT NULL;

-- Enable RLS
ALTER TABLE public.event_queue ENABLE ROW LEVEL SECURITY;

-- RLS Policies
-- Allow service role to manage all events
CREATE POLICY "Service role can manage all events" ON public.event_queue
FOR ALL USING (auth.role() = 'service_role');

-- Allow authenticated users to view their related events (we'll refine this later)
CREATE POLICY "Users can view related events" ON public.event_queue
FOR SELECT USING (auth.role() = 'authenticated');

-- Grant permissions
GRANT ALL ON public.event_queue TO service_role;
GRANT SELECT ON public.event_queue TO authenticated;

-- Comments for documentation
COMMENT ON TABLE public.event_queue IS 'Core event queue that triggers all notification processing';
COMMENT ON COLUMN public.event_queue.event_type IS 'Type of event (ORDER_CREATED, DEAL_CREATED, etc.)';
COMMENT ON COLUMN public.event_queue.payload IS 'Event data in JSON format';
COMMENT ON COLUMN public.event_queue.status IS 'Processing status: pending, processing, processed, failed, retry';
COMMENT ON COLUMN public.event_queue.retry_count IS 'Number of retry attempts made';
COMMENT ON COLUMN public.event_queue.metadata IS 'Additional event metadata and context';