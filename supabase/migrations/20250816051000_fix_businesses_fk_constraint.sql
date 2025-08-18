-- Remove businesses foreign key constraint for hybrid mode
-- In hybrid mode, auth.users exists in cloud but not locally

-- Check and remove foreign key constraint from businesses table
ALTER TABLE businesses DROP CONSTRAINT IF EXISTS businesses_owner_id_fkey;

-- Add a comment explaining why there's no FK constraint
COMMENT ON COLUMN businesses.owner_id IS 'User ID from cloud Supabase auth.users (no FK in hybrid mode)';