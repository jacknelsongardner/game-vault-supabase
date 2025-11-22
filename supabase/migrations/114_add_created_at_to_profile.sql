-- Add created_at column to profile table
ALTER TABLE profile
ADD COLUMN created_at TIMESTAMPTZ DEFAULT NOW();

-- Update existing rows to use the auth.users created_at if available
UPDATE profile
SET created_at = auth.users.created_at
FROM auth.users
WHERE profile.auth_id = auth.users.id;
