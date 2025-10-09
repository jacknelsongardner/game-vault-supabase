CREATE TABLE post (
    id SERIAL PRIMARY KEY,
    name TEXT,
    search_name TEXT,
    profile_id UUID REFERENCES auth.users(id),
    posttime TIMESTAMPTZ,
    data JSONB,
    parent_id INTEGER DEFAULT NULL REFERENCES post(id) ON DELETE SET NULL
);

CREATE TABLE tag (
    id SERIAL PRIMARY KEY,
    name TEXT, 
    type TEXT,
    type_id INTEGER,
    search_name TEXT,
    post_id INTEGER REFERENCEs post(id)
);