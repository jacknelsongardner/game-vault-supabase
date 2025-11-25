-- Add foreign key relationship between post and profile
-- This allows Supabase PostgREST to automatically join these tables

-- First, add the foreign key constraint
ALTER TABLE post 
ADD CONSTRAINT post_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES profile(auth_id) 
ON DELETE CASCADE;

-- Add an index for better query performance
CREATE INDEX IF NOT EXISTS idx_post_profile_id ON post(profile_id);
