-- Migration 148: Eurostat LAU (Local Administrative Units) attributes
--
-- Adds per-city attributes from the Eurostat GISCO LAU dataset (2024 vintage).
-- LAU = Local Administrative Units — the lowest level of administrative
-- geography in the EU. For most countries, this is "municipality".
--
-- Source: LAU_RG_01M_2024_3035.csv
--   https://gisco-services.ec.europa.eu/distribution/v2/lau/csv/LAU_RG_01M_2024_3035.csv
--   Released 2026-02-18, 5.6 MB
--   Schema: GISCO_ID, CNTR_CODE, LAU_NAME, POP_2024, POP_DENS_2024, AREA_KM2, YEAR
--
-- Coverage:
--   - 97,987 LAU records across 30 country codes (EU-27 + EFTA + candidates)
--   - 25 of 30 countries have population data (AL, ES, FR, IS, RS have 0-pop)
--   - The 5 zero-pop countries don't disclose municipality-level population
--     to Eurostat due to national privacy laws (FR, ES, etc.)
--
-- What we get (NEW attributes per EU city):
--   - gisco_id: official Eurostat LAU ID (e.g. "DE_11000000" for Berlin)
--   - lau_name: official LAU name (may differ from dr5hn name)
--   - pop_2024: population (1 January 2024) — null for FR/ES/AL/IS/RS
--   - pop_density_2024: people per km²
--   - area_km2: official area in km² (replaces dr5hn for EU cities)
--   - year: data vintage (2024)
--
-- We also add `gisco_id` to cities for the FIPS-style crosswalk. The pattern
-- mirrors M11.5 (FIPS) so future EU data sources can join the same way.
--
-- Schema design:
--   - PRIMARY KEY (city_id) — one row per city (one LAU per city)
--   - 97,987 LAU × 7 columns = 685K values, fits in 1 table
--   - (country_code, gisco_id) is unique per LAU but we use city_id PK
--     because we want O(1) joins from cities → eu_lau_attributes
--   - release_id enables future vintages (LAU 2025) without conflict

-- ============================================================================
-- Table 1: eu_lau_attributes (per-city LAU data)
-- ============================================================================
CREATE TABLE IF NOT EXISTS eu_lau_attributes (
  city_id              INTEGER NOT NULL,
  -- Eurostat ID
  gisco_id             TEXT NOT NULL,        -- e.g. "DE_11000000"
  country_code         TEXT NOT NULL,        -- 2-letter, e.g. "DE"
  lau_name             TEXT NOT NULL,        -- official name, may differ from dr5hn
  -- Population data (year 2024)
  pop_2024             INTEGER,              -- 1 January 2024 population
  pop_density_2024     REAL,                 -- people per km²
  area_km2             REAL,                 -- official area in km²
  year                 INTEGER NOT NULL,     -- data vintage (2024)
  -- Metadata
  release_id           TEXT NOT NULL,
  fetched_at           INTEGER NOT NULL,
  PRIMARY KEY (city_id)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_eu_lau_country
  ON eu_lau_attributes(country_code);

CREATE INDEX IF NOT EXISTS idx_eu_lau_gisco
  ON eu_lau_attributes(gisco_id);

CREATE INDEX IF NOT EXISTS idx_eu_lau_pop
  ON eu_lau_attributes(pop_2024);

-- ============================================================================
-- Table 2: add GISCO ID column to cities for the crosswalk
-- ============================================================================
-- We add gisco_id to cities so the GISCO ID → city_id join is O(1).
-- gisco_id is the official Eurostat LAU identifier; future EU data sources
-- (URAU city/FUA, NUTS, etc.) can join on this same key.
ALTER TABLE cities ADD COLUMN gisco_id TEXT;

CREATE INDEX IF NOT EXISTS idx_cities_gisco_id
  ON cities(gisco_id);

-- ============================================================================
-- Table 3: eu_urau_attributes (City vs FUA distinction)
-- ============================================================================
-- URAU = Urban Audit dataset. Distinguishes:
--   - City (URAU_CATG=C): the administrative municipality
--   - FUA (URAU_CATG=F): Functional Urban Area — the wider metro area
--     that includes the city plus surrounding suburbs/communes
--
-- A City record has a FUA_CODE pointing to the FUA record.
-- This is the "City vs FUA" distinction the user wanted for M11.6.
--
-- Source: URAU_AT_2024.csv (despite the name, it's PAN-EU)
--   https://gisco-services.ec.europa.eu/distribution/v2/urau/csv/URAU_AT_2024.csv
--   1,332 records (Cities + FUAs) across 30 EU countries
--
-- Schema (CSV):
--   URAU_CODE, URAU_CATG, CNTR_CODE, URAU_NAME, CITY_CPTL, FUA_CODE, AREA_SQM, NUTS3_2024
--
-- We store ONE row per city_id with the FUA linkage resolved.
CREATE TABLE IF NOT EXISTS eu_urau_attributes (
  city_id              INTEGER NOT NULL,
  urau_code            TEXT NOT NULL,        -- e.g. "ES001C" (city) or "ES001F" (FUA)
  urau_name            TEXT NOT NULL,        -- official URAU name
  fua_code             TEXT,                 -- e.g. "ES001F" — the FUA this city belongs to
  fua_name             TEXT,                 -- resolved from FUA record
  area_sqm             REAL,                 -- area in km² (used for density calcs)
  nuts3_code           TEXT,                 -- NUTS 2024 region code
  release_id           TEXT NOT NULL,
  fetched_at           INTEGER NOT NULL,
  PRIMARY KEY (city_id)
);

CREATE INDEX IF NOT EXISTS idx_eu_urau_country
  ON eu_urau_attributes(substring(urau_code, 1, 2));

CREATE INDEX IF NOT EXISTS idx_eu_urau_fua
  ON eu_urau_attributes(fua_code);
