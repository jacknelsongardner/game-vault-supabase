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