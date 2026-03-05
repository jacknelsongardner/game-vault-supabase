-- Migration: Create content_violation table for tracking moderation actions

CREATE TABLE content_violation (
    id SERIAL PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content_type TEXT NOT NULL,
    content_id INTEGER,
    original_text TEXT NOT NULL,
    matched_terms TEXT[] NOT NULL DEFAULT '{}',
    severity TEXT NOT NULL,
    action_taken TEXT NOT NULL,
    reviewed BOOLEAN NOT NULL DEFAULT false,
    reviewed_by UUID REFERENCES auth.users(id),
    reviewed_at TIMESTAMPTZ,
    review_decision TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Constraints
ALTER TABLE content_violation
ADD CONSTRAINT violation_content_type_check
CHECK (content_type IN ('post', 'comment', 'share', 'profile', 'review', 'custom_field'));

ALTER TABLE content_violation
ADD CONSTRAINT violation_severity_check
CHECK (severity IN ('profanity', 'slur', 'ambiguous_slur'));

ALTER TABLE content_violation
ADD CONSTRAINT violation_action_check
CHECK (action_taken IN ('censored', 'flagged', 'rejected', 'warning_issued', 'account_deactivated'));

ALTER TABLE content_violation
ADD CONSTRAINT violation_review_decision_check
CHECK (review_decision IS NULL OR review_decision IN ('confirmed_violation', 'false_positive', 'escalated'));

-- Indexes
CREATE INDEX idx_violation_profile ON content_violation(profile_id);
CREATE INDEX idx_violation_unreviewed ON content_violation(reviewed) WHERE reviewed = false;
CREATE INDEX idx_violation_created ON content_violation(created_at DESC);
CREATE INDEX idx_violation_severity ON content_violation(severity);
