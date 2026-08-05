-- Migration 133: Add data quality metadata to cities
-- Per spec §1 (mandate): track provenance of timezone assignment
-- Per spec §14.3 (Null Island): flag suspicious coordinates
-- Per spec §15 (boundary): track distance to nearest TZ boundary
-- Per spec §28 (manual override): document each override

ALTER TABLE cities ADD COLUMN timezone_confidence TEXT
  CHECK (timezone_confidence IN ('high', 'medium', 'low', 'unresolved'));
ALTER TABLE cities ADD COLUMN timezone_source TEXT;
  -- e.g. 'polygon:timezonefinder', 'geonames', 'us-truth-115', 'manual:atol', etc.
ALTER TABLE cities ADD COLUMN boundary_distance_km REAL;
  -- Distance from city to nearest timezone boundary line.
  -- NULL = unknown (no polygon data for this TZ)
  -- <1.0 = near boundary (data quality concern)
ALTER TABLE cities ADD COLUMN near_boundary INTEGER DEFAULT 0;
  -- 1 if boundary_distance_km < 1.0, else 0
ALTER TABLE cities ADD COLUMN data_quality_flags TEXT;
  -- Comma-separated flags: 'null_island', 'no_pop', 'no_tz_polygon', 'no_wiki', etc.

CREATE INDEX IF NOT EXISTS idx_cities_tz_confidence ON cities(timezone_confidence);
CREATE INDEX IF NOT EXISTS idx_cities_near_boundary ON cities(near_boundary) WHERE near_boundary = 1;
CREATE INDEX IF NOT EXISTS idx_cities_quality_flags ON cities(data_quality_flags) WHERE data_quality_flags IS NOT NULL;

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('133_data_quality_columns', 'Add timezone_confidence, timezone_source, boundary_distance_km, near_boundary, data_quality_flags');
