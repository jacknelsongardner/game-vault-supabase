-- Games
create trigger game_search_trg
after insert or update on game
for each row execute function update_search_index();

-- Platforms
create trigger platform_search_trg
after insert or update on platform
for each row execute function update_search_index();

-- Companies
create trigger company_search_trg
after insert or update on company
for each row execute function update_search_index();

-- Post
create trigger post_search_trg
after insert or update on post
for each row execute function update_search_index();

-- Profile
create trigger profile_search_trg
after insert or update on profile
for each row execute function update_search_index();

-- Tag
create trigger tag_search_trg
after insert or update on tag
for each row execute function update_search_index();
