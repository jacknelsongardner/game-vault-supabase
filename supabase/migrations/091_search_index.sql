CREATE TABLE search_index (
  id SERIAL PRIMARY KEY,
  entity_type TEXT, -- 'game', 'character', 'platform', 'company'
  entity_id INT,
  search_vector tsvector
);

CREATE INDEX search_index_idx ON search_index USING GIN (search_vector);

create or replace function update_search_index()
returns trigger as $$
begin
  -- Delete old entry if it exists
  delete from search_index
  where entity_type = tg_table_name
    and entity_id = new.id;

  -- Insert new entry
  insert into search_index (entity_type, entity_id, search_vector)
  values (
    tg_table_name,           -- use table name as entity_type
    new.id,
    new.search_name,                -- assumes searchable field is "name"
    to_tsvector('english', coalesce(new.search_name, ''))
  );

  return new;
end;
$$ language plpgsql;
