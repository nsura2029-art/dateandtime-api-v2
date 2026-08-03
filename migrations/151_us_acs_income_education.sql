-- Migration 151: ACS 5-Year Income (B19013) + Education (B15003)
-- Adds per-city median household income and educational attainment for US places

CREATE TABLE IF NOT EXISTS us_acs_income_attributes (
  fips_geoid    TEXT PRIMARY KEY,        -- 7-digit FIPS place code
  median_income INTEGER,                 -- B19013_E001 (USD, 2022 inflation-adjusted)
  acs_year      INTEGER NOT NULL,        -- 2022 (end of 2018-2022 5-year)
  release_id    TEXT NOT NULL,
  fetched_at    INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_us_acs_income_year ON us_acs_income_attributes (acs_year);

CREATE TABLE IF NOT EXISTS us_acs_education_attributes (
  fips_geoid         TEXT PRIMARY KEY,        -- 7-digit FIPS place code
  population_25_plus INTEGER,                 -- B15003_E001 (population 25+)
  less_than_hs       INTEGER,                 -- E002-E010 (no high school)
  hs_or_ged          INTEGER,                 -- E011-E012
  some_college       INTEGER,                 -- E013-E014 (no degree)
  associate_degree   INTEGER,                 -- E015
  bachelor_degree    INTEGER,                 -- E016
  graduate_degree    INTEGER,                 -- E017-E019 (Master's, Professional, Doctorate)
  bachelor_or_higher INTEGER,                 -- E016+E017+E018+E019
  acs_year           INTEGER NOT NULL,        -- 2022
  release_id         TEXT NOT NULL,
  fetched_at         INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_us_acs_education_year ON us_acs_education_attributes (acs_year);
