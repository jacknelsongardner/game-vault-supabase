-- =====================================================
-- Follower System (self-contained upgrade migration)
-- =====================================================
-- Replaces the old bidirectional `friend` table with a
-- one-directional `follower` table, adds cached count
-- columns to profile, applies RLS, and installs the
-- count-maintenance trigger and query helper functions.
-- =====================================================

-- =====================================================
-- 1. Drop the old friend table and its RLS policies
-- =====================================================

DROP TABLE IF EXISTS friend CASCADE;

-- =====================================================
-- 2. Create the follower table
-- =====================================================

CREATE TABLE IF NOT EXISTS follower (
    follower_id  UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at   TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, following_id),
    CHECK (follower_id != following_id)
);

CREATE INDEX IF NOT EXISTS idx_follower_follower_id ON follower(follower_id);
CREATE INDEX IF NOT EXISTS idx_follower_following_id ON follower(following_id);
CREATE INDEX IF NOT EXISTS idx_follower_created_at   ON follower(created_at DESC);

-- =====================================================
-- 3. Add cached count columns to profile
-- =====================================================

ALTER TABLE profile
    ADD COLUMN IF NOT EXISTS follower_count  INTEGER NOT NULL DEFAULT 0,
    ADD COLUMN IF NOT EXISTS following_count INTEGER NOT NULL DEFAULT 0;

-- =====================================================
-- 4. RLS for follower table
-- =====================================================

ALTER TABLE follower ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Follower relationships are viewable by everyone" ON follower;
DROP POLICY IF EXISTS "Users can follow others"   ON follower;
DROP POLICY IF EXISTS "Users can unfollow others" ON follower;

CREATE POLICY "Follower relationships are viewable by everyone"
    ON follower FOR SELECT USING (true);

CREATE POLICY "Users can follow others"
    ON follower FOR INSERT WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can unfollow others"
    ON follower FOR DELETE USING (auth.uid() = follower_id);

-- =====================================================
-- 5. Trigger: Keep follower_count / following_count in sync
-- =====================================================

CREATE OR REPLACE FUNCTION update_follower_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE profile SET following_count = following_count + 1 WHERE auth_id = NEW.follower_id;
        UPDATE profile SET follower_count  = follower_count  + 1 WHERE auth_id = NEW.following_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE profile SET following_count = GREATEST(following_count - 1, 0) WHERE auth_id = OLD.follower_id;
        UPDATE profile SET follower_count  = GREATEST(follower_count  - 1, 0) WHERE auth_id = OLD.following_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_follower_counts ON follower;
CREATE TRIGGER trigger_update_follower_counts
AFTER INSERT OR DELETE ON follower
FOR EACH ROW EXECUTE FUNCTION update_follower_counts();

-- =====================================================
-- 6. Helper: is_following(user_a, user_b) → boolean
-- =====================================================

CREATE OR REPLACE FUNCTION is_following(user_a UUID, user_b UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM follower
        WHERE follower_id = user_a AND following_id = user_b
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- 7. Helper: are_mutual_followers(user_a, user_b) → boolean
-- =====================================================

CREATE OR REPLACE FUNCTION are_mutual_followers(user_a UUID, user_b UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM follower WHERE follower_id = user_a AND following_id = user_b
    )
    AND EXISTS (
        SELECT 1 FROM follower WHERE follower_id = user_b AND following_id = user_a
    );
END;
$$ LANGUAGE plpgsql STABLE;

-- =====================================================
-- 8. Helper: get_mutual_followers(user_a, user_b) → table
-- Returns users that both user_a and user_b follow
-- =====================================================

CREATE OR REPLACE FUNCTION get_mutual_followers(user_a UUID, user_b UUID)
RETURNS TABLE(mutual_user_id UUID) AS $$
BEGIN
    RETURN QUERY
    SELECT f1.following_id
    FROM follower f1
    WHERE f1.follower_id = user_a
    INTERSECT
    SELECT f2.following_id
    FROM follower f2
    WHERE f2.follower_id = user_b;
END;
$$ LANGUAGE plpgsql STABLE;
