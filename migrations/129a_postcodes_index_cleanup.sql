-- Migration 129a: Drop unused city_id index (always NULL in dr5hn data)
-- city_id is always NULL in dr5hn postcodes, so the index is unused.
-- nearest_city_id (from migration 128) has its own index.

DROP INDEX IF EXISTS idx_postcodes_city;

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('129_postcodes_import', 'Import dr5hn postcodes.json (844,248 rows in 20 parts)'),
  ('129a_postcodes_index_cleanup', 'Drop unused city_id index (always NULL)');
