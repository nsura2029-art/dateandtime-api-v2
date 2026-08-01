-- Migration 101: Create new schema (10 main tables)
--
-- Phase 1 of docs/PLAN-phased-implementation.md
-- Source spec: docs/SPEC-master-data-architecture.md
--
-- Target counts:
--   regions                  : 6
--   subregions               : 22
--   countries                : 250
--   administrative_regions   : 5,308 (states, provinces, counties, etc.)
--   cities                   : 152,970
--   place_names              : 500K+ (added in Phase 2)
--   time_zones               : ~450 (IANA canonical + aliases)
--   city_time_zones          : 152,970+ (1+ per city)
--   country_time_zones       : 400+ (1+ per country)
--   data_sources             : 10+
--   import_history           : growing
--   place_redirects          : 30+ (historical renamings)

-- ============================================================================
-- regions: 6 UN M49 regions
-- ============================================================================
CREATE TABLE IF NOT EXISTS regions (
  id          INTEGER PRIMARY KEY,            -- 1..6
  code        TEXT UNIQUE NOT NULL,           -- 'AF', 'AM', 'AS', 'EU', 'OC', 'AN'
  name        TEXT NOT NULL,                  -- 'Africa', 'Americas', 'Asia', 'Europe', 'Oceania', 'Antarctica'
  un_m49_code TEXT UNIQUE NOT NULL            -- '002', '019', '142', '150', '009', 'AQ'  (UN M49 standard)
);

-- ============================================================================
-- subregions: 22 UN M49 sub-regions
-- ============================================================================
CREATE TABLE IF NOT EXISTS subregions (
  id          INTEGER PRIMARY KEY,            -- 1..22
  code        TEXT,                           -- UN M49 code, e.g. '021' (Northern America). NULLABLE — not all regions/sub-regions have UN M49 codes; no UNIQUE constraint because our hand-curated map has duplicate codes.
  name        TEXT NOT NULL,
  region_id   INTEGER NOT NULL,
  FOREIGN KEY (region_id) REFERENCES regions(id)
);

CREATE INDEX IF NOT EXISTS idx_subregions_region ON subregions(region_id);

-- ============================================================================
-- countries: 250 ISO 3166-1 countries
-- ============================================================================
CREATE TABLE IF NOT EXISTS countries (
  id                  INTEGER PRIMARY KEY,            -- dr5hn ID (1..250)
  cca2                TEXT UNIQUE NOT NULL,           -- 'US', 'IN', 'JP' (ISO 3166-1 alpha-2)
  cca3                TEXT,                           -- 'USA', 'IND', 'JPN' (alpha-3)
  ccn3                TEXT,                           -- '840', '356', '392' (numeric)
  cioc                TEXT,                           -- 'USA', 'IND', 'JPN' (Olympic)
  name                TEXT NOT NULL,                  -- 'United States'
  official_name       TEXT,                           -- 'United States of America'
  capital             TEXT,                           -- 'Washington, D.C.'
  region_id           INTEGER NOT NULL,
  subregion_id        INTEGER,                 -- NULLABLE — Antarctica has no sub-region
  currency_code       TEXT,                           -- 'ISO 4217 currency code (USD, INR, JPY)
  currency_name       TEXT,                           -- 'US Dollar'
  currency_symbol     TEXT,                           -- '$', '₹', '¥'
  phone_code          TEXT,                           -- '+1', '+91', '+81'
  languages           TEXT,                           -- 'en', 'hi,en', 'ja'
  latitude            REAL,
  longitude           REAL,
  area_km2            REAL,
  population          INTEGER,
  flag_emoji          TEXT,                           -- '🇺🇸', '🇮🇳', '🇯🇵'
  tld                 TEXT,                           -- '.us', '.in', '.jp'
  nationality         TEXT,                           -- 'Afghan', 'American' (denonym)
  un_member           INTEGER DEFAULT 0,              -- 0/1
  landlocked          INTEGER DEFAULT 0,              -- 0/1
  independent         INTEGER DEFAULT 0,              -- 0/1
  start_of_week       TEXT,                           -- 'monday' / 'sunday'
  borders             TEXT,                           -- 'CA,MX', 'CN,NP,BT,BD,MM', NULL
  canonical_timezones TEXT,                           -- 'America/New_York,America/Chicago,...'
  FOREIGN KEY (region_id)    REFERENCES regions(id),
  FOREIGN KEY (subregion_id) REFERENCES subregions(id)
);

