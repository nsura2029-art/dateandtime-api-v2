-- Migration 146: country_populations (World Bank SP.POP.TOTL)
--
-- Brings country-level population from the World Bank API
-- (https://api.worldbank.org/v2/country/{iso3}/indicator/SP.POP.TOTL).
-- Originally planned as UN WPP 2024, but pivoted to World Bank because:
--   - UN WPP CSV download URLs were 404/500 at fetch time
--   - World Bank has the same data category (country population)
--   - World Bank JSON API is simpler (no big CSV to download/parse)
--   - World Bank is already in source_registry (world_bank / sp-pop-totl)
--   - World Bank data is updated annually (lastupdated: 2026-07-13)
--
-- Use cases:
--   1. Country population fallback: cities.country_id → countries.population
--      (when countries.population is stale or NULL, use country_populations.value)
--   2. Time-series: we store year=2024 as the most recent estimate; can add
--      historical years if needed for trend analysis.
--
-- Schema:
--   country_id   - links to countries.id (matches by cca3 in loader)
--   year         - data year (e.g. 2024)
--   population   - total population (INTEGER)
--   source       - "world_bank" (future-proofing for other sources)
--   release_id   - which source_release row this came from
--   fetched_at   - unix timestamp when we fetched
--   PRIMARY KEY (country_id, year, source) - one row per country per year per source
--
-- The (country_id, year, source) primary key allows multiple sources to coexist
-- (e.g. UN WPP 2024 and World Bank 2024 — keep both, don't overwrite).

CREATE TABLE IF NOT EXISTS country_populations (
  country_id   INTEGER NOT NULL,
  year         INTEGER NOT NULL,
  population   INTEGER NOT NULL,
  source       TEXT NOT NULL DEFAULT 'world_bank',
  release_id   TEXT NOT NULL,
  fetched_at   INTEGER NOT NULL,
  PRIMARY KEY (country_id, year, source)
);

CREATE INDEX IF NOT EXISTS idx_country_populations_year
  ON country_populations(year);

CREATE INDEX IF NOT EXISTS idx_country_populations_country
  ON country_populations(country_id);
