-- Fix search index function to handle profile table with username field
CREATE OR REPLACE FUNCTION update_search_index()
RETURNS TRIGGER AS $$  
DECLARE
  entity_name_value TEXT;
BEGIN
  -- Determine the name field based on table type
  IF TG_TABLE_NAME = 'profile' THEN
    entity_name_value := NEW.username;
  ELSE
    entity_name_value := NEW.name;
  END IF;

  -- Delete old entry if it exists
  DELETE FROM search_index
  WHERE entity_type = TG_TABLE_NAME
    AND entity_id = NEW.id;

  -- Insert new entry
  INSERT INTO search_index (entity_type, entity_id, entity_name, search_vector)
  VALUES (
    TG_TABLE_NAME,           -- entity_type
    NEW.id,                  -- entity_id
    entity_name_value,       -- entity_name
    to_tsvector('english', COALESCE(NEW.search_name, ''))  -- search_vector
  );

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
