-- Migration 157: Holiday schema — worldwide support + categories + observances
-- Adds: worldwide flag, category, origin, subdivision column on holiday_occurrence
-- Make country_id nullable so we can have international/UN rows
-- Adds: holiday_occurrence_states (M:N) for per-state details
-- Used by: enrichment engine (M14) for US, India, NZ, future countries

-- Disable FK during table rebuilds
PRAGMA foreign_keys = OFF;

-- ============================================================================
-- 1. Make country_id nullable for worldwide / international occurrences
-- ============================================================================
-- SQLite can't ALTER COLUMN, so we recreate the table
CREATE TABLE IF NOT EXISTS holiday_occurrence_new (
  id               INTEGER PRIMARY KEY,
  concept_id       INTEGER NOT NULL,
  country_id       INTEGER,                       -- NULL for worldwide/UN
  subdivision_code TEXT,                          -- ISO 3166-2 (e.g. 'US-FL'), NULL for national
  locality_name    TEXT,                          -- free text for city-specific holidays
  start_date       TEXT NOT NULL,
  end_date         TEXT,
  observed_date    TEXT,
  date_role        TEXT NOT NULL DEFAULT 'actual',
  legal_status     TEXT,                          -- 'public' | 'de_facto' | 'optional' | 'observance' | 'half_day'
  scope_level      TEXT NOT NULL DEFAULT 'country', -- 'global' | 'country' | 'subdivision' | 'locality' | 'organization'
  event_domain     TEXT,                          -- 'civil' | 'religious' | 'UN' | 'worldwide' | 'astronomical' | 'time_zone' | 'sports' | 'election' | 'school' | 'finance'
  prominence       TEXT,                          -- 'major' | 'additional' | 'standard'
  date_status      TEXT NOT NULL DEFAULT 'confirmed',
  tentative_reason TEXT,
  is_working_day   INTEGER,
  notes            TEXT,
  -- ====== NEW (M14 enrichment) ======
  worldwide        INTEGER DEFAULT 0,             -- 1 if applicable to all countries (UN days, New Year, Christmas as global event)
  category         TEXT DEFAULT 'public_holiday', -- 'public_holiday' | 'observance' | 'religious' | 'international' | 'season' | 'clock_change' | 'sporting_event' | 'election' | 'school_break' | 'bank_closure'
  origin           TEXT DEFAULT 'manual',         -- 'nager_date' | 'openholidays' | 'hebcal' | 'un_official' | 'computed_easter' | 'computed_federal' | 'computed_season' | 'computed_dst' | 'manual_csv' | 'migration_157'
  -- ====== /NEW ======
  release_id       TEXT,
  created_at       INTEGER NOT NULL,
  updated_at       INTEGER NOT NULL,
  FOREIGN KEY (concept_id) REFERENCES holiday_concept(id),
  FOREIGN KEY (country_id) REFERENCES countries(id)
);

INSERT INTO holiday_occurrence_new (
  id, concept_id, country_id, subdivision_code, locality_name,
  start_date, end_date, observed_date, date_role, legal_status,
  scope_level, event_domain, prominence, date_status, tentative_reason,
  is_working_day, notes, release_id, created_at, updated_at
) SELECT
  id, concept_id, country_id, subdivision_code, locality_name,
  start_date, end_date, observed_date, date_role, legal_status,
  scope_level, event_domain, prominence, date_status, tentative_reason,
  is_working_day, notes, release_id, created_at, updated_at
FROM holiday_occurrence;

DROP TABLE holiday_occurrence;
ALTER TABLE holiday_occurrence_new RENAME TO holiday_occurrence;

-- Recreate indexes
CREATE INDEX IF NOT EXISTS idx_holiday_occ_country ON holiday_occurrence(country_id, start_date);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_concept ON holiday_occurrence(concept_id);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_subdiv ON holiday_occurrence(subdivision_code);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_date ON holiday_occurrence(start_date);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_status ON holiday_occurrence(date_status);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_worldwide ON holiday_occurrence(worldwide, start_date);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_category ON holiday_occurrence(category, start_date);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_origin ON holiday_occurrence(origin, start_date);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_country_subdiv_date ON holiday_occurrence(country_id, subdivision_code, start_date);

-- ============================================================================
-- 2. Extend holiday_concept: worldwide flag, origin
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_concept_new (
  id               INTEGER PRIMARY KEY,
  name_en          TEXT NOT NULL,
  name_local       TEXT,
  tradition        TEXT,
  description      TEXT,
  wikidata_qid     TEXT,
  release_id       TEXT,
  -- ====== NEW (M14 enrichment) ======
  worldwide        INTEGER DEFAULT 0,             -- 1 if observed globally (New Year, Christmas, etc.)
  origin           TEXT DEFAULT 'manual',
  -- ====== /NEW ======
  created_at       INTEGER NOT NULL
);

INSERT INTO holiday_concept_new (id, name_en, name_local, tradition, description, wikidata_qid, release_id, created_at)
SELECT id, name_en, name_local, tradition, description, wikidata_qid, release_id, created_at
FROM holiday_concept;

DROP TABLE holiday_concept;
ALTER TABLE holiday_concept_new RENAME TO holiday_concept;

CREATE INDEX IF NOT EXISTS idx_holiday_concept_tradition ON holiday_concept(tradition);
CREATE INDEX IF NOT EXISTS idx_holiday_concept_worldwide ON holiday_concept(worldwide);

-- Re-enable FK
PRAGMA foreign_keys = ON;

