-- ArtworkEnum
CREATE TABLE artwork_enum (
    id INTEGER PRIMARY KEY,
    type TEXT
);

CREATE TABLE artwork (
    id SERIAL PRIMARY KEY,
    url TEXT--,
    --data JSONB
);

CREATE TABLE cover (
    id SERIAL PRIMARY KEY,
    url TEXT--,
    --data JSONB
);

CREATE TABLE screenshot (
    id SERIAL PRIMARY KEY,
    url TEXT--,
    --data JSONB
);

CREATE TABLE game_video (
    id SERIAL PRIMARY KEY,
    url TEXT--,
    --data JSONB
);

CREATE TABLE artwork_of (
    artwork_id INTEGER REFERENCES artwork(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (artwork_id, game_id)
);

CREATE TABLE cover_of (
    cover_id INTEGER REFERENCES cover(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (cover_id, game_id)
);

CREATE TABLE screenshot_of (
    screenshot_id INTEGER REFERENCES screenshot(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (screenshot_id, game_id)
);

CREATE TABLE game_video_of (
    game_video_id INTEGER REFERENCES game_video(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (game_video_id, game_id)
);