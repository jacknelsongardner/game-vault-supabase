CREATE TABLE post (
    id SERIAL PRIMARY KEY,
    search_name TEXT,
    profile_id UUID REFERENCES profile(id),
    posttime TIMESTAMPTZ,
    data JSONB
);


CREATE TABLE custom_tags (
    tag TEXT, 
    post_id INTEGER REFERENCEs post(id)
);

CREATE TABLE game_tags (
    game_id INTEGER REFERENCES game(id),
    post_id INTEGER REFERENCEs post(id)
);

CREATE TABLE platform_tags (
    platform_id INTEGER REFERENCES platform(id),
    post_id INTEGER REFERENCEs post(id)
);

CREATE TABLE company_tags (
    company_id INTEGER REFERENCES company(id),
    post_id INTEGER REFERENCEs post(id)
);

CREATE TABLE profile_tags (
    profile_id UUID REFERENCES profile(id),
    post_id INTEGER REFERENCEs post(id)
);