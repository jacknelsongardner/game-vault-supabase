-- Company
CREATE TABLE company (
    id INTEGER PRIMARY KEY,
    search_name TEXT,
    name TEXT
);

CREATE TABLE involved_company (
    company_id INTEGER REFERENCES company(id),
    game_id INTEGER REFERENCES game(id),
    PRIMARY KEY (game_id, company_id)
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