CREATE INDEX IF NOT EXISTS idx_countries_cca2      ON countries(cca2);
CREATE INDEX IF NOT EXISTS idx_countries_cca3      ON countries(cca3);
CREATE INDEX IF NOT EXISTS idx_countries_region    ON countries(region_id);
CREATE INDEX IF NOT EXISTS idx_countries_subregion ON countries(subregion_id);

-- ============================================================================
-- administrative_regions: 5,308 states/provinces/counties/regions
-- Hierarchical: country → region → sub-region → district/county
-- ============================================================================
CREATE TABLE IF NOT EXISTS administrative_regions (
  id            INTEGER PRIMARY KEY,            -- dr5hn ID
  country_id    INTEGER NOT NULL,
  parent_id     INTEGER,                        -- for nested regions (e.g., county in state)
  code          TEXT,                           -- 'CA', 'NY', 'ON' (ISO 3166-2)
  name          TEXT NOT NULL,
  ascii_name    TEXT,
  type          TEXT,                           -- 'state' | 'province' | 'territory' | 'region' | 'county' | 'district'
  level         INTEGER DEFAULT 1,              -- 1=state/province, 2=county/district
  latitude      REAL,
  longitude     REAL,
  iso2          TEXT,                           -- full ISO 3166-2 code, e.g. 'US-CA'
  population    INTEGER,
  timezone      TEXT,                           -- IANA timezone
  FOREIGN KEY (country_id) REFERENCES countries(id),
  FOREIGN KEY (parent_id)  REFERENCES administrative_regions(id)
);

CREATE INDEX IF NOT EXISTS idx_admin_country  ON administrative_regions(country_id);
CREATE INDEX IF NOT EXISTS idx_admin_parent   ON administrative_regions(parent_id);
CREATE INDEX IF NOT EXISTS idx_admin_code     ON administrative_regions(country_id, code);
CREATE INDEX IF NOT EXISTS idx_admin_iso2     ON administrative_regions(iso2);
CREATE INDEX IF NOT EXISTS idx_admin_tz       ON administrative_regions(timezone);

-- ============================================================================
-- cities: 152,970 canonical place records
-- ============================================================================
CREATE TABLE IF NOT EXISTS cities (
  id                    INTEGER PRIMARY KEY,            -- dr5hn ID
  name                  TEXT NOT NULL,                  -- official name (any script)
  ascii_name            TEXT,                           -- ASCII transliteration
  country_id            INTEGER NOT NULL,
  state_id              INTEGER,                        -- FK to administrative_regions
  district_id           INTEGER,                        -- FK to administrative_regions (county)
  latitude              REAL NOT NULL,
  longitude             REAL NOT NULL,
  timezone              TEXT NOT NULL,                  -- IANA timezone
  population            INTEGER,
  elevation             INTEGER,
  feature_code          TEXT,                           -- GeoNames feature code
  place_type            TEXT,                           -- 'city' | 'town' | 'village' | 'neighborhood' | 'district'
  capital_type          TEXT,                           -- 'none' | 'state_capital' | 'country_capital' | 'both'
  is_active             INTEGER DEFAULT 1,              -- 0=historical, 1=active
  is_capital            INTEGER DEFAULT 0,              -- legacy
  is_state_capital      INTEGER DEFAULT 0,
  is_country_capital    INTEGER DEFAULT 0,
  disputed              INTEGER DEFAULT 0,              -- 1 if boundary/label disputed
  claimed_by            TEXT,                           -- comma-separated country codes
  source_id             TEXT,                           -- e.g. "dr5hn:1326573" or "geonames:5128581"
  source_version        TEXT,                           -- e.g. "dr5hn-2026-07-29"
  created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (country_id)  REFERENCES countries(id),
  FOREIGN KEY (state_id)    REFERENCES administrative_regions(id),
  FOREIGN KEY (district_id) REFERENCES administrative_regions(id),
  FOREIGN KEY (timezone)    REFERENCES time_zones(id)
);

