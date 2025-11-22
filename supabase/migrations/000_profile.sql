
-- Profile
CREATE TABLE profile (
    auth_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    id INTEGER UNIQUE GENERATED ALWAYS AS IDENTITY, 
    username TEXT UNIQUE,
    search_name TEXT,
    avatar_url TEXT,
    bio TEXT
);

CREATE TABLE friend (
    friendOne UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    friendTwo UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    PRIMARY KEY (friendOne, friendTwo)
);

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
