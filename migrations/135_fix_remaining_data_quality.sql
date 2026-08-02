-- Migration 135: Fix remaining 970 NULL timezone_confidence cities
-- These were missed by the 20-part split (rounding error). Set them now.

UPDATE cities
SET timezone_confidence = 'medium',
    timezone_source = COALESCE(timezone_source, 'dr5hn:default')
WHERE timezone_confidence IS NULL;

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('135_fix_remaining_data_quality', 'Set timezone_confidence=medium for 970 NULL cities (M8 split bug)');
