
-- PlayedOn (Game ↔ platform)
CREATE TABLE played_on (
    platform_id INTEGER REFERENCES platform(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (platform_id, game_id)
);

-- platformOwned (Profile ↔ platform)
CREATE TABLE platform_owned (
    platform_id INTEGER REFERENCES platform(id),
    profile_id UUID REFERENCES auth.users(id),
    PRIMARY KEY (platform_id, profile_id)
);

-- GameOwned (Profile ↔ Game on a platform)
CREATE TABLE game_owned (
    platform_id INTEGER REFERENCES platform(id),
    profile_id UUID REFERENCES auth.users(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (platform_id, profile_id, game_id)
);

CREATE TABLE wishlist_game (
    
    profile_id UUID REFERENCES auth.users(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (profile_id, game_id)
);

CREATE TABLE playing_game (
    
    profile_id UUID REFERENCES auth.users(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (profile_id, game_id)
);

CREATE TABLE finished_game (
    
    profile_id UUID REFERENCES auth.users(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (profile_id, game_id)
);

-- Reviews
CREATE TABLE reviews (
    id INTEGER PRIMARY KEY,

    platform_id INTEGER REFERENCES platform(id),
    game_id INTEGER REFERENCES game(id),
    profile_id UUID REFERENCES auth.users(id),
    
    revision INTEGER,
    title TEXT,
    content TEXT,
    star_rating INTEGER
);