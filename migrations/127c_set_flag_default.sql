-- Migration 127c: Set flag=1 default for all cities
-- dr5hn's `flag` field is always null, so we use our schema's DEFAULT value
-- (1 = active, 0 = deprecated). All 152,970 cities are active by default.

UPDATE cities SET flag = 1 WHERE flag IS NULL;

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('127_cities_enrichment', 'Import dr5hn cities.json enrichment data (state_code, native, type, level, parent_id, wiki_data_id, flag) for 152,970 cities'),
  ('127b_wiki_data_id', 'wikiDataId (camelCase) → wiki_data_id (snake_case)'),
  ('127c_set_flag_default', 'Set flag=1 default for all cities (dr5hn flag is always null)');
