-- Migration: Add content moderation columns to existing tables
-- Adds moderation_status to posts/comments, account management fields to profile

-- Add moderation status to posts
ALTER TABLE post
ADD COLUMN moderation_status TEXT NOT NULL DEFAULT 'clean';

-- Add moderation status to comments
ALTER TABLE post_comment
ADD COLUMN moderation_status TEXT NOT NULL DEFAULT 'clean';

-- Add account moderation fields to profile
ALTER TABLE profile
ADD COLUMN account_status TEXT NOT NULL DEFAULT 'active',
ADD COLUMN warning_count INTEGER NOT NULL DEFAULT 0,
ADD COLUMN show_profanity BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN is_admin BOOLEAN NOT NULL DEFAULT false;

-- Add check constraints for valid statuses
ALTER TABLE post
ADD CONSTRAINT post_moderation_status_check
CHECK (moderation_status IN ('clean', 'flagged', 'rejected'));

ALTER TABLE post_comment
ADD CONSTRAINT comment_moderation_status_check
CHECK (moderation_status IN ('clean', 'flagged', 'rejected'));

ALTER TABLE profile
ADD CONSTRAINT profile_account_status_check
CHECK (account_status IN ('active', 'suspended', 'deactivated'));

-- Index for quickly finding flagged content
CREATE INDEX idx_post_moderation_status ON post(moderation_status) WHERE moderation_status != 'clean';
CREATE INDEX idx_comment_moderation_status ON post_comment(moderation_status) WHERE moderation_status != 'clean';
CREATE INDEX idx_profile_account_status ON profile(account_status) WHERE account_status != 'active';
