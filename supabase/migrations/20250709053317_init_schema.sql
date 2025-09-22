
-- Profile
CREATE TABLE profile (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT,
    birthday TIMESTAMP,
    avatar_url TEXT,
    bio TEXT
);

-- platform
CREATE TABLE platform (
    id INTEGER PRIMARY KEY,
    search_name TEXT,
    --alternate_name TEXT,
    --abbreviation TEXT, 
    data JSONB
);

CREATE TABLE platform_enum (
    id INTEGER PRIMARY KEY,
    name TEXT
);

INSERT INTO platform_enum (id, name) VALUES
    (1, 'console'),
    (2, 'arcade'),
    (3, 'platform'),
    (4, 'operating_system'),
    (5, 'portable_console'),
    (6, 'computer');

CREATE TABLE platform_logo (
    id INTEGER PRIMARY KEY--,
    -- alpha_channel BOOLEAN,
    -- animated BOOLEAN,
    -- height INTEGER,
    -- image_id TEXT,
    -- url TEXT,
    -- width INTEGER,
    -- checksum TEXT
);

-- Game
CREATE TABLE game (
    id INTEGER PRIMARY KEY,
    search_name TEXT,
    data JSONB
);

-- Company
CREATE TABLE company (
    id INTEGER PRIMARY KEY,
    data JSONB
);

CREATE TABLE platform_category (
    id INTEGER PRIMARY KEY,
    name TEXT,
    data JSONB
);


CREATE TABLE platform_family (
    id INTEGER PRIMARY KEY,
    company INTEGER REFERENCES company(id),
    name TEXT
);

