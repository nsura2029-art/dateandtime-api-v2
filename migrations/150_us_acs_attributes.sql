-- ============================================================================
-- M11.5.1: ACS 5-year estimates (Sex by Age, B01001)
-- ============================================================================
-- Adds per-city attributes from the 2018-2022 American Community Survey
-- 5-year estimates, table B01001 (Sex by Age).
--
-- Source: https://www2.census.gov/programs-surveys/acs/summary_file/2022/table-based-SF/data/5YRData/acsdt5y2022-b01001.dat
-- 200 MB pipe-delimited file, ~32K place records
-- Released Dec 2023, 5-year pooled ACS (2018-2022)
--
-- Schema (B01001):
--   49 estimate variables + 49 margin-of-error variables (MOE)
--   - B01001_E001: Total population
--   - B01001_E002: Male
--   - B01001_E003-25: Male by age bucket (23 buckets)
--   - B01001_E026: Female
--   - B01001_E027-49: Female by age bucket (23 buckets)
--
-- We roll up to major age buckets for the API:
--   - under_5 (< 5)
--   - school_age (5-17)
--   - college_age (18-24)
--   - young_adult (25-44)
--   - middle_age (45-64)
--   - senior (65+)
--
-- Plus a JSON field with the full 23 age groups for clients that want detail.
-- ============================================================================

CREATE TABLE IF NOT EXISTS us_acs_attributes (
  city_id            INTEGER NOT NULL,
  fips_geoid         TEXT NOT NULL,        -- 7-digit FIPS GEOID (state+place)
  total_population   INTEGER,              -- B01001_E001
  male_population    INTEGER,              -- B01001_E002
  female_population  INTEGER,              -- B01001_E026
  -- Major age buckets (rolled up)
  under_5            INTEGER,
  age_5_to_17        INTEGER,
  age_18_to_24       INTEGER,
  age_25_to_44       INTEGER,
  age_45_to_64       INTEGER,
  age_65_plus        INTEGER,
  -- Full age detail (23 male + 23 female = 46 entries) as JSON
  age_detail         TEXT,                 -- JSON
  median_age         REAL,                 -- B01002_001E (Median Age by Sex) — from B01002
  -- ACS metadata
  acs_year           INTEGER NOT NULL,     -- 2022 (end year of 2018-2022 5-year)
  release_id         TEXT NOT NULL,
  fetched_at         INTEGER NOT NULL,
  PRIMARY KEY (city_id)
);

CREATE INDEX IF NOT EXISTS idx_us_acs_fips
  ON us_acs_attributes(fips_geoid);
