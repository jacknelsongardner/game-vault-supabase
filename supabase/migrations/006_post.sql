CREATE TABLE post (
    id SERIAL PRIMARY KEY,
    search_name TEXT,
    profile_id UUID REFERENCES profile(id),
    posttime TIMESTAMPTZ,
    data JSONB
);

CREATE TABLE tag (
    value TEXT, 
    type TEXT,
    search_name TEXT,
    post_id INTEGER REFERENCEs post(id)
);