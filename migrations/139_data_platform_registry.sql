-- Migration 139: Data Platform — Source Registry + Releases
--
-- Creates the source_registry table (10 sources) and source_releases table
-- (every known release, versioned with SHA-256, status, manifest).
-- Also creates a cities_staging table for two-phase commit on city releases.
--
-- This is the foundation of the data ingestion platform (M11.0).
-- GeoNames is the first source; Wikidata, CLDR, UN WPP, etc. follow.

-- ============================================================================
-- source_registry: 10 sources, 1 active at a time
-- ============================================================================
CREATE TABLE IF NOT EXISTS source_registry (
  source_key        TEXT PRIMARY KEY,           -- 'geonames', 'wikidata', etc.
  publisher         TEXT NOT NULL,              -- 'GeoNames', 'Wikimedia Foundation'
  dataset           TEXT NOT NULL,              -- 'cities5000', 'cities500', etc.
  coverage          TEXT,                       -- 'world', 'US-only', etc.
  access_method     TEXT,                       -- 'https-zip', 'https-json', 's3', 'rss'
  endpoint_url      TEXT,                       -- where to fetch
  license           TEXT,                       -- 'CC-BY-4.0', 'public-domain', etc.
  license_url       TEXT,
  attribution       TEXT,                       -- exact attribution text
  refresh_policy    TEXT,                       -- 'annual', 'decennial', 'on-release', 'monthly'
  known_limitations TEXT,
  is_active         INTEGER DEFAULT 1,          -- 1 = enabled, 0 = paused
  created_at        INTEGER NOT NULL,
  updated_at        INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_source_registry_active ON source_registry(is_active);

-- ============================================================================
-- source_releases: every known release of every source
-- ============================================================================
CREATE TABLE IF NOT EXISTS source_releases (
  release_id          TEXT PRIMARY KEY,         -- e.g. 'geonames-cities5000-2026-08-01'
  source_key          TEXT NOT NULL,           -- FK to source_registry.source_key
  release_date        TEXT NOT NULL,           -- ISO date from publisher
  discovered_at       INTEGER NOT NULL,
  status              TEXT,                     -- discovered|downloading|raw-stored|parsing|normalized|staging|published|rejected|superseded
  raw_sha256          TEXT,
  raw_size_bytes      INTEGER,
  raw_r2_key          TEXT,
  normalized_r2_key   TEXT,
  row_count_in        INTEGER,
  row_count_accepted  INTEGER,
  row_count_rejected  INTEGER,
  manifest_r2_key     TEXT,
  workflow_run_id     TEXT,
  error_message       TEXT,
  started_at          INTEGER,
  finished_at         INTEGER,
  published_at        INTEGER,
  FOREIGN KEY (source_key) REFERENCES source_registry(source_key)
);

CREATE INDEX IF NOT EXISTS idx_source_releases_status ON source_releases(status);
CREATE INDEX IF NOT EXISTS idx_source_releases_source ON source_releases(source_key, status);

-- ============================================================================
-- cities_staging: two-phase commit staging area for city releases
-- ============================================================================
-- Live cities table is read by /api/v1/cities/* — never written to directly.
-- New releases go to cities_staging first; reconciliation + atomic swap
-- move them to live. Failed runs leave live data untouched.
CREATE TABLE IF NOT EXISTS cities_staging (
  staging_id        INTEGER PRIMARY KEY AUTOINCREMENT,
  release_id        TEXT NOT NULL,             -- which release this row came from
  external_id       TEXT NOT NULL,             -- GeoNames geonameid
  name              TEXT NOT NULL,
  ascii_name        TEXT,
  latitude          REAL NOT NULL,
  longitude         REAL NOT NULL,
  country_code      TEXT,                      -- ISO 3166-1 alpha-2
  admin1_code       TEXT,                      -- state/province code
  admin2_code       TEXT,                      -- county code
  feature_class     TEXT,                      -- 'P' for populated place
  feature_code      TEXT,                      -- 'PPL', 'PPLA', 'PPLC', etc.
  population        INTEGER,
  elevation         INTEGER,
  dem               INTEGER,                   -- digital elevation model
  timezone          TEXT,                      -- IANA timezone
  modified_date     TEXT,
  loaded_at         INTEGER NOT NULL,
  UNIQUE(release_id, external_id)
);

CREATE INDEX IF NOT EXISTS idx_cities_staging_release ON cities_staging(release_id);
CREATE INDEX IF NOT EXISTS idx_cities_staging_country ON cities_staging(country_code, admin1_code);

-- ============================================================================
-- Seed: register 10 sources (1 active: GeoNames, 9 planned)
-- ============================================================================
INSERT OR IGNORE INTO source_registry (source_key, publisher, dataset, coverage, access_method, endpoint_url, license, license_url, attribution, refresh_policy, known_limitations, is_active, created_at, updated_at)
VALUES
  ('geonames',     'GeoNames',                'cities5000',  'world',     'https-zip',  'https://download.geonames.org/export/dump/cities5000.zip',    'CC-BY-4.0',  'https://creativecommons.org/licenses/by/4.0/',  'Contains data from GeoNames (https://www.geonames.org/), licensed under CC-BY 4.0.', 'monthly',  'Sub-15K villages not included. License requires attribution.', 1, strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('wikidata',     'Wikimedia Foundation',    'entities',    'world',     'https-json', 'https://www.wikidata.org/wiki/Special:EntityData/',        'CC0',        'https://creativecommons.org/publicdomain/zero/1.0/', 'Wikidata is in the public domain (CC0).', 'weekly', 'Bulk dump preferred over SPARQL. SPARQL has rate limits.', 0, strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('cldr',         'Unicode Consortium',      'cldr-46',     'world',     'https-zip',  'https://unicode.org/Public/cldr/46/cldr-46.0.zip',          'Unicode-DFS', 'https://www.unicode.org/copyright.html',           'Copyright © 1991-2025 Unicode, Inc. All rights reserved.', 'quarterly', 'Lang population estimates may not be current. NOT final legal authority.', 0, strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('un_wpp',       'United Nations DESA',     'wpp-2024',    'world',     'https-zip',  'https://population.un.org/wpp/Download/Standard/CSV/',       'CC-BY-3.0-IGO', 'https://creativecommons.org/licenses/by/3.0/igo/', 'Source: United Nations, Department of Economic and Social Affairs, Population Division.', 'biennial', 'Country-level only. No city breakdown.', 0, strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('us_census',    'U.S. Census Bureau',      'vintage-2024','US',        'https-csv',  'https://www2.census.gov/programs-surveys/popest/datasets/2020-2024/cities/totals/sub-est2024.csv', 'Public Domain', 'https://www.census.gov/about/policies.html', 'U.S. Census Bureau data — public domain.', 'annual', 'Decennial + 5-year ACS vintages need separate tracking.', 0, strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('eurostat',     'Eurostat',                'city-stats',  'EU+EFTA+UK','https-json', 'https://ec.europa.eu/eurostat/api/dissemination/sdmx/2.1/', 'CC-BY-4.0',  'https://ec.europa.eu/eurostat/about/policies/copyright', '© European Union, 1995-2025. Reuse authorised with attribution.', 'annual', 'Distinguishes City, FUA, NUTS regions, LAU.', 0, strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('census_india', 'Office of the Registrar General & Census Commissioner, India', 'population_finder', 'IN', 'https-html', 'https://censusindia.gov.in/pca/SearchData.aspx', 'OGL-India', 'https://data.gov.in/', 'Source: Office of the Registrar General & Census Commissioner, India.', 'decennial', '2011 still official at town level. No good API — HTML scraping needed.', 0, strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('india_proj',   'Government of India',     'state-projection-2011-2036', 'IN', 'https-pdf', 'https://niti.gov.in/sites/default/files/2020-01/State-wise-Projection-2036.pdf', 'OGL-India', 'https://data.gov.in/', 'Government of India population projections 2011-2036.', 'decennial', 'State-level only. PDF data, needs parsing.', 0, strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('world_bank',   'The World Bank',          'sp-pop-totl', 'world',     'https-json', 'https://api.worldbank.org/v2/country/all/indicator/SP.POP.TOTL?format=json', 'CC-BY-4.0', 'https://www.worldbank.org/en/about/legal/terms-of-use', 'Source: World Bank Indicators.', 'annual', 'Stored SEPARATELY from WPP — do not average/overwrite.', 0, strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('nso',          'Future National Statistical Offices', 'TBD', 'varies', 'TBD', NULL, 'TBD', NULL, 'TBD', 'TBD', 'Drop until a specific NSO is in mind.', 0, strftime('%s','now')*1000, strftime('%s','now')*1000);
