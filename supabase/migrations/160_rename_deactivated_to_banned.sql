-- Rename 'deactivated' → 'banned' for clarity.
-- Also fixes the atomic warning increment RPC and adds suspend/ban helpers.

-- 1. Drop and recreate the CHECK constraint on profile.account_status
ALTER TABLE profile DROP CONSTRAINT IF EXISTS profile_account_status_check;
ALTER TABLE profile
  ADD CONSTRAINT profile_account_status_check
  CHECK (account_status IN ('active', 'suspended', 'banned'));

-- 2. Rename existing 'deactivated' rows to 'banned'
UPDATE profile SET account_status = 'banned' WHERE account_status = 'deactivated';

-- 3. Update the ActionTaken enum-like check in content_violation if present
ALTER TABLE content_violation DROP CONSTRAINT IF EXISTS content_violation_action_taken_check;
ALTER TABLE content_violation
  ADD CONSTRAINT content_violation_action_taken_check
  CHECK (action_taken IN (
    'censored', 'flagged', 'rejected', 'warning_issued', 'account_banned'
  ));

UPDATE content_violation SET action_taken = 'account_banned' WHERE action_taken = 'account_deactivated';

-- 4. Replace the atomic increment RPC to use 'banned' instead of 'deactivated'
CREATE OR REPLACE FUNCTION increment_warning_count(p_user_id uuid)
RETURNS TABLE(new_count integer, account_deactivated boolean)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_new_count   integer;
  v_banned      boolean;
BEGIN
  UPDATE profile
  SET
    warning_count  = warning_count + 1,
    account_status = CASE
                       WHEN warning_count + 1 >= 3 THEN 'banned'
                       ELSE account_status
                     END
  WHERE auth_id = p_user_id
  RETURNING
    warning_count,
    (warning_count >= 3)
  INTO v_new_count, v_banned;

  -- column name kept as account_deactivated for backward compat with existing TS code
  RETURN QUERY SELECT v_new_count, v_banned;
END;
$$;
