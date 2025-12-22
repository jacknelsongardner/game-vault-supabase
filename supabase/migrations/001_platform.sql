
-- platform
CREATE TABLE platform (
    id INTEGER PRIMARY KEY,
    name TEXT,
    search_name TEXT--,
    --alternate_name TEXT,
    --abbreviation TEXT, 
    --data JSONB
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

CREATE TABLE platform_category (
    id INTEGER PRIMARY KEY,
    name TEXT--,
    --data JSONB
);