-- PlayedOn (Game ↔ platform)
CREATE TABLE played_on (
    platform_id INTEGER REFERENCES platform(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (platform_id, game_id)
);

-- platformOwned (Profile ↔ platform)
CREATE TABLE platform_owned (
    platform_id INTEGER REFERENCES platform(id),
    profile_id UUID REFERENCES profile(id),
    PRIMARY KEY (platform_id, profile_id)
);

-- GameOwned (Profile ↔ Game on a platform)
CREATE TABLE game_owned (
    platform_id INTEGER REFERENCES platform(id),
    profile_id UUID REFERENCES profile(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (platform_id, profile_id, game_id)
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


CREATE TABLE posts (
    id INTEGER PRIMARY KEY,
    data JSONB
);

-- Reviews
CREATE TABLE reviews (
    id INTEGER PRIMARY KEY,

    platform_id INTEGER REFERENCES platform(id),
    game_id INTEGER REFERENCES game(id),
    profile_id UUID REFERENCES profile(id),
    
    revision INTEGER,
    title TEXT,
    content TEXT,
    star_rating INTEGER
);

CREATE TABLE screenshot (
    id INTEGER PRIMARY KEY,
    game_id INTEGER REFERENCES game(id),
    profile_id UUID REFERENCES profile(id),

    url TEXT,
    width INTEGER,
    height INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    description TEXT
);

-- PopularityEnum
CREATE TABLE popularity_enum (
    id INTEGER PRIMARY KEY,
    type TEXT
);

-- Popularity (Entity ↔ PopularityEnum)
CREATE TABLE popularity (
    popularity_enum_id INTEGER REFERENCES popularity_enum(id),
    score FLOAT,
    PRIMARY KEY (popularity_enum_id)
);

-- Country (wraps Entity)
CREATE TABLE country (
    id INTEGER PRIMARY KEY
);

-- ReleasedIn (Game ↔ Country)
CREATE TABLE released_in (
    game_id INTEGER REFERENCES game(id),
    country_id INTEGER REFERENCES country(id),
    PRIMARY KEY (game_id, country_id)
);

-- Ratingsystem
CREATE TABLE rating_system (
    id INTEGER PRIMARY KEY,
    name TEXT
);

-- RatingEnum (e.g. ESRB M, PEGI 18)
CREATE TABLE rating_enum (
    id INTEGER PRIMARY KEY,
    rating_system_id INTEGER REFERENCES rating_system(id),
    name TEXT,
    age INTEGER
);

-- AgeRating (Game ↔ RatingEnum through RatingSystem)
CREATE TABLE age_rating (
    game_id INTEGER REFERENCES game(id),
    rating_system_id INTEGER REFERENCES rating_system(id),
    rating_enum_id INTEGER REFERENCES rating_enum(id),
    PRIMARY KEY (game_id, rating_system_id)
);

-- ArtworkEnum
CREATE TABLE artwork_enum (
    id INTEGER PRIMARY KEY,
    type TEXT
);

-- Artwork (Entity ↔ ArtworkEnum)
CREATE TABLE artwork (
    id INTEGER PRIMARY KEY,
    artwork_enum_id INTEGER REFERENCES artwork_enum(id),
    image_url TEXT
);

-- TimeToPlay (Profile ↔ Game)
CREATE TABLE time_to_play (
    profile_id UUID REFERENCES profile(id),
    game_id INTEGER REFERENCES game(id),
    hours INTEGER,
    minutes INTEGER,
    PRIMARY KEY (profile_id, game_id)
);

-- Franchise
CREATE TABLE franchise (
    id INTEGER PRIMARY KEY,
    name TEXT
);

-- EntryInFranchise (Game ↔ Franchise)
CREATE TABLE entry_in_franchise (
    game_id INTEGER REFERENCES game(id),
    franchise_id INTEGER REFERENCES franchise(id),
    PRIMARY KEY (game_id, franchise_id)
);

-- GenreEnum
CREATE TABLE genre_enum (
    id INTEGER PRIMARY KEY,
    name TEXT
);

-- Genre (Game ↔ GenreEnum)
CREATE TABLE genre (
    game_id INTEGER REFERENCES game(id),
    genre_id INTEGER REFERENCES genre_enum(id),
    PRIMARY KEY (game_id, genre_id)
);

-- Developed (Game ↔ Company)
CREATE TABLE developed (
    game_id INTEGER REFERENCES game(id),
    company_id INTEGER REFERENCES company(id),
    PRIMARY KEY (game_id, company_id)
);

-- Published (Game ↔ Company)
CREATE TABLE published (
    game_id INTEGER REFERENCES game(id),
    company_id INTEGER REFERENCES company(id),
    PRIMARY KEY (game_id, company_id)
);

-- Series
CREATE TABLE series (
    id INTEGER PRIMARY KEY,
    name TEXT,
    description TEXT
);

-- EntryInSeries (Game ↔ Series)
CREATE TABLE entry_in_series (
    game_id INTEGER REFERENCES game(id),
    series_id INTEGER REFERENCES series(id),
    PRIMARY KEY (game_id, series_id)
);

-- Edition (Game ↔ Game)
CREATE TABLE edition (
    game_id INTEGER REFERENCES game(id),
    edition_id INTEGER REFERENCES game(id),
    PRIMARY KEY (game_id, edition_id)
);

-- BundledIn (Game ↔ Game)
CREATE TABLE bundled_in (
    game_id INTEGER REFERENCES game(id),
    bundle_id INTEGER REFERENCES game(id),
    PRIMARY KEY (game_id, bundle_id)
);

-- DLC (Game ↔ Game)
CREATE TABLE dlc (
    game_id INTEGER REFERENCES game(id),
    dlc_id INTEGER REFERENCES game(id),
    PRIMARY KEY (game_id, dlc_id)
);


-- Memory for importing game info from IGDB

CREATE TABLE last_imported (
    kind TEXT PRIMARY KEY,
    next INTEGER,
    count INTEGER
);

CREATE TABLE last_updated (
    data JSONB
);

CREATE TABLE error_log (
    id SERIAL PRIMARY KEY,
    error_message TEXT,
    error_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);