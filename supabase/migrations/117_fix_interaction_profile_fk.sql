-- Add foreign key relationships for post_reaction and post_comment to profile table
-- This allows Supabase PostgREST to automatically join these tables with profile

-- Drop existing foreign key constraints that reference auth.users
ALTER TABLE post_reaction 
DROP CONSTRAINT IF EXISTS post_reaction_profile_id_fkey;

ALTER TABLE post_comment 
DROP CONSTRAINT IF EXISTS post_comment_profile_id_fkey;

ALTER TABLE comment_reaction 
DROP CONSTRAINT IF EXISTS comment_reaction_profile_id_fkey;

-- Add new foreign key constraints that reference profile table
ALTER TABLE post_reaction 
ADD CONSTRAINT post_reaction_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES profile(auth_id) 
ON DELETE CASCADE;

ALTER TABLE post_comment 
ADD CONSTRAINT post_comment_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES profile(auth_id) 
ON DELETE CASCADE;

ALTER TABLE comment_reaction 
ADD CONSTRAINT comment_reaction_profile_id_fkey 
FOREIGN KEY (profile_id) 
REFERENCES profile(auth_id) 
ON DELETE CASCADE;
