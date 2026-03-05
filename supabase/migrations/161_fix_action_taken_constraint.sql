-- Migration: Fix content_violation action_taken constraint
--
-- Migration 160 intended to rename 'account_deactivated' → 'account_banned' in the
-- action_taken CHECK constraint, but it dropped the wrong constraint name
-- ('content_violation_action_taken_check') while the real constraint from migration 157
-- is named 'violation_action_check'. This left the old constraint in place, causing
-- any insert with action_taken = 'account_banned' to fail silently.

-- Drop the original (incorrectly-named) constraint from migration 157
ALTER TABLE content_violation DROP CONSTRAINT IF EXISTS violation_action_check;

-- The correct constraint ('content_violation_action_taken_check') was already added
-- by migration 160 and includes 'account_banned', so no need to re-add it.
