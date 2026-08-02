-- Migration 136: Mark Null Island cities as unresolved
-- 22 cities had lat=0,lon=0 (M1 audit). Per spec §14.1, they should be flagged.

UPDATE cities
SET timezone_confidence = 'unresolved',
    timezone_source = 'dr5hn:unverified'
WHERE data_quality_flags LIKE '%null_island%';

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('136_null_island_resolve', 'Mark 22 Null Island cities as timezone_confidence=unresolved');
