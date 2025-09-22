-- Games
create trigger games_search_trg
after insert or update on games
for each row execute function update_search_index();

-- Characters
create trigger characters_search_trg
after insert or update on characters
for each row execute function update_search_index();

-- Platforms
create trigger platforms_search_trg
after insert or update on platforms
for each row execute function update_search_index();

-- Companies
create trigger companies_search_trg
after insert or update on companies
for each row execute function update_search_index();
