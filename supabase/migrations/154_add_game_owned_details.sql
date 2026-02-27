-- Add acquisition/collection detail columns to game_owned
-- These allow users to track where, when, and how much they paid for each game

ALTER TABLE game_owned
  ADD COLUMN acquisition_source TEXT,
  ADD COLUMN acquisition_date   DATE,
  ADD COLUMN price_paid         NUMERIC(10, 2),
  ADD COLUMN condition           TEXT CHECK (condition IN ('mint', 'excellent', 'good', 'fair', 'poor')),
  ADD COLUMN notes               TEXT;
