-- Enable Row Level Security on post tables
ALTER TABLE post ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_reaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE post_comment ENABLE ROW LEVEL SECURITY;
ALTER TABLE comment_reaction ENABLE ROW LEVEL SECURITY;

-- Post policies
-- Everyone can view all posts
CREATE POLICY "Posts are viewable by everyone"
ON post FOR SELECT
USING (true);

-- Authenticated users can create posts
CREATE POLICY "Authenticated users can create posts"
ON post FOR INSERT
WITH CHECK (auth.uid() = profile_id);

-- Users can update their own posts
CREATE POLICY "Users can update their own posts"
ON post FOR UPDATE
USING (auth.uid() = profile_id)
WITH CHECK (auth.uid() = profile_id);

-- Users can delete their own posts
CREATE POLICY "Users can delete their own posts"
ON post FOR DELETE
USING (auth.uid() = profile_id);

-- Post Reaction (Likes) policies
-- Everyone can view reactions
CREATE POLICY "Reactions are viewable by everyone"
ON post_reaction FOR SELECT
USING (true);

-- Authenticated users can like posts
CREATE POLICY "Authenticated users can like posts"
ON post_reaction FOR INSERT
WITH CHECK (auth.uid() = profile_id);

-- Users can unlike their own reactions
CREATE POLICY "Users can unlike their own reactions"
ON post_reaction FOR DELETE
USING (auth.uid() = profile_id);

-- Post Comment policies
-- Everyone can view comments
CREATE POLICY "Comments are viewable by everyone"
ON post_comment FOR SELECT
USING (true);

-- Authenticated users can create comments
CREATE POLICY "Authenticated users can create comments"
ON post_comment FOR INSERT
WITH CHECK (auth.uid() = profile_id);

-- Users can update their own comments
CREATE POLICY "Users can update their own comments"
ON post_comment FOR UPDATE
USING (auth.uid() = profile_id)
WITH CHECK (auth.uid() = profile_id);

-- Users can delete their own comments
CREATE POLICY "Users can delete their own comments"
ON post_comment FOR DELETE
USING (auth.uid() = profile_id);

-- Comment Reaction policies
-- Everyone can view comment reactions
CREATE POLICY "Comment reactions are viewable by everyone"
ON comment_reaction FOR SELECT
USING (true);

-- Authenticated users can like comments
CREATE POLICY "Authenticated users can like comments"
ON comment_reaction FOR INSERT
WITH CHECK (auth.uid() = profile_id);

-- Users can unlike their own comment reactions
CREATE POLICY "Users can unlike their own comment reactions"
ON comment_reaction FOR DELETE
USING (auth.uid() = profile_id);
