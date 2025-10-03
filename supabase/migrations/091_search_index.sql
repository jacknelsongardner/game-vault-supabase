CREATE TABLE search_index (
  id SERIAL PRIMARY KEY,
  entity_type TEXT, -- 'game', 'character', 'platform', 'company'
  entity_id INT,
  entity_name TEXT,
  search_vector tsvector
);

CREATE INDEX search_index_idx ON search_index USING GIN (search_vector);

CREATE OR REPLACE FUNCTION update_search_index()
RETURNS TRIGGER AS $$  
BEGIN
  -- Delete old entry if it exists
  DELETE FROM search_index
  WHERE entity_type = TG_TABLE_NAME
    AND entity_id = NEW.id;

  -- Insert new entry
  INSERT INTO search_index (entity_type, entity_id, entity_name, search_vector)
  VALUES (
    TG_TABLE_NAME,           -- entity_type
    NEW.id,                  -- entity_id
    NEW.name,                -- entity_name
    to_tsvector('english', COALESCE(NEW.search_name, ''))  -- search_vector
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
