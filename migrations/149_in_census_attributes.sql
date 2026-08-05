-- ============================================================================
-- M11.7: Census of India 2011 city attributes
-- ============================================================================
-- Adds per-city attributes from the 2011 Census of India (PCA-UA dataset).
--
-- Source: https://censusindia.gov.in/nada/index.php/catalog/45261/download/48987/PCA11-UA-0000.xlsx
-- Released 2011, still the official Indian census as of 2026 (2021 delayed by COVID).
--
-- Schema (XLSX):
--   ST Code (2) | DT Code (3) | SubDT Code (5) | Town Code (6) | UA Code (9) |
--   UA Name | Level | Ward From/To | No_HH | TOT_P/M/F | P_06 (child) | P_SC, P_ST |
--   P_LIT, P_ILL | TOT_WORK_P | MAINWORK_P, MARGWORK_P, NON_WORK_P | ...
--
-- Level hierarchy:
--   0 = Urban Agglomeration total (e.g. "Srinagar UA" — full metro)
--   1 = Statutory city within UA (e.g. "Srinagar (M Corp.+OG)")
--   2 = Sub-town / Outgrowth (e.g. "Bagh-I-Mehtab (OG)" — part of Srinagar)
--   3 = Sub-sub (rare)
--
-- We store Level 1 (the actual statutory city) plus Level 2 (sub-towns/OGs
-- that have separate identity in some cases).
--
-- Key fields for our API:
--   - population (TOT_P): more accurate than dr5hn/GeoNames for India
--   - households (No_HH): urban planning metric
--   - sex_ratio (TOT_M / TOT_F * 1000): demographic
--   - child_population (P_06): child cohort (0-6 years)
--   - literacy_rate (P_LIT / TOT_P * 100)
--   - sc_population, st_population: scheduled caste/tribe
--   - workers_total, main_workers, marginal_workers
--   - ua_code, ua_name: parent Urban Agglomeration (for city-cluster view)
-- ============================================================================

-- ============================================================================
-- Table 1: in_census_attributes
-- ============================================================================
CREATE TABLE IF NOT EXISTS in_census_attributes (
  city_id                INTEGER NOT NULL,
  census_code            TEXT NOT NULL,        -- 6-digit town code from Census
  state_code             TEXT NOT NULL,        -- 2-digit state code
  district_code          TEXT NOT NULL,        -- 3-digit district code
  sub_district_code      TEXT,                 -- 5-digit sub-district code
  ua_code                TEXT NOT NULL,        -- 9-digit Urban Agglomeration code
  ua_name                TEXT NOT NULL,        -- UA name (e.g. "Srinagar UA")
  level                  INTEGER NOT NULL,     -- 0/1/2/3 hierarchy level
  -- Core demographic
  households             INTEGER,              -- No_HH
  population             INTEGER,              -- TOT_P
  male_population        INTEGER,              -- TOT_M
  female_population      INTEGER,              -- TOT_F
  child_population       INTEGER,              -- P_06 (0-6 years)
  child_male             INTEGER,              -- M_06
  child_female           INTEGER,              -- F_06
  -- Social groups
  sc_population          INTEGER,              -- P_SC (Scheduled Caste)
  st_population          INTEGER,              -- P_ST (Scheduled Tribe)
  -- Education
  literate_population    INTEGER,              -- P_LIT
  illiterate_population  INTEGER,              -- P_ILL
  -- Workforce
  workers_total          INTEGER,              -- TOT_WORK_P
  main_workers           INTEGER,              -- MAINWORK_P
  marginal_workers       INTEGER,              -- MARGWORK_P
  non_workers            INTEGER,              -- NON_WORK_P
  -- Census metadata
  census_year            INTEGER NOT NULL,     -- 2011
  release_id             TEXT NOT NULL,
  fetched_at             INTEGER NOT NULL,
  PRIMARY KEY (city_id)
);

CREATE INDEX IF NOT EXISTS idx_in_census_state
  ON in_census_attributes(state_code);

CREATE INDEX IF NOT EXISTS idx_in_census_ua
  ON in_census_attributes(ua_code);

-- ============================================================================
-- Table 2: add census_code to cities for the crosswalk
-- ============================================================================
-- We add in_census_code to cities so the Census town code → city_id join
-- is O(1) after the initial load. Future re-runs of Census of India can
-- match on this same key.
ALTER TABLE cities ADD COLUMN in_census_code TEXT;

CREATE INDEX IF NOT EXISTS idx_cities_in_census_code
  ON cities(in_census_code);
