-- Table for post reactions (likes)
CREATE TABLE post_reaction (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES post(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reaction_type TEXT DEFAULT 'like',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(post_id, profile_id)
);

-- Table for post comments
CREATE TABLE post_comment (
    id SERIAL PRIMARY KEY,
    post_id INTEGER NOT NULL REFERENCES post(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Table for comment reactions (likes)
CREATE TABLE comment_reaction (
    id SERIAL PRIMARY KEY,
    comment_id INTEGER NOT NULL REFERENCES post_comment(id) ON DELETE CASCADE,
    profile_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    reaction_type TEXT DEFAULT 'like',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(comment_id, profile_id)
);

-- Indexes for better query performance
CREATE INDEX idx_post_reaction_post_id ON post_reaction(post_id);
CREATE INDEX idx_post_reaction_profile_id ON post_reaction(profile_id);
CREATE INDEX idx_post_comment_post_id ON post_comment(post_id);
CREATE INDEX idx_post_comment_profile_id ON post_comment(profile_id);
CREATE INDEX idx_comment_reaction_comment_id ON comment_reaction(comment_id);
CREATE INDEX idx_comment_reaction_profile_id ON comment_reaction(profile_id);
