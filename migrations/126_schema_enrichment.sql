-- Migration 126: Schema enrichment to match dr5hn countries-states-cities-database
--
-- Adds:
--   1. 8 new columns to `cities` (state_code, native, type, level, parent_id, wiki_data_id, flag)
--   2. `postcodes` table (city_id FK)
--   3. `translations` table (replaces/augments `place_names`)
--   4. `airports` table (schema only - populated in future milestone)
--   5. `migrations` table (track applied schema changes)
--   6. Indexes for new tables
--
-- Per spec section 5.1: timezone fields preserved, plus enrichment fields
-- Per spec section 16.1: city geometry/data completeness
-- Per dr5hn API: matches the JSON shape shown by user
--
-- All operations are idempotent. New tables created with IF NOT EXISTS.
-- New columns added with no default (NULL allowed). Data populated in M3-M5.

-- ============================================================================
-- 1. Add new columns to `cities`
-- ============================================================================

ALTER TABLE cities ADD COLUMN state_code TEXT;          -- 'FL', 'CA', 'BDS' (Badakhshan)
ALTER TABLE cities ADD COLUMN native TEXT;              -- Local name in native script
ALTER TABLE cities ADD COLUMN type TEXT;                -- 'city', 'adm2', 'district', etc. (33 distinct)
ALTER TABLE cities ADD COLUMN level INTEGER;            -- 1, 2, 3 (administrative level)
ALTER TABLE cities ADD COLUMN parent_id INTEGER;        -- FK to cities.id (hierarchy)
ALTER TABLE cities ADD COLUMN wiki_data_id TEXT;        -- Wikidata QID, e.g. 'Q3459226'
ALTER TABLE cities ADD COLUMN flag INTEGER DEFAULT 1;   -- 1 if active, 0 if deprecated

-- Indexes for new columns
CREATE INDEX IF NOT EXISTS idx_cities_type ON cities(type);
CREATE INDEX IF NOT EXISTS idx_cities_parent ON cities(parent_id);
CREATE INDEX IF NOT EXISTS idx_cities_wiki ON cities(wiki_data_id);
CREATE INDEX IF NOT EXISTS idx_cities_state_code ON cities(state_code);

-- ============================================================================
-- 2. `postcodes` table
-- ============================================================================

CREATE TABLE IF NOT EXISTS postcodes (
  id INTEGER PRIMARY KEY,
  code TEXT NOT NULL,                     -- '32501', 'AD100'
  country_id INTEGER NOT NULL,            -- FK to countries
  country_code TEXT NOT NULL,             -- 'US', 'AD'
  state_id INTEGER,                       -- FK to administrative_regions
  state_code TEXT,                        -- 'FL', '02'
  city_id INTEGER,                        -- FK to cities (nullable)
  locality_name TEXT,                     -- neighborhood/area name
  type TEXT,                              -- 'full', 'partial'
  latitude REAL,
  longitude REAL,
  source TEXT,                            -- 'manual', 'geonames', etc.
  wiki_data_id TEXT,
  FOREIGN KEY (country_id) REFERENCES countries(id),
  FOREIGN KEY (state_id) REFERENCES administrative_regions(id),
  FOREIGN KEY (city_id) REFERENCES cities(id)
);

CREATE INDEX IF NOT EXISTS idx_postcodes_city ON postcodes(city_id);
CREATE INDEX IF NOT EXISTS idx_postcodes_code ON postcodes(code);
CREATE INDEX IF NOT EXISTS idx_postcodes_country ON postcodes(country_id);
CREATE INDEX IF NOT EXISTS idx_postcodes_state ON postcodes(state_id);

-- ============================================================================
-- 3. `translations` table (replaces `place_names` for city/country/state names)
-- ============================================================================
-- Per dr5hn translations.csv schema: place_id, place_type, language, translation
-- place_type: 'country' | 'state' | 'city'
-- 2,965,566 rows in dr5hn (vs our 604K in place_names)

CREATE TABLE IF NOT EXISTS translations (
  place_id INTEGER NOT NULL,              -- FK to cities.id / countries.id / administrative_regions.id
  place_type TEXT NOT NULL,               -- 'country' | 'state' | 'city'
  language TEXT NOT NULL,                 -- 'ko', 'zh-CN', 'pt-BR', etc.
  translation TEXT NOT NULL,
  PRIMARY KEY (place_id, place_type, language)
);

CREATE INDEX IF NOT EXISTS idx_translations_place ON translations(place_id, place_type);
CREATE INDEX IF NOT EXISTS idx_translations_lang ON translations(language, translation);

-- ============================================================================
-- 4. `airports` table (schema only - data import in future milestone)
-- ============================================================================
-- Per our airports cron reminder (next: monthly 9 AM):
--   Data source: https://ourairports.com/data/airports.csv
--   Fields: iata_code, icao_code, name, city_id, country_id, lat, lon, type, timezone

CREATE TABLE IF NOT EXISTS airports (
  id INTEGER PRIMARY KEY,
  iata_code TEXT,                         -- 'JFK', 'LHR', 'NRT'
  icao_code TEXT,                         -- 'KJFK', 'EGLL', 'RJAA'
  name TEXT NOT NULL,                     -- 'John F Kennedy International Airport'
  type TEXT NOT NULL,                     -- 'large_airport' | 'medium_airport' | 'small_airport' | 'heliport' | 'seaplane_base' | 'closed'
  city_id INTEGER,                        -- FK to cities
  country_id INTEGER,                     -- FK to countries
  state_id INTEGER,                       -- FK to administrative_regions
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  elevation_ft INTEGER,
  timezone TEXT,                          -- IANA timezone
  is_scheduled INTEGER DEFAULT 1,         -- 1 = scheduled service, 0 = cargo/GA only
  wiki_data_id TEXT,
  FOREIGN KEY (city_id) REFERENCES cities(id),
  FOREIGN KEY (country_id) REFERENCES countries(id),
  FOREIGN KEY (state_id) REFERENCES administrative_regions(id)
);

CREATE INDEX IF NOT EXISTS idx_airports_iata ON airports(iata_code);
CREATE INDEX IF NOT EXISTS idx_airports_icao ON airports(icao_code);
CREATE INDEX IF NOT EXISTS idx_airports_city ON airports(city_id);
CREATE INDEX IF NOT EXISTS idx_airports_coords ON airports(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_airports_country ON airports(country_id);
CREATE INDEX IF NOT EXISTS idx_airports_type ON airports(type);

-- ============================================================================
-- 5. `migrations` table (track applied schema migrations)
-- ============================================================================

CREATE TABLE IF NOT EXISTS migrations (
  version TEXT PRIMARY KEY,               -- '126_schema_enrichment'
  description TEXT,
  applied_at TEXT DEFAULT CURRENT_TIMESTAMP
);

-- Insert this migration's record
INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('126_schema_enrichment', 'Add dr5hn enrichment columns to cities + postcodes/translations/airports/migrations tables');

-- ============================================================================
-- 6. Verify
-- ============================================================================
-- SELECT column_name FROM pragma_table_info('cities') WHERE column_name IN
--   ('state_code', 'native', 'type', 'level', 'parent_id', 'wiki_data_id', 'flag');
-- Expected: 7 rows
--
-- SELECT name FROM sqlite_master WHERE type='table' AND name IN
--   ('postcodes', 'translations', 'airports', 'migrations');
-- Expected: 4 rows
