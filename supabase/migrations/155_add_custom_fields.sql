-- Add custom_field_definitions JSONB column to profile
-- Stores up to 3 user-defined field definitions that apply to ALL games.
-- Each entry: { id, label, type, options? }
-- Supported types: text, number, date, dropdown, checkbox, rating, url

ALTER TABLE profile
  ADD COLUMN custom_field_definitions JSONB DEFAULT '[]'::jsonb;

ALTER TABLE profile
  ADD CONSTRAINT custom_field_definitions_max_3
  CHECK (jsonb_array_length(COALESCE(custom_field_definitions, '[]'::jsonb)) <= 3);

-- Add custom_fields JSONB column to game_owned
-- Stores per-game values keyed by definition id: { "<field_id>": <value>, ... }

ALTER TABLE game_owned
  ADD COLUMN custom_fields JSONB DEFAULT '{}'::jsonb;
