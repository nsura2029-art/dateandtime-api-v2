-- Migration 128: Add nearest_city_id to postcodes
-- dr5hn postcodes have NULL city_id. We compute this via lat/lon → city
-- polygon lookup (migration 129).
--
-- NULL = not yet computed. After migration 129, this will be populated
-- for ~99% of postcodes (some oceanic postcodes have no nearby city).

ALTER TABLE postcodes ADD COLUMN nearest_city_id INTEGER REFERENCES cities(id);
CREATE INDEX IF NOT EXISTS idx_postcodes_nearest_city ON postcodes(nearest_city_id);

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('128_postcodes_nearest_city', 'Add nearest_city_id FK column to postcodes (populated by migration 129)');
