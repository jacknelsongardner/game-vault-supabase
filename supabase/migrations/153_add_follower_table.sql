-- =====================================================
-- Follower System: Triggers & Helper Functions
-- =====================================================
-- follower table + indexes   → 000_profile.sql
-- RLS policies               → 102_rls_policies.sql
-- get_closest_friends update → 142_function_friends_genre.sql
-- This migration adds the count-maintenance trigger and query helpers.
-- =====================================================

-- =====================================================
-- Trigger: Keep follower_count / following_count in sync
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

CREATE TRIGGER trigger_update_follower_counts
AFTER INSERT OR DELETE ON follower
FOR EACH ROW EXECUTE FUNCTION update_follower_counts();

-- =====================================================
-- Helper: is_following(user_a, user_b) → boolean
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
-- Helper: are_mutual_followers(user_a, user_b) → boolean
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
-- Helper: get_mutual_followers(user_a, user_b) → table
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
