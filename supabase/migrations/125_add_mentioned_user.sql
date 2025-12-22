-- Add mentioned_user_id to post_comment for @mentions
-- When replying to a reply (level 1), we create a reply to the parent comment (level 0)
-- and use mentioned_user_id to reference who was being replied to

ALTER TABLE post_comment
ADD COLUMN IF NOT EXISTS mentioned_user_id UUID NULL REFERENCES auth.users(id) ON DELETE SET NULL;

CREATE INDEX IF NOT EXISTS idx_post_comment_mentioned_user_id ON post_comment(mentioned_user_id);

COMMENT ON COLUMN post_comment.mentioned_user_id IS 'When replying to a reply, this stores the auth_id of the reply author being mentioned';
