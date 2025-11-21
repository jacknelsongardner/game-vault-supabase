-- Add timezone column to profile table
ALTER TABLE profile
ADD COLUMN IF NOT EXISTS timezone TEXT;

-- Remove first_name, last_name, and birthday columns if they exist
-- Note: Only run these if you want to completely remove the old fields
-- Comment these out if you want to keep them for backwards compatibility
ALTER TABLE profile DROP COLUMN IF EXISTS first_name;
ALTER TABLE profile DROP COLUMN IF EXISTS last_name;
ALTER TABLE profile DROP COLUMN IF EXISTS birthday;
