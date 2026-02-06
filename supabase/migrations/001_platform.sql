CREATE TABLE platform_logo (
    id INTEGER PRIMARY KEY,
    url TEXT
);

CREATE TABLE platform_category (
    id INTEGER PRIMARY KEY,
    name TEXT--,
    --data JSONB
);

CREATE TABLE platform_type (
    id INTEGER PRIMARY KEY,
    name TEXT
);

CREATE TABLE platform_family (
    id INTEGER PRIMARY KEY,
    name TEXT
);

-- platform
CREATE TABLE platform (
    id INTEGER PRIMARY KEY,
    name TEXT,
    url TEXT,
    summary TEXT,
    search_name TEXT,
    platform_family INTEGER REFERENCES platform_family(id),
    platform_logo INTEGER REFERENCES platform_logo(id),
    platform_type INTEGER REFERENCES platform_type(id),
    generation INTEGER,
    alternate_name TEXT,
    abbreviation TEXT
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

