CREATE TABLE profile_index (
  id SERIAL PRIMARY KEY,
  entity_type TEXT, -- 'game', 'character', 'platform', 'company'
  entity_id INT,
  profile_id UUID REFERENCES auth.users(id),
  profile_name TEXT,
  search_vector_id tsvector,
  search_vector_name tsvector
);

-- Separate GIN indexes for each
CREATE INDEX profile_index_id_idx ON profile_index USING GIN (search_vector_id);
CREATE INDEX profile_index_name_idx ON profile_index USING GIN (search_vector_name);

create or replace function update_profile_index()
returns trigger as $$
begin
  -- Delete old entry if it exists
  delete from profile_index
  where entity_type = tg_table_name
    and entity_id = new.id;

  -- Insert new entry
  insert into profile_index (
    entity_type,
    entity_id,
    profile_id,
    profile_name,
    search_vector_id,
    search_vector_name
  )
  values (
    tg_table_name,           
    new.id,
    new.profile_id,
    new.name,  -- assumes your table has a "name" column
    to_tsvector('english', coalesce(new.profile_id::text, '')),
    to_tsvector('english', coalesce(new.name, ''))
  );

  return new;
end;
$$ language plpgsql;
