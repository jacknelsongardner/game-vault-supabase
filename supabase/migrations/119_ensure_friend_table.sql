-- Ensure friend table exists with correct columns
-- If it doesn't exist, create it; if it does, this is safe to run

CREATE TABLE IF NOT EXISTS friend (
    friendOne UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    friendTwo UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    PRIMARY KEY (friendOne, friendTwo)
);

-- Ensure RLS is enabled
ALTER TABLE friend ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own friendships" ON friend;
DROP POLICY IF EXISTS "Users can create friendships for themselves" ON friend;
DROP POLICY IF EXISTS "Users can delete their own friendships" ON friend;

-- Create RLS policies
CREATE POLICY "Users can view their own friendships"
ON friend FOR SELECT
USING (auth.uid() = friendOne OR auth.uid() = friendTwo);

CREATE POLICY "Users can create friendships for themselves"
ON friend FOR INSERT
WITH CHECK (auth.uid() = friendOne OR auth.uid() = friendTwo);

CREATE POLICY "Users can delete their own friendships"
ON friend FOR DELETE
USING (auth.uid() = friendOne OR auth.uid() = friendTwo);
