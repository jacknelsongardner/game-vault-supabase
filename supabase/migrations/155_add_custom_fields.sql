-- Add custom_fields JSONB column to game_owned
-- Allows users to define up to 3 custom fields per game entry.
-- Each entry is an object: { id, label, type, value, options? }
-- Supported types: text, number, date, dropdown, checkbox, rating, url

ALTER TABLE game_owned
  ADD COLUMN custom_fields JSONB DEFAULT '[]'::jsonb;

-- Enforce a maximum of 3 custom fields per row
ALTER TABLE game_owned
  ADD CONSTRAINT custom_fields_max_3
  CHECK (jsonb_array_length(COALESCE(custom_fields, '[]'::jsonb)) <= 3);
