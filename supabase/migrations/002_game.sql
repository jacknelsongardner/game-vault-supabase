
-- Game
CREATE TABLE game (
    id INTEGER PRIMARY KEY,
    search_name TEXT,
    data JSONB
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