-- ============================================================================
-- 3. New: holiday_occurrence_state — detailed per-state mentions
-- Used to express "in details mention state" (e.g., Diwali is State Holiday in CA/PA,
-- State Observance in CT/NC, Hindu Holiday everywhere)
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_occurrence_state (
  id               INTEGER PRIMARY KEY,
  occurrence_id    INTEGER NOT NULL,
  subdivision_code TEXT NOT NULL,                 -- 'US-CA', 'IN-MH', etc.
  role             TEXT NOT NULL,                 -- 'legal_holiday' | 'observance' | 'closed' | 'partial' | 'unrecognized'
  source_key       TEXT,                          -- which source asserts this state-level application
  notes            TEXT,
  FOREIGN KEY (occurrence_id) REFERENCES holiday_occurrence(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_state_occ ON holiday_occurrence_state(occurrence_id);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_state_subdiv ON holiday_occurrence_state(subdivision_code);
CREATE UNIQUE INDEX IF NOT EXISTS idx_holiday_occ_state_unique ON holiday_occurrence_state(occurrence_id, subdivision_code, role);

-- ============================================================================
-- 4. New: holiday_un_day — UN observance registry (for the variance endpoint)
-- Each row = one international day that the UN celebrates on a fixed date
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_un_day (
  id               INTEGER PRIMARY KEY,
  name_en          TEXT NOT NULL,
  name_short       TEXT,                          -- 'International Day of Peace'
  date_observed    TEXT NOT NULL,                 -- 'MM-DD' format (no year, applies every year)
  year_started     INTEGER,
  resolution_url   TEXT,                          -- UN General Assembly resolution
  agency           TEXT,                          -- 'UNESCO', 'WHO', 'UN', 'UNICEF', etc.
  description      TEXT,
  tags             TEXT,                          -- JSON array of tags
  created_at       INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_holiday_un_day_date ON holiday_un_day(date_observed);

-- ============================================================================
-- 5. New: holiday_country_un_day — which countries formally observe each UN day
-- Most UN days are observed by all member states; this table marks the ones
-- that have a formal state-recognized status (used for country_filter_policy)
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_country_un_day (
  un_day_id        INTEGER NOT NULL,
  country_code     TEXT NOT NULL,                 -- ISO 3166-1 alpha-2
  status           TEXT NOT NULL,                 -- 'observed' | 'official_holiday' | 'public_holiday' | 'awareness_only'
  year_started     INTEGER,
  notes            TEXT,
  PRIMARY KEY (un_day_id, country_code),
  FOREIGN KEY (un_day_id) REFERENCES holiday_un_day(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_holiday_country_un_country ON holiday_country_un_day(country_code);

-- ============================================================================
-- 6. Extend country_filter_policy: add state_applies (e.g., 'US-FL:optional')
-- ============================================================================
-- Already has state column with 'unsupported'|'supported_empty'|'available'|'degraded'
-- No schema change needed, just add notes documenting the M:N pattern

-- ============================================================================
-- 7. Seed new sources
-- ============================================================================
INSERT OR IGNORE INTO holiday_source (source_key, authority_tier, organization, scope_country, filters, format, endpoint_url, license, license_url, attribution, redistribution_allowed, commercial_use_allowed, is_active, notes, created_at, updated_at) VALUES
  ('hebcal', 'D', 'Hebcal.com', NULL, 'JEWISH_MAJOR,JEWISH_MORE,OTHER_RELIGION', 'json', 'https://www.hebcal.com/hebcal', 'MIT', 'https://www.hebcal.com/home/49', 'Hebcal - Jewish Calendar', 1, 1, 1, 'Open Jewish holiday API, MIT-licensed', strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('un_official', 'B', 'United Nations', NULL, 'UN_OBSERVANCE,WORLD_OBSERVANCE', 'json', 'https://www.un.org/en/observances', 'Public Domain', 'https://www.un.org/en/about-us/copyright', 'United Nations', 1, 1, 1, 'UN General Assembly international days and weeks', strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('computed_season', 'C', 'Astronomical algorithm (Meeus)', NULL, 'SEASON', 'derived', NULL, 'Internal', NULL, 'Computed from Julian Day + Meeus', 1, 1, 1, 'Seasons computed in code, not from external source', strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('computed_federal_us', 'C', '5 U.S.C. § 6103', 'US', 'PUBLIC_NATIONAL,GOVERNMENT_CLOSURE', 'derived', 'https://www.law.cornell.edu/uscode/text/5/6103', 'Public Domain', NULL, '5 U.S.C. § 6103', 1, 1, 1, 'US federal holidays from statute', strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('employment_nz', 'A', 'Employment New Zealand', 'NZ', 'PUBLIC_NATIONAL,PUBLIC_LOCAL,GOVERNMENT_CLOSURE', 'html', 'https://www.employment.govt.nz/leave-and-holidays/public-holidays/public-holidays-and-anniversary-dates', 'Crown Copyright', 'https://www.employment.govt.nz/about-this-site/copyright', 'New Zealand Government', 1, 1, 1, 'Tier A official source for NZ', strftime('%s','now')*1000, strftime('%s','now')*1000),
  ('drikpanchang', 'D', 'DrikPanchang', 'IN', 'HINDU_MAJOR,HINDU_MORE', 'json', 'https://www.drikpanchang.com', 'CC-BY', 'https://www.drikpanchang.com/disclaimer.html', 'DrikPanchang.com', 1, 1, 0, 'Hindu panchang, CC-BY. Disabled until API access.', strftime('%s','now')*1000, strftime('%s','now')*1000);
