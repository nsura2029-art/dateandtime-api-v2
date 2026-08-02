-- Migration 138: Populate data_sources with the actual sources used
-- 8 sources that we have data from

INSERT OR IGNORE INTO data_sources (id, name, url, version, license, last_fetched_at) VALUES
  ('dr5hn', 'dr5hn countries-states-cities-database', 'https://github.com/dr5hn/countries-states-cities-database', '2026-07-29', 'MIT', '2026-07-29'),
  ('geonames', 'GeoNames', 'https://www.geonames.org/', '2024-12', 'CC-BY-4.0', '2024-12'),
  ('iana', 'IANA Time Zone Database', 'https://www.iana.org/time-zones', '2026c', 'Public Domain', '2026-08-01'),
  ('un_m49', 'UN M49 Standard Country Codes', 'https://unstats.un.org/unsd/methodology/m49/', '2024', 'Public Domain', '2024'),
  ('nager_date', 'Nager.Date Public Holidays API', 'https://date.nager.at/', 'live', 'CC-BY-4.0', '2026-07-19'),
  ('wikipedia', 'Wikipedia (Wikidata)', 'https://www.wikidata.org/', 'live', 'CC-BY-SA-4.0', '2026-08-01'),
  ('timezonefinder', 'timezonefinder / timezone-boundary-builder', 'https://github.com/jannikmi/timezonefinder', '8.2.5', 'MIT', '2026-08-01'),
  ('us_census', 'US Census Bureau ZCTA', 'https://www.census.gov/', '2020', 'Public Domain', '2020');

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('138_populate_data_sources', 'Populate data_sources with 8 actual sources used (dr5hn, geonames, iana, etc.)');
