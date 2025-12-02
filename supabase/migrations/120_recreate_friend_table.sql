-- Drop and recreate friend table to refresh schema cache
-- This is a fresh start approach

DROP TABLE IF EXISTS friend CASCADE;

CREATE TABLE friend (
    friendOne UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    friendTwo UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    PRIMARY KEY (friendOne, friendTwo)
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_friend_one ON friend(friendOne);
CREATE INDEX IF NOT EXISTS idx_friend_two ON friend(friendTwo);

-- Enable Row Level Security
ALTER TABLE friend ENABLE ROW LEVEL SECURITY;

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

-- Grant permissions
GRANT SELECT, INSERT, DELETE ON friend TO authenticated;
GRANT SELECT ON friend TO anon;
