-- Remove foreign key constraint for hybrid mode
-- In hybrid mode, auth.users exists in cloud but not locally
ALTER TABLE app_users DROP CONSTRAINT IF EXISTS app_users_id_fkey;

-- Add a comment explaining why there's no FK constraint
COMMENT ON COLUMN app_users.id IS 'User ID from cloud Supabase auth.users (no FK in hybrid mode)';