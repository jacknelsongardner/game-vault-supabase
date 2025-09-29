-- ArtworkEnum
CREATE TABLE artwork_enum (
    id INTEGER PRIMARY KEY,
    type TEXT
);


CREATE TABLE artwork (
    id SERIAL PRIMARY KEY,
    search_name TEXT,
    url TEXT,
    data JSONB
);

CREATE TABLE cover (
    id SERIAL PRIMARY KEY,
    search_name TEXT,
    url TEXT,
    data JSONB
);