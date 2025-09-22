-- Company
CREATE TABLE company (
    id INTEGER PRIMARY KEY,
    data JSONB
);

CREATE TABLE platform_family (
    id INTEGER PRIMARY KEY,
    company INTEGER REFERENCES company(id),
    name TEXT
);

-- Developed (Game ↔ Company)
CREATE TABLE developed (
    game_id INTEGER REFERENCES game(id),
    company_id INTEGER REFERENCES company(id),
    PRIMARY KEY (game_id, company_id)
);

-- Published (Game ↔ Company)
CREATE TABLE published (
    game_id INTEGER REFERENCES game(id),
    company_id INTEGER REFERENCES company(id),
    PRIMARY KEY (game_id, company_id)
);