CREATE INDEX IF NOT EXISTS idx_cities_country     ON cities(country_id);
CREATE INDEX IF NOT EXISTS idx_cities_state       ON cities(state_id);
CREATE INDEX IF NOT EXISTS idx_cities_district    ON cities(district_id);
CREATE INDEX IF NOT EXISTS idx_cities_tz          ON cities(timezone);
CREATE INDEX IF NOT EXISTS idx_cities_coords      ON cities(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_cities_population  ON cities(population DESC);
CREATE INDEX IF NOT EXISTS idx_cities_source      ON cities(source_id);
CREATE INDEX IF NOT EXISTS idx_cities_active      ON cities(is_active);
CREATE INDEX IF NOT EXISTS idx_cities_capital     ON cities(capital_type);

-- ============================================================================
-- place_names: 500K+ searchable names (one city can have many)
-- Populated in Phase 2. Empty for now.
-- ============================================================================
CREATE TABLE IF NOT EXISTS place_names (
  id                  INTEGER PRIMARY KEY,
  canonical_place_id  INTEGER NOT NULL,                -- FK to cities.id
  name                TEXT NOT NULL,                   -- "München" / "Munich" / "Мюнхен" / "NYC"
  normalized_name     TEXT NOT NULL,                   -- for search: lowercase, diacritics removed
  language_code       TEXT,                            -- ISO 639-1: "de", "en", "ru"
  script              TEXT,                            -- "Latn", "Cyrl", "Arab", "Hans"
  name_type           TEXT NOT NULL,                   -- 'official' | 'ascii' | 'local' | 'transliteration' | 'abbreviation' | 'alternate' | 'historical' | 'colloquial'
  is_preferred        INTEGER DEFAULT 0,               -- 1 = use for display when multiple exist
  is_historical       INTEGER DEFAULT 0,               -- 1 = historical name, no longer in use
  source              TEXT,                            -- "dr5hn" | "geonames" | "wikipedia" | "manual"
  FOREIGN KEY (canonical_place_id) REFERENCES cities(id)
);

CREATE INDEX IF NOT EXISTS idx_place_names_norm      ON place_names(normalized_name);
CREATE INDEX IF NOT EXISTS idx_place_names_canonical ON place_names(canonical_place_id);
CREATE INDEX IF NOT EXISTS idx_place_names_lang      ON place_names(language_code, script);
CREATE INDEX IF NOT EXISTS idx_place_names_type      ON place_names(name_type);

-- FTS5 for fast text search
CREATE VIRTUAL TABLE IF NOT EXISTS place_names_fts USING fts5(
  name, normalized_name,
  content='place_names', content_rowid='id',
  tokenize='unicode61 remove_diacritics 2'
);

-- ============================================================================
-- time_zones: ~450 IANA canonical + aliases
-- ============================================================================
CREATE TABLE IF NOT EXISTS time_zones (
  id                    TEXT PRIMARY KEY,              -- IANA name, e.g. 'America/New_York'
  canonical_id          TEXT,                          -- points to canonical IANA name (NULL if id is canonical)
  region                TEXT,                          -- 'America', 'Europe', 'Asia', etc.
  subregion             TEXT,                          -- 'Northern America', 'Western Europe', etc.
  city                  TEXT,                          -- representative city, e.g. 'New York'
  country_codes         TEXT,                          -- comma-separated cca2: 'US,CA'
  countries             TEXT,                          -- comma-separated country names
  latitude              REAL,
  longitude             REAL,
  current_offset        INTEGER,                       -- UTC offset in MINUTES (e.g., -300 for EST)
  current_abbreviation  TEXT,                          -- 'EST', 'EDT', 'GMT+5:30'
  is_dst                INTEGER,                       -- 0/1
  description           TEXT,
  FOREIGN KEY (canonical_id) REFERENCES time_zones(id)
);

CREATE INDEX IF NOT EXISTS idx_tz_canonical ON time_zones(canonical_id);
CREATE INDEX IF NOT EXISTS idx_tz_region    ON time_zones(region);
CREATE INDEX IF NOT EXISTS idx_tz_offset    ON time_zones(current_offset);

-- ============================================================================
-- city_time_zones: M2M (cities ↔ time_zones)
-- Most cities have one, but some span multiple (or share one across borders)
-- ============================================================================
CREATE TABLE IF NOT EXISTS city_time_zones (
  city_id      INTEGER NOT NULL,
  timezone_id  TEXT NOT NULL,
  is_primary   INTEGER DEFAULT 1,                     -- 1 = main timezone for this city
  PRIMARY KEY (city_id, timezone_id),
  FOREIGN KEY (city_id)     REFERENCES cities(id),
  FOREIGN KEY (timezone_id) REFERENCES time_zones(id)
);

CREATE INDEX IF NOT EXISTS idx_ctz_tz ON city_time_zones(timezone_id);

-- ============================================================================
-- country_time_zones: M2M (countries ↔ time_zones)
-- 1+ per country (e.g., US has 6+ timezones: Eastern, Central, Mountain, Pacific, Alaska, Hawaii)
-- ============================================================================
CREATE TABLE IF NOT EXISTS country_time_zones (
  country_id   INTEGER NOT NULL,
  timezone_id  TEXT NOT NULL,
  is_primary   INTEGER DEFAULT 0,                     -- 1 = main timezone
  PRIMARY KEY (country_id, timezone_id),
  FOREIGN KEY (country_id)  REFERENCES countries(id),
  FOREIGN KEY (timezone_id) REFERENCES time_zones(id)
);

CREATE INDEX IF NOT EXISTS idx_ctrtz_tz ON country_time_zones(timezone_id);

-- ============================================================================
-- data_sources: track which source/version each data came from
-- ============================================================================
CREATE TABLE IF NOT EXISTS data_sources (
  id                  INTEGER PRIMARY KEY,
  name                TEXT UNIQUE NOT NULL,            -- "dr5hn" | "geonames" | "iana_tzdb" | "cldr" | "natural_earth"
  url                 TEXT,                            -- source homepage
  version             TEXT NOT NULL,                   -- "2026-07-29"
  license             TEXT,                            -- "MIT" | "CC-BY-4.0" | "public-domain"
  last_fetched_at     TIMESTAMP,
  last_fetched_rows   INTEGER,
  notes               TEXT
);

-- ============================================================================
-- import_history: every import run, with stats and errors
-- ============================================================================
CREATE TABLE IF NOT EXISTS import_history (
  id                INTEGER PRIMARY KEY,
  data_source_id    INTEGER,
  started_at        TIMESTAMP NOT NULL,
  completed_at      TIMESTAMP,
  rows_imported     INTEGER DEFAULT 0,
  rows_skipped      INTEGER DEFAULT 0,
  rows_errored      INTEGER DEFAULT 0,
  error_message     TEXT,
  notes             TEXT,
  FOREIGN KEY (data_source_id) REFERENCES data_sources(id)
);

CREATE INDEX IF NOT EXISTS idx_import_history_source ON import_history(data_source_id);
CREATE INDEX IF NOT EXISTS idx_import_history_date   ON import_history(started_at DESC);

-- ============================================================================
-- place_redirects: old ID → new ID (for historical/merged cities)
-- ============================================================================
CREATE TABLE IF NOT EXISTS place_redirects (
  id            INTEGER PRIMARY KEY,
  from_id       INTEGER NOT NULL,                      -- old city ID
  to_id         INTEGER NOT NULL,                      -- new city ID
  reason        TEXT,                                  -- 'renamed' | 'merged' | 'absorbed' | 'duplicate'
  year_from     INTEGER,                               -- e.g. 1995 (when the old name was in use)
  year_to       INTEGER,                               -- e.g. 2000 (when the redirect was created)
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (from_id) REFERENCES cities(id),
  FOREIGN KEY (to_id)   REFERENCES cities(id)
);

CREATE INDEX IF NOT EXISTS idx_redirects_from ON place_redirects(from_id);
CREATE INDEX IF NOT EXISTS idx_redirects_to   ON place_redirects(to_id);

-- ============================================================================
-- city_aliases (legacy — re-derived from place_names in Phase 2)
-- ============================================================================
DROP TABLE IF EXISTS city_aliases;
-- (Not recreated; use place_names instead)
