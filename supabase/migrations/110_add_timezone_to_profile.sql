-- Add timezone column to profile table
ALTER TABLE profile
ADD COLUMN IF NOT EXISTS timezone TEXT;
