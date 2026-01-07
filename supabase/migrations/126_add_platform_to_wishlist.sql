-- Add platform_id to wishlist_game table to track which platform version is wishlisted

-- Drop the existing primary key constraint
ALTER TABLE wishlist_game DROP CONSTRAINT IF EXISTS wishlist_game_pkey;

-- Add platform_id column (nullable temporarily to handle existing data)
ALTER TABLE wishlist_game 
ADD COLUMN IF NOT EXISTS platform_id INTEGER;

-- For existing records without platform_id, set a default platform
-- This will set platform_id to 6 (PC) for existing wishlist entries
-- You may want to adjust this based on your needs
UPDATE wishlist_game 
SET platform_id = 6 
WHERE platform_id IS NULL;

-- Now make platform_id NOT NULL and add foreign key constraint
ALTER TABLE wishlist_game 
ALTER COLUMN platform_id SET NOT NULL,
ADD CONSTRAINT wishlist_game_platform_fk 
FOREIGN KEY (platform_id) REFERENCES platform(id);

-- Create new composite primary key including platform_id
ALTER TABLE wishlist_game 
ADD PRIMARY KEY (platform_id, profile_id, game_id);
