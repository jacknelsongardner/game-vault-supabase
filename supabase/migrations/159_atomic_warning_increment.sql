-- Atomic warning increment function.
-- Increments warning_count in a single UPDATE...RETURNING, preventing
-- race conditions from the prior SELECT + UPDATE two-step pattern.
CREATE OR REPLACE FUNCTION increment_warning_count(p_user_id uuid)
RETURNS TABLE(new_count integer, account_deactivated boolean)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_new_count   integer;
  v_deactivated boolean;
BEGIN
  UPDATE profile
  SET
    warning_count  = warning_count + 1,
    account_status = CASE
                       WHEN warning_count + 1 >= 3 THEN 'deactivated'
                       ELSE account_status
                     END
  WHERE auth_id = p_user_id
  RETURNING
    warning_count,
    (warning_count >= 3)
  INTO v_new_count, v_deactivated;

  RETURN QUERY SELECT v_new_count, v_deactivated;
END;
$$;
