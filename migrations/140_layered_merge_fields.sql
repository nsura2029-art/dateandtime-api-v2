-- Migration 140: Layered merge fields (M11.1)
--
-- Adds fields to `cities` for the intelligent dr5hn + GeoNames layer.
-- These are non-destructive: we only ADD columns, never modify or drop.
-- Existing dr5hn data is preserved; new fields are populated by the merge script.

-- ============================================================================
-- Layer fields on cities
-- ============================================================================
ALTER TABLE cities ADD COLUMN display_name TEXT;
ALTER TABLE cities ADD COLUMN short_name TEXT;
ALTER TABLE cities ADD COLUMN search_name TEXT;
ALTER TABLE cities ADD COLUMN geonames_id INTEGER;
ALTER TABLE cities ADD COLUMN elevation_m INTEGER;
ALTER TABLE cities ADD COLUMN source_primary TEXT;        -- 'dr5hn' | 'geonames'
ALTER TABLE cities ADD COLUMN source_merged_with TEXT;   -- 'geonames' | 'dr5hn' | NULL
ALTER TABLE cities ADD COLUMN merge_method TEXT;         -- 'exact' | 'historical_alias' | 'fuzzy' | 'geonames_only' | NULL
ALTER TABLE cities ADD COLUMN merge_run_id TEXT;          -- UUID of the M11.1 run
ALTER TABLE cities ADD COLUMN merged_at INTEGER;          -- when the merge ran

-- ============================================================================
-- Indexes for the new fields
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_cities_display_name ON cities(display_name);
CREATE INDEX IF NOT EXISTS idx_cities_geonames_id ON cities(geonames_id);
CREATE INDEX IF NOT EXISTS idx_cities_source_primary ON cities(source_primary);
CREATE INDEX IF NOT EXISTS idx_cities_merge_method ON cities(merge_method);

-- ============================================================================
-- city_layer_log: append-only audit trail
-- ============================================================================
CREATE TABLE IF NOT EXISTS city_layer_log (
  log_id INTEGER PRIMARY KEY AUTOINCREMENT,
  city_id INTEGER NOT NULL,
  run_id TEXT NOT NULL,
  action TEXT NOT NULL,            -- 'created' | 'updated' | 'matched' | 'unmatched'
  field TEXT,                     -- which field was changed
  old_value TEXT,
  new_value TEXT,
  reason TEXT,                    -- why this action
  logged_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_city_layer_log_city ON city_layer_log(city_id);
CREATE INDEX IF NOT EXISTS idx_city_layer_log_run ON city_layer_log(run_id);
