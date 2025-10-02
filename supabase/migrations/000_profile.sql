
-- Profile
CREATE TABLE profile (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    birthday TIMESTAMP,
    search_name TEXT,
    avatar_url TEXT,
    bio TEXT
);

CREATE TABLE friend (
    friendOne UUID REFERENCES profile(id) ON DELETE CASCADE,
    friendTwo UUID REFERENCES profile(id) ON DELETE CASCADE,
    PRIMARY KEY (friend, friended)
);

-- Badge
CREATE TABLE badge (
    id INTEGER PRIMARY KEY,
    name TEXT,
    icon_url TEXT,
    description TEXT
);

-- BadgesEarned
CREATE TABLE badges_earned (
    profile_id UUID REFERENCES profile(id),
    badge_id INTEGER REFERENCES badge(id),
    PRIMARY KEY (profile_id, badge_id)
);
