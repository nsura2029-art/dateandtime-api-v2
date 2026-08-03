-- Migration 152: ACS 5-Year Tenure (B25003) + Transportation to Work (B08301)
-- Adds per-city housing tenure + commute mode data for US places

-- B25003 Tenure (3 estimate variables, rollup)
-- E001: Total occupied housing units
-- E002: Owner-occupied
-- E003: Renter-occupied
CREATE TABLE IF NOT EXISTS us_acs_tenure_attributes (
  fips_geoid           TEXT PRIMARY KEY,
  total_occupied       INTEGER,            -- E001 total occupied housing units
  owner_occupied       INTEGER,            -- E002 owner occupied
  renter_occupied      INTEGER,            -- E003 renter occupied
  owner_occupied_pct   REAL,               -- owner / total * 100 (computed)
  renter_occupied_pct  REAL,               -- renter / total * 100 (computed)
  acs_year             INTEGER NOT NULL,
  release_id           TEXT NOT NULL,
  fetched_at           INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_us_acs_tenure_year ON us_acs_tenure_attributes (acs_year);

-- B08301 Means of Transportation to Work by Earnings
-- This is actually a cross-tab (transport mode × earnings bracket) with 21 estimate cols.
-- We store all 21 raw columns so the data is preserved; the API exposes useful rollups.
CREATE TABLE IF NOT EXISTS us_acs_transport_attributes (
  fips_geoid            TEXT PRIMARY KEY,
  e001                  INTEGER,            -- Total workers 16+
  e002                  INTEGER,            -- Car, truck, or van
  e003                  INTEGER,            -- (continued)
  e004                  INTEGER,
  e005                  INTEGER,
  e006                  INTEGER,
  e007                  INTEGER,
  e008                  INTEGER,
  e009                  INTEGER,
  e010                  INTEGER,
  e011                  INTEGER,
  e012                  INTEGER,
  e013                  INTEGER,
  e014                  INTEGER,
  e015                  INTEGER,
  e016                  INTEGER,
  e017                  INTEGER,
  e018                  INTEGER,
  e019                  INTEGER,
  e020                  INTEGER,
  e021                  INTEGER,
  car_or_van           INTEGER,            -- Best-guess: car/truck/van (E002 in 17-col layout)
  public_transport_guess INTEGER,          -- Best-guess: public transit (E010 area in 21-col layout)
  worked_at_home_guess  INTEGER,            -- Best-guess: worked at home (later col)
  acs_year              INTEGER NOT NULL,
  release_id            TEXT NOT NULL,
  fetched_at            INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_us_acs_transport_year ON us_acs_transport_attributes (acs_year);
