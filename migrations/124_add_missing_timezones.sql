-- Migration 124: Add missing IANA timezones
-- timezonefinder returned 9 TZ IDs that aren't in our time_zones table:
--   - America/Atikokan (real TZ, Eastern Standard no DST - Ontario/CA)
--   - America/Creston (real TZ, Mountain Standard no DST - BC/CA)
--   - Etc/GMT* (spec-banned per section 8.2 - not added, will be overridden)
--
-- Also adds UTC offset, abbreviation, DST flag for the 2 new zones.

INSERT OR IGNORE INTO time_zones
  (id, canonical_id, region, subregion, country_codes, current_offset, current_abbreviation, is_dst)
VALUES
  ('America/Atikokan', 'America/Atikokan', 'Americas', 'Northern America', 'CA', -300, 'EST', 0),
  ('America/Creston', 'America/Creston', 'Americas', 'Northern America', 'CA', -420, 'MST', 0);

-- Verify
-- SELECT id, current_offset, current_abbreviation, is_dst, country_codes
-- FROM time_zones
-- WHERE id IN ('America/Atikokan', 'America/Creston');
