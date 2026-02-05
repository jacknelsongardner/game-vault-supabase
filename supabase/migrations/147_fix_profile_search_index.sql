-- Fix search index function to properly handle profile table
-- Profile has id as GENERATED ALWAYS, need to wait for it or skip if null

CREATE OR REPLACE FUNCTION update_search_index()
RETURNS TRIGGER AS $$  
DECLARE
  entity_name_value TEXT;
  entity_id_value INT;
BEGIN
  -- Determine the name field based on table type
  IF TG_TABLE_NAME = 'profile' THEN
    entity_name_value := NEW.username;
    entity_id_value := NEW.id;
    
    -- Skip if profile id is not yet generated or username is null
    IF entity_id_value IS NULL OR entity_name_value IS NULL THEN
      RETURN NEW;
    END IF;
  ELSE
    entity_name_value := NEW.name;
    entity_id_value := NEW.id;
  END IF;

  -- Delete old entry if it exists
  DELETE FROM search_index
  WHERE entity_type = TG_TABLE_NAME
    AND entity_id = entity_id_value;

  -- Insert new entry (skip if name is null for non-profile tables)
  IF entity_name_value IS NOT NULL THEN
    INSERT INTO search_index (entity_type, entity_id, entity_name, search_vector)
    VALUES (
      TG_TABLE_NAME,           -- entity_type
      entity_id_value,         -- entity_id
      entity_name_value,       -- entity_name
      to_tsvector('english', COALESCE(NEW.search_name, entity_name_value, ''))  -- search_vector
    );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
