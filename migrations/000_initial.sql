-- Migration 000: Initial schema (cities, countries, timezones)
-- These tables already exist in timeandtimepro-full (from the old API repo).
-- This file is here for reference + to seed a fresh D1 if needed.
--
-- The current prod D1 is `timeandtimepro-full` (c401ffb6) which already has:
--   - cities (33,945 rows)
--   - countries (242)
--   - timezones (408)
--   - onthisday (50)
--   - city_aliases (206)
--   - holidays (880)
--   - business_calendars (21)
--   - holiday_rules (11)
--   - climate_summaries (60,972)
--   - seasons (16,378)
--   - dst_transitions (1,560)
--   - place_redirects (30)
--   - data_sources (8)
--   - import_history (10)
--   - data_quality_checks (10)
--   - feedback (open + closed)
--   - FTS5 indexes for cities
--
-- If you need a fresh D1 for local dev, run this against it. The full schema
-- lives in the OLD repo at `cloudflare/datetime-api/migrations/002-010.sql`.

CREATE TABLE IF NOT EXISTS cities (
  geoname_id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  ascii_name TEXT NOT NULL,
  country_code TEXT NOT NULL,
  country_name TEXT NOT NULL,
  admin1_code TEXT,
  admin2_code TEXT,
  admin3_code TEXT,
  admin4_code TEXT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  timezone TEXT NOT NULL,
  population INTEGER,
  elevation INTEGER,
  feature_code TEXT,
  is_capital INTEGER DEFAULT 0,
  state TEXT,
  state_code TEXT,
  state_native TEXT,
  state_iso3166_2 TEXT,
  state_type TEXT,
  state_dr5hn_id INTEGER,
  slug TEXT,
  FOREIGN KEY (country_code) REFERENCES countries(cca2),
  FOREIGN KEY (timezone) REFERENCES timezones(id)
);

CREATE INDEX IF NOT EXISTS idx_cities_country ON cities(country_code);
CREATE INDEX IF NOT EXISTS idx_cities_tz ON cities(timezone);
CREATE INDEX IF NOT EXISTS idx_cities_state ON cities(country_code, state_code);
CREATE INDEX IF NOT EXISTS idx_cities_population ON cities(population DESC);
CREATE INDEX IF NOT EXISTS idx_cities_slug ON cities(slug);
CREATE INDEX IF NOT EXISTS idx_cities_name ON cities(name);
CREATE INDEX IF NOT EXISTS idx_cities_ascii ON cities(ascii_name);

CREATE TABLE IF NOT EXISTS countries (
  cca2 TEXT PRIMARY KEY,
  cca3 TEXT,
  ccn3 TEXT,
  cioc TEXT,
  name TEXT NOT NULL,
  ascii_name TEXT,
  official_name TEXT,
  capital TEXT,
  continent TEXT,
  un_region TEXT,
  un_subregion TEXT,
  languages TEXT,
  currencies TEXT,
  phone_code TEXT,
  latitude REAL,
  longitude REAL,
  area_km2 REAL,
  population INTEGER,
  un_member INTEGER,
  landlocked INTEGER,
  independent INTEGER,
  start_of_week TEXT,
  canonical_timezones TEXT,
  borders TEXT
);

CREATE TABLE IF NOT EXISTS timezones (
  id TEXT PRIMARY KEY,
  region TEXT,
  subregion TEXT,
  city TEXT,
  country_codes TEXT,
  countries TEXT,
  latitude REAL,
  longitude REAL,
  current_offset INTEGER,
  current_abbreviation TEXT,
  is_dst INTEGER
);

-- FTS5 virtual table for cities (already in prod, recreated here for reference)
CREATE VIRTUAL TABLE IF NOT EXISTS cities_fts USING fts5(
  name, ascii_name, country_name, state,
  content='cities', content_rowid='geoname_id',
  tokenize='unicode61 remove_diacritics 2'
);
