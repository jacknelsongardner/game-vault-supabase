create extension if not exists vector;


-- Profile
CREATE TABLE profile (
    auth_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    id INTEGER UNIQUE GENERATED ALWAYS AS IDENTITY, 
    username TEXT UNIQUE,
    search_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    follower_count INTEGER NOT NULL DEFAULT 0,
    following_count INTEGER NOT NULL DEFAULT 0
);

-- One-directional follower relationship (follower_id follows following_id)
CREATE TABLE follower (
    follower_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    PRIMARY KEY (follower_id, following_id),
    CHECK (follower_id != following_id)
);

CREATE INDEX idx_follower_follower_id ON follower(follower_id);
CREATE INDEX idx_follower_following_id ON follower(following_id);
CREATE INDEX idx_follower_created_at ON follower(created_at DESC);

-- Badge
CREATE TABLE badge (
    id INTEGER PRIMARY KEY,
    name TEXT,
    code TEXT,
    icon_url TEXT,
    description TEXT
);

-- BadgesEarned
CREATE TABLE badges_earned (
    profile_id UUID REFERENCES auth.users(id),
    badge_id INTEGER REFERENCES badge(id),
    PRIMARY KEY (profile_id, badge_id)
);

-- Create storage bucket if not exists
insert into storage.buckets (id, name, public)
select 'profile-photos', 'profile-photos', true
where not exists (
  select 1 from storage.buckets where id = 'profile-photos'
);
