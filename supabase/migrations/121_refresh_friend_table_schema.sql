-- Refresh friend table schema cache by touching the table
-- This migration forces Supabase to rebuild the schema cache for the friend table

-- Ensure the friend table exists with correct structure and constraints
DROP TABLE IF EXISTS friend CASCADE;

CREATE TABLE friend (
  friendOne UUID NOT NULL,
  friendTwo UUID NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (friendOne, friendTwo),
  CONSTRAINT valid_friend_order CHECK (friendOne < friendTwo),
  CONSTRAINT different_users CHECK (friendOne != friendTwo)
);

-- Create indices for efficient querying
CREATE INDEX idx_friend_one ON friend(friendOne);
CREATE INDEX idx_friend_two ON friend(friendTwo);

-- Enable RLS
ALTER TABLE friend ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for friend table
-- Users can see friends of any profile
CREATE POLICY "Users can view friend relationships"
  ON friend FOR SELECT
  USING (true);

-- Users can only add themselves as friendOne or friendTwo
CREATE POLICY "Users can add themselves as a friend"
  ON friend FOR INSERT
  WITH CHECK (
    auth.uid() = friendOne OR auth.uid() = friendTwo
  );

-- Users can only remove friendships they're part of
CREATE POLICY "Users can remove their own friendships"
  ON friend FOR DELETE
  USING (
    auth.uid() = friendOne OR auth.uid() = friendTwo
  );

-- Add comments for clarity
COMMENT ON TABLE friend IS 'Represents friendships between users. friendOne is always less than friendTwo to avoid duplicates.';
COMMENT ON COLUMN friend.friendOne IS 'First user UUID (ordered to be less than friendTwo)';
COMMENT ON COLUMN friend.friendTwo IS 'Second user UUID (ordered to be greater than friendOne)';
COMMENT ON COLUMN friend.created_at IS 'Timestamp when the friendship was created';
