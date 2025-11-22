-- Add banner_url column to profile table
ALTER TABLE profile
ADD COLUMN IF NOT EXISTS banner_url TEXT;

-- Add comment explaining the column
COMMENT ON COLUMN profile.banner_url IS 'URL to the user profile banner image stored in Supabase Storage';
