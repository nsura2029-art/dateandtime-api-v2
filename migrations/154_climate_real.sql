-- Migration 154: Real climate data (M11.8)
-- Open-Meteo Historical API aggregates 2020-2023 daily data to monthly normals.
-- For 30K cities, this gives 360K monthly rows (30K × 12).

CREATE TABLE IF NOT EXISTS climate_real (
  city_id        INTEGER NOT NULL,
  month          INTEGER NOT NULL,        -- 1-12
  avg_high_c     REAL,                    -- average daily max temperature (°C)
  avg_low_c      REAL,                    -- average daily min temperature (°C)
  precipitation_mm REAL,                  -- total precipitation (mm/month)
  data_years     TEXT NOT NULL,           -- e.g. '2020-2023'
  source         TEXT NOT NULL,           -- 'open-meteo'
  release_id     TEXT NOT NULL,
  retrieved_at   INTEGER NOT NULL,
  PRIMARY KEY (city_id, month)
);

CREATE INDEX IF NOT EXISTS idx_climate_real_city ON climate_real (city_id);
