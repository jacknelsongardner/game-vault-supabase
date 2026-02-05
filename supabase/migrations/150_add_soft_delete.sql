-- Add soft delete support to posts and comments
-- Allows users to delete their content while preserving conversation structure

-- Add soft delete columns to post table
ALTER TABLE post
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ NULL,
ADD COLUMN IF NOT EXISTS deleted_by_user BOOLEAN DEFAULT true;

-- Add soft delete columns to post_comment table
ALTER TABLE post_comment
ADD COLUMN IF NOT EXISTS deleted_at TIMESTAMPTZ NULL,
ADD COLUMN IF NOT EXISTS deleted_by_user BOOLEAN DEFAULT true;

-- Create indexes for efficient querying of non-deleted content
CREATE INDEX IF NOT EXISTS idx_post_deleted_at ON post(deleted_at) WHERE deleted_at IS NULL;
CREATE INDEX IF NOT EXISTS idx_post_comment_deleted_at ON post_comment(deleted_at) WHERE deleted_at IS NULL;

-- Comments on the columns for documentation
COMMENT ON COLUMN post.deleted_at IS 'Timestamp when the post was soft deleted. NULL means not deleted.';
COMMENT ON COLUMN post.deleted_by_user IS 'TRUE if deleted by the user themselves, FALSE if deleted by moderator/admin.';
COMMENT ON COLUMN post_comment.deleted_at IS 'Timestamp when the comment was soft deleted. NULL means not deleted.';
COMMENT ON COLUMN post_comment.deleted_by_user IS 'TRUE if deleted by the user themselves, FALSE if deleted by moderator/admin.';
