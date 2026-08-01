-- Migration 100: Drop ALL existing tables (DESTRUCTIVE — no rollback)
--
-- This migration is the first step of the full DB cleanup + rebuild
-- (Phase 1 of docs/PLAN-phased-implementation.md).
--
-- DESTRUCTIVE: ALL DATA WILL BE PERMANENTLY DELETED.
--
-- Before running this migration:
--   1. Save a D1 backup:  wrangler d1 export timeandtimepro-full --output=backup-$(date +%Y%m%d).sql
--   2. Confirm with user: "do you really want to wipe the DB?"
--   3. Apply:              wrangler d1 execute timeandtimepro-full --env dev --file=migrations/100_drop_all.sql
--
-- After this migration, the DB is empty. Apply migrations 101+ to create the new schema.

-- Drop in reverse-dependency order (children first, parents last)
DROP TABLE IF EXISTS cities_fts;        -- FTS5 virtual table
DROP TABLE IF EXISTS place_redirects;
DROP TABLE IF EXISTS city_aliases;
DROP TABLE IF EXISTS data_quality_issues;
DROP TABLE IF EXISTS data_quality_checks;
DROP TABLE IF EXISTS import_history;
DROP TABLE IF EXISTS data_sources;
DROP TABLE IF EXISTS seasons;
DROP TABLE IF EXISTS climate_summaries;
DROP TABLE IF EXISTS dst_transitions;
DROP TABLE IF EXISTS holiday_rules;
DROP TABLE IF EXISTS business_calendars;
DROP TABLE IF EXISTS holidays;
DROP TABLE IF EXISTS onthisday;
DROP TABLE IF EXISTS city_time_zones;
DROP TABLE IF EXISTS country_time_zones;
DROP TABLE IF EXISTS place_names;
DROP TABLE IF EXISTS cities;
DROP TABLE IF EXISTS administrative_regions;
DROP TABLE IF EXISTS subregions;
DROP TABLE IF EXISTS regions;
DROP TABLE IF EXISTS countries;
DROP TABLE IF EXISTS time_zones;
