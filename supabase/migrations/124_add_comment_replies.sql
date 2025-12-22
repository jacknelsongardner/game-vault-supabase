-- Add 1-level reply support to post_comment
-- Structure: Post -> Comments (level 0); Comment -> Replies (level 1)
-- No deeper nesting allowed.

-- 1) Schema changes: add parent_comment_id with FK and helpful index
ALTER TABLE post_comment
ADD COLUMN IF NOT EXISTS parent_comment_id INTEGER NULL REFERENCES post_comment(id) ON DELETE CASCADE;

CREATE INDEX IF NOT EXISTS idx_post_comment_parent_comment_id ON post_comment(parent_comment_id);

-- Prevent self-referencing parent
ALTER TABLE post_comment
ADD CONSTRAINT IF NOT EXISTS post_comment_no_self_parent CHECK (
  parent_comment_id IS NULL OR parent_comment_id <> id
);

-- 2) Business rules enforced via trigger:
-- - If parent_comment_id is set, the parent must be a top-level comment (its parent_comment_id is NULL)
-- - If parent_comment_id is set, NEW.post_id must match parent's post_id
CREATE OR REPLACE FUNCTION enforce_post_comment_depth()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  parent_parent_id INTEGER;
  parent_post_id INTEGER;
BEGIN
  -- No parent: nothing to validate
  IF NEW.parent_comment_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Ensure referenced parent exists and is top-level; also capture its post_id
  SELECT pc.parent_comment_id, pc.post_id
    INTO parent_parent_id, parent_post_id
  FROM post_comment pc
  WHERE pc.id = NEW.parent_comment_id;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Parent comment % does not exist', NEW.parent_comment_id;
  END IF;

  -- Disallow replying to a reply (enforce max depth = 1)
  IF parent_parent_id IS NOT NULL THEN
    RAISE EXCEPTION 'Replies cannot be nested more than one level';
  END IF;

  -- Require reply to belong to the same post as the parent comment
  IF NEW.post_id IS DISTINCT FROM parent_post_id THEN
    RAISE EXCEPTION 'Reply must reference same post as its parent comment';
  END IF;

  RETURN NEW;
END;
$$;

-- Create/replace triggers for INSERT and relevant UPDATEs
DROP TRIGGER IF EXISTS trg_enforce_post_comment_depth_ins ON post_comment;
DROP TRIGGER IF EXISTS trg_enforce_post_comment_depth_upd ON post_comment;

CREATE TRIGGER trg_enforce_post_comment_depth_ins
BEFORE INSERT ON post_comment
FOR EACH ROW EXECUTE FUNCTION enforce_post_comment_depth();

-- Only fire when changing parent linkage or moving comment across posts
CREATE TRIGGER trg_enforce_post_comment_depth_upd
BEFORE UPDATE OF parent_comment_id, post_id ON post_comment
FOR EACH ROW EXECUTE FUNCTION enforce_post_comment_depth();
