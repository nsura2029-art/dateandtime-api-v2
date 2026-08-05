-- Migration 147: US Census Bureau city attributes (Vintage 2025)
--
-- Adds per-city attributes from the US Census Bureau Population Estimates Program
-- (PEP) and the Gazetteer File. These are official US government data sources
-- (public domain).
--
-- Source files:
--   1. sub-est2025.csv — Population Estimates Program (released 2026-05-14)
--      https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv
--      Schema: SUMLEV, STATE, COUNTY, PLACE, COUSUB, CONCIT, PRIMGEO_FLAG, FUNCSTAT,
--              NAME, STNAME, ESTIMATESBASE2020, POPESTIMATE2020..POPESTIMATE2025
--      81,354 rows, 19,483 incorporated places (SUMLEV=162)
--
--   2. 2024_Gaz_place_national.txt — Gazetteer (released 2024-08-30)
--      https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2024_Gazetteer/2024_Gaz_place_national.zip
--      Schema: USPS, GEOID, ANSICODE, NAME, LSAD, FUNCSTAT, ALAND, AWATER,
--              ALAND_SQMI, AWATER_SQMI, INTPTLAT, INTPTLONG
--      32,334 place records
--
-- What we get (NEW attributes per US city):
--   - populationTimeSeries: yearly 2020-2025 (6 values per city)
--   - populationLatest: most recent (POPESTIMATE2025, July 2025)
--   - estimatesBase2020: April 2020 anchor
--   - landAreaSqMi: from gazetteer (e.g. 15.543 for Abbeville city)
--   - waterAreaSqMi: from gazetteer
--   - densityPerSqMi: computed (population / land_area)
--   - legalClass: from LSAD (25=city, 43=town, 47=village, 57=CDP, 62=borough)
--   - internalLat/Lon: gazetteer internal point (more accurate than dr5hn)
--   - funcstat: A=Active, S=Statistical
--   - fipsStateCode, fipsPlaceCode, fipsGeoid: 2/5/7-digit FIPS codes
--
-- Schema design notes:
--   - PRIMARY KEY (city_id) — one row per city (one Census "place" per city)
--   - 19,483 incorporated places × 19 columns ≈ 370K values, fits in 1 table
--   - Composite (fips_state, fips_place) is unique but we use city_id PK because
--     we want O(1) joins from cities → us_census_attributes
--   - release_id enables future vintages (vintage 2026, 2027) without conflict
--
-- We also add `fips_state` and `fips_place` columns to cities for the FIPS
-- crosswalk (and so that future sources like ACS 5-year can join the same way).
-- These are 2-digit state FIPS and 5-digit place FIPS — when concatenated, they
-- form the 7-digit FIPS GEOID (e.g. '0100124' = state 01, place 00124).
--
-- We do NOT overwrite cities.population (dr5hn curated) — we store the Census
-- value separately, in this table, and surface it via the API as a "census"
-- block. Future: M11.x can do an intelligent merge (Census for US, dr5hn
-- everywhere else).

-- ============================================================================
-- Table 1: us_census_attributes (per-city Census data)
-- ============================================================================
CREATE TABLE IF NOT EXISTS us_census_attributes (
  city_id              INTEGER NOT NULL,
  -- FIPS codes
  fips_state           TEXT NOT NULL,        -- 2-digit state FIPS, e.g. '01'
  fips_place           TEXT NOT NULL,        -- 5-digit place FIPS, e.g. '00124'
  fips_geoid           TEXT NOT NULL,        -- 7-digit (state+place), e.g. '0100124'
  -- Gazetteer attributes
  lsad_code            INTEGER,              -- LSAD code (25=city, 43=town, etc.)
  legal_class          TEXT,                 -- 'city', 'town', 'village', 'CDP', 'borough'
  funcstat             TEXT,                 -- 'A' (active) or 'S' (statistical)
  land_area_sqmi       REAL,                 -- e.g. 15.543
  water_area_sqmi      REAL,                 -- e.g. 0.042
  internal_lat         REAL,                 -- gazetteer internal point latitude
  internal_lon         REAL,                 -- gazetteer internal point longitude
  -- Population time series (yearly estimates as of July)
  pop_2020             INTEGER,              -- POPESTIMATE2020
  pop_2021             INTEGER,              -- POPESTIMATE2021
  pop_2022             INTEGER,              -- POPESTIMATE2022
  pop_2023             INTEGER,              -- POPESTIMATE2023
  pop_2024             INTEGER,              -- POPESTIMATE2024
  pop_2025             INTEGER,              -- POPESTIMATE2025 (latest)
  estimates_base_2020  INTEGER,              -- April 2020 anchor (census day)
  -- Metadata
  release_id           TEXT NOT NULL,        -- e.g. 'us-census-sub-est-2025-2026-08-02'
  gaz_release_id       TEXT,                 -- e.g. 'us-census-gazetteer-2024-2026-08-02'
  fetched_at           INTEGER NOT NULL,
  PRIMARY KEY (city_id)
);

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_us_census_state
  ON us_census_attributes(fips_state);

CREATE INDEX IF NOT EXISTS idx_us_census_geoid
  ON us_census_attributes(fips_geoid);

CREATE INDEX IF NOT EXISTS idx_us_census_funcstat
  ON us_census_attributes(funcstat);

CREATE INDEX IF NOT EXISTS idx_us_census_pop_2025
  ON us_census_attributes(pop_2025);

-- ============================================================================
-- Table 2: add FIPS columns to cities for the crosswalk
-- ============================================================================
-- We add fips_state_code (2-digit) and fips_place_code (5-digit) to cities
-- so that the FIPS → city_id join is O(1) without parsing addresses.
-- Index on (fips_state_code, fips_place_code) is the natural lookup key.
ALTER TABLE cities ADD COLUMN fips_state_code TEXT;
ALTER TABLE cities ADD COLUMN fips_place_code TEXT;
ALTER TABLE cities ADD COLUMN fips_geoid      TEXT;

CREATE INDEX IF NOT EXISTS idx_cities_fips_geoid
  ON cities(fips_geoid);

CREATE INDEX IF NOT EXISTS idx_cities_fips_state
  ON cities(fips_state_code);
