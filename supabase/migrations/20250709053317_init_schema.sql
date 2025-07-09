-- Profile
CREATE TABLE profile (
    id INTEGER PRIMARY KEY,
    auth_user_id UUID REFERENCES auth.users(id),
    name TEXT,
    birthday TIMESTAMP,
    avatar_url TEXT
);

-- Entity (abstract base for game, company, system, etc.)
CREATE TABLE entity (
    id INTEGER PRIMARY KEY,
    name TEXT,
    description TEXT
);

-- Game
CREATE TABLE game (
    id INTEGER PRIMARY KEY,
    entity_id INTEGER REFERENCES entity(id)
);

-- Company
CREATE TABLE company (
    id INTEGER PRIMARY KEY,
    entity_id INTEGER REFERENCES entity(id)
);

-- System
CREATE TABLE system (
    id INTEGER PRIMARY KEY,
    entity_id INTEGER REFERENCES entity(id)
);

-- PlayedOn (Game ↔ System)
CREATE TABLE played_on (
    system_id INTEGER REFERENCES system(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (system_id, game_id)
);

-- SystemOwned (Profile ↔ System)
CREATE TABLE system_owned (
    system_id INTEGER REFERENCES system(id),
    profile_id INTEGER REFERENCES profile(id),
    PRIMARY KEY (system_id, profile_id)
);

-- GameOwned (Profile ↔ Game on a System)
CREATE TABLE game_owned (
    system_id INTEGER REFERENCES system(id),
    profile_id INTEGER REFERENCES profile(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (system_id, profile_id, game_id)
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
    profile_id INTEGER REFERENCES profile(id),
    badge_id INTEGER REFERENCES badge(id),
    PRIMARY KEY (profile_id, badge_id)
);

-- Reviews
CREATE TABLE reviews (
    id INTEGER PRIMARY KEY,
    system_id INTEGER REFERENCES system(id),
    game_id INTEGER REFERENCES game(id),
    profile_id INTEGER REFERENCES profile(id),
    revision INTEGER,
    title TEXT,
    content TEXT,
    star_rating INTEGER
);

-- PopularityEnum
CREATE TABLE popularity_enum (
    id INTEGER PRIMARY KEY,
    type TEXT
);

-- Popularity (Entity ↔ PopularityEnum)
CREATE TABLE popularity (
    entity_id INTEGER REFERENCES entity(id),
    popularity_enum_id INTEGER REFERENCES popularity_enum(id),
    score FLOAT,
    PRIMARY KEY (entity_id, popularity_enum_id)
);

-- Country (wraps Entity)
CREATE TABLE country (
    id INTEGER PRIMARY KEY,
    entity_id INTEGER REFERENCES entity(id)
);

-- ReleasedIn (Game ↔ Country)
CREATE TABLE released_in (
    game_id INTEGER REFERENCES game(id),
    country_id INTEGER REFERENCES country(id),
    PRIMARY KEY (game_id, country_id)
);

-- RatingSystem
CREATE TABLE rating_system (
    id INTEGER PRIMARY KEY,
    name TEXT
);

-- RatingEnum (e.g. ESRB M, PEGI 18)
CREATE TABLE rating_enum (
    id INTEGER PRIMARY KEY,
    system_id INTEGER REFERENCES rating_system(id),
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
    entity_id INTEGER REFERENCES entity(id),
    artwork_enum_id INTEGER REFERENCES artwork_enum(id),
    image_url TEXT,
    PRIMARY KEY (entity_id, artwork_enum_id)
);

-- TimeToPlay (Profile ↔ Game)
CREATE TABLE time_to_play (
    profile_id INTEGER REFERENCES profile(id),
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
