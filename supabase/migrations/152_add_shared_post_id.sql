-- Add shared_post_id column to post table to track shared posts
-- When a user shares a post, a new post is created with shared_post_id referencing the original post

ALTER TABLE post ADD COLUMN IF NOT EXISTS shared_post_id INTEGER DEFAULT NULL REFERENCES post(id) ON DELETE CASCADE;

-- Add index for performance when querying shared posts
CREATE INDEX IF NOT EXISTS idx_post_shared_post_id ON post(shared_post_id);

-- Add comment to explain the column
COMMENT ON COLUMN post.shared_post_id IS 'References the original post ID when this post is a share';
