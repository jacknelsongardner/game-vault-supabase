-- ArtworkEnum
CREATE TABLE artwork_enum (
    id INTEGER PRIMARY KEY,
    type TEXT
);

CREATE TABLE artwork (
    id SERIAL PRIMARY KEY,
    url TEXT,
    data JSONB
);

CREATE TABLE cover (
    id SERIAL PRIMARY KEY,
    url TEXT,
    data JSONB
);

CREATE TABLE screenshot (
    id SERIAL PRIMARY KEY,
    url TEXT,
    data JSONB
);

CREATE TABLE video (
    id SERIAL PRIMARY KEY,
    url TEXT,
    data JSONB
);