-- Migration 142: alt_names_staging table for GeoNames alternateNamesV2
--
-- GeoNames publishes alternateNamesV2.zip (40M+ rows, ~300MB compressed,
-- 6GB uncompressed) containing all alternate names for all GeoNames records
-- (cities, countries, admin regions, etc.). We only care about the city
-- alternate names (geonameid matching cities_staging.external_id).
--
-- Columns we store:
--   geonameid       - the GeoNames id (joins to cities_staging.external_id)
--   isolanguage     - ISO 639 language code, or empty string for language-agnostic
--                     alt names (postal codes, abbreviations, historic names)
--   alternate_name  - the actual alt name text
--   is_preferred    - 1 if this is the preferred name in this language
--   is_short        - 1 if this is a short/common abbreviation
--   is_colloquial   - 1 if this is a colloquial/informal name
--   is_historic     - 1 if this is a historic name (e.g. Bombay, Edo, Peking)
--
-- Why we want it:
--   1. Historical aliases (is_historic=1) — catch city renames
--      (Bombay→Mumbai, Edo→Tokyo, Peking→Beijing, Constantinople→Istanbul)
--      that the M11.1 layer's Tier 3 (historical_alias) currently misses
--      on the GeoNames side
--   2. Preferred names per language — better display in non-English UIs
--   3. Short names — additional compact aliases for autocomplete
--
-- The intelligence_merge.py script will join this table to enrich the
-- cities_staging layer with is_historic alternate names, then re-run
-- the merge to find more historical_alias matches.

CREATE TABLE IF NOT EXISTS alt_names_staging (
  staging_id        INTEGER PRIMARY KEY AUTOINCREMENT,
  release_id        TEXT NOT NULL,
  geonameid         INTEGER NOT NULL,        -- joins to cities_staging.external_id
  isolanguage       TEXT,                    -- ISO 639 code or '' for lang-agnostic
  alternate_name    TEXT NOT NULL,
  is_preferred      INTEGER DEFAULT 0,
  is_short          INTEGER DEFAULT 0,
  is_colloquial     INTEGER DEFAULT 0,
  is_historic       INTEGER DEFAULT 0,
  loaded_at         INTEGER NOT NULL,
  UNIQUE(release_id, geonameid, isolanguage, alternate_name)
);

CREATE INDEX IF NOT EXISTS idx_alt_names_staging_geonameid
  ON alt_names_staging (geonameid, release_id);

CREATE INDEX IF NOT EXISTS idx_alt_names_staging_historic
  ON alt_names_staging (alternate_name, is_historic)
  WHERE is_historic = 1;

CREATE INDEX IF NOT EXISTS idx_alt_names_staging_lang
  ON alt_names_staging (isolanguage)
  WHERE isolanguage IS NOT NULL AND isolanguage != '';
