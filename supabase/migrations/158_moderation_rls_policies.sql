-- Migration: RLS policies for content moderation

-- Enable RLS on content_violation
ALTER TABLE content_violation ENABLE ROW LEVEL SECURITY;

-- Users can view their own violations
CREATE POLICY "Users can view own violations"
ON content_violation
FOR SELECT
USING (auth.uid() = profile_id);

-- Service role has full access (used by moderation system)
-- (service_role bypasses RLS by default, no explicit policy needed)

-- Admins can view all violations
CREATE POLICY "Admins can view all violations"
ON content_violation
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM profile
        WHERE profile.auth_id = auth.uid()
        AND profile.is_admin = true
    )
);

-- Admins can update violations (review decisions)
CREATE POLICY "Admins can update violations"
ON content_violation
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM profile
        WHERE profile.auth_id = auth.uid()
        AND profile.is_admin = true
    )
);

-- Update post SELECT policy: hide rejected posts from non-admin users
-- First drop existing policy if it exists, then recreate
DROP POLICY IF EXISTS "Posts are viewable by everyone" ON post;

CREATE POLICY "Posts are viewable by everyone"
ON post
FOR SELECT
USING (
    moderation_status != 'rejected'
    OR profile_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM profile
        WHERE profile.auth_id = auth.uid()
        AND profile.is_admin = true
    )
);

-- Update comment SELECT policy: hide rejected comments from non-admin users
DROP POLICY IF EXISTS "Comments are viewable by everyone" ON post_comment;

CREATE POLICY "Comments are viewable by everyone"
ON post_comment
FOR SELECT
USING (
    moderation_status != 'rejected'
    OR profile_id = auth.uid()
    OR EXISTS (
        SELECT 1 FROM profile
        WHERE profile.auth_id = auth.uid()
        AND profile.is_admin = true
    )
);

-- Admins can update any post's moderation status
CREATE POLICY "Admins can update post moderation"
ON post
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM profile
        WHERE profile.auth_id = auth.uid()
        AND profile.is_admin = true
    )
);

-- Admins can update any comment's moderation status
CREATE POLICY "Admins can update comment moderation"
ON post_comment
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM profile
        WHERE profile.auth_id = auth.uid()
        AND profile.is_admin = true
    )
);

-- Admins can update any profile (for account status changes)
CREATE POLICY "Admins can update any profile"
ON profile
FOR UPDATE
USING (
    EXISTS (
        SELECT 1 FROM profile AS admin_profile
        WHERE admin_profile.auth_id = auth.uid()
        AND admin_profile.is_admin = true
    )
);
