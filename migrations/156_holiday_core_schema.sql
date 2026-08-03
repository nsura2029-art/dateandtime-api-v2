-- Migration 156: Holidays — Core Schema (M13 MVP)
-- 10 atomic dimensions per spec section 4.
-- Concepts (abstract) + Occurrences (concrete dates) split.
-- Every occurrence has source lineage.
-- Country filter policy drives the variance endpoint (US=18 filters, NL=4).

-- ============================================================================
-- holiday_filter: catalog of all filter codes (1 row per code)
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_filter (
  code              TEXT PRIMARY KEY,            -- 'PUBLIC_NATIONAL', 'OBS_IMPORTANT', etc.
  label_en          TEXT NOT NULL,
  atomic_legal_status   TEXT,                    -- 'public', 'de_facto', 'optional', etc.
  atomic_scope_level    TEXT,                    -- 'country', 'subdivision', 'locality', 'global'
  atomic_observance_rank TEXT,                   -- 'important', 'common', 'other', 'local'
  atomic_tradition      TEXT,                    -- 'christian', 'jewish', 'muslim', etc.
  atomic_event_domain   TEXT,                    -- 'civil', 'religious', 'UN', 'astronomical', etc.
  atomic_op_effect      TEXT,                    -- 'work_off', 'school_closed', 'bank_closed', etc.
  description       TEXT,
  default_state     TEXT DEFAULT 'unsupported', -- 'unsupported' | 'supported_empty' | 'available' | 'degraded'
  default_selected  INTEGER DEFAULT 0,
  display_order     INTEGER DEFAULT 100,
  created_at        INTEGER NOT NULL
);

-- ============================================================================
-- holiday_concept: abstract "what" (e.g., 'Christmas Day')
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_concept (
  id               INTEGER PRIMARY KEY,
  name_en          TEXT NOT NULL,                -- 'Christmas Day'
  name_local       TEXT,                         -- 'Kerstmis', 'Navidad', etc.
  tradition        TEXT,                         -- 'christian', 'jewish', 'muslim', etc.
  description      TEXT,
  wikidata_qid     TEXT,                         -- cross-source link
  release_id       TEXT,
  created_at       INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_holiday_concept_tradition ON holiday_concept(tradition);

-- ============================================================================
-- holiday_occurrence: the "when + where" (concrete date in specific scope)
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_occurrence (
  id               INTEGER PRIMARY KEY,
  concept_id       INTEGER NOT NULL,             -- FK to holiday_concept
  country_id       INTEGER NOT NULL,             -- FK to countries
  subdivision_code TEXT,                         -- ISO 3166-2 (e.g. 'US-FL'), NULL for national
  locality_name    TEXT,                         -- free text for city-specific holidays
  start_date       TEXT NOT NULL,                -- ISO 8601 YYYY-MM-DD (the actual date)
  end_date         TEXT,                         -- for multi-day events
  observed_date    TEXT,                         -- when it is observed (e.g. observed Monday)
  date_role        TEXT NOT NULL DEFAULT 'actual', -- 'actual' | 'observed' | 'substitute' | 'in_lieu' | 'working_day_swap'
  legal_status     TEXT,                         -- 'public' | 'de_facto' | 'optional' | 'observance' | 'half_day' | 'working_day_override'
  scope_level      TEXT NOT NULL DEFAULT 'country', -- 'global' | 'country' | 'subdivision' | 'locality' | 'organization'
  event_domain     TEXT,                         -- 'civil' | 'religious' | 'UN' | 'worldwide' | 'astronomical' | 'time_zone' | 'sports' | 'election' | 'school' | 'finance'
  prominence       TEXT,                         -- 'major' | 'additional' | 'standard'
  date_status      TEXT NOT NULL DEFAULT 'confirmed', -- 'confirmed' | 'official_announced' | 'calculated' | 'tentative' | 'moon_sighting_pending' | 'estimated' | 'canceled'
  tentative_reason TEXT,                         -- explanation when date_status != 'confirmed'
  is_working_day   INTEGER,                      -- 1 if this date is a mandatory workday (China-style swap)
  notes            TEXT,
  release_id       TEXT,
  created_at       INTEGER NOT NULL,
  updated_at       INTEGER NOT NULL,
  FOREIGN KEY (concept_id) REFERENCES holiday_concept(id),
  FOREIGN KEY (country_id) REFERENCES countries(id)
);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_country ON holiday_occurrence(country_id, start_date);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_concept ON holiday_occurrence(concept_id);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_subdiv ON holiday_occurrence(subdivision_code);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_date ON holiday_occurrence(start_date);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_status ON holiday_occurrence(date_status);

-- ============================================================================
-- holiday_occurrence_filter: M:N — one event can be in many filters
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_occurrence_filter (
  occurrence_id    INTEGER NOT NULL,
  filter_code      TEXT NOT NULL,
  PRIMARY KEY (occurrence_id, filter_code),
  FOREIGN KEY (occurrence_id) REFERENCES holiday_occurrence(id) ON DELETE CASCADE,
  FOREIGN KEY (filter_code) REFERENCES holiday_filter(code)
);
CREATE INDEX IF NOT EXISTS idx_holiday_occ_filter_filter ON holiday_occurrence_filter(filter_code);

-- ============================================================================
-- holiday_source: per-source metadata (links to source_registry via source_key)
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_source (
  source_key       TEXT PRIMARY KEY,
  authority_tier   TEXT NOT NULL,                -- A (official) | B (operational) | C (licensed) | D (open) | E (institutional) | F (community)
  organization     TEXT NOT NULL,                -- 'OpenHolidays API', 'Nager.Date', etc.
  scope_country    TEXT,                         -- ISO 3166-1 alpha-2 or NULL for global
  filters          TEXT,                         -- comma-separated filter codes
  format           TEXT,                         -- 'ics' | 'json' | 'html' | 'csv'
  endpoint_url     TEXT,
  license          TEXT,                         -- 'ODbL', 'MIT', 'CC0', etc.
  license_url      TEXT,
  attribution      TEXT,
  redistribution_allowed INTEGER DEFAULT 1,
  commercial_use_allowed INTEGER DEFAULT 1,
  is_active        INTEGER DEFAULT 1,
  notes            TEXT,
  created_at       INTEGER NOT NULL,
  updated_at       INTEGER NOT NULL
);

-- ============================================================================
-- holiday_occurrence_source: which sources contribute to this occurrence
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_occurrence_source (
  occurrence_id    INTEGER NOT NULL,
  source_key       TEXT NOT NULL,
  assertion_role   TEXT NOT NULL DEFAULT 'asserted', -- 'asserted' | 'calculated' | 'derived' | 'cross_check'
  freshness        TEXT,                         -- ISO timestamp when this assertion was made
  raw_payload      TEXT,                         -- JSON of the raw source record
  PRIMARY KEY (occurrence_id, source_key),
  FOREIGN KEY (occurrence_id) REFERENCES holiday_occurrence(id) ON DELETE CASCADE,
  FOREIGN KEY (source_key) REFERENCES holiday_source(source_key)
);

-- ============================================================================
-- holiday_revision: change tracking
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_revision (
  id               INTEGER PRIMARY KEY,
  occurrence_id    INTEGER NOT NULL,
  change_type      TEXT NOT NULL,                -- 'added' | 'removed' | 'date_changed' | 'observed_date_changed' | 'scope_changed' | 'renamed' | 'confirmed' | 'canceled' | 'working_day_swap'
  before_state     TEXT,                         -- JSON of before
  after_state      TEXT,                         -- JSON of after
  source_key       TEXT,                         -- which source triggered the change
  reason           TEXT,
  created_at       INTEGER NOT NULL,
  FOREIGN KEY (occurrence_id) REFERENCES holiday_occurrence(id) ON DELETE CASCADE
);
CREATE INDEX IF NOT EXISTS idx_holiday_revision_occ ON holiday_revision(occurrence_id, created_at);
CREATE INDEX IF NOT EXISTS idx_holiday_revision_created ON holiday_revision(created_at);

-- ============================================================================
-- country_filter_policy: per-country filter applicability (THE VARIANCE TABLE)
-- ============================================================================
CREATE TABLE IF NOT EXISTS country_filter_policy (
  country_code     TEXT NOT NULL,
  filter_code      TEXT NOT NULL,
  state            TEXT NOT NULL DEFAULT 'unsupported', -- 'unsupported' | 'supported_empty' | 'available' | 'degraded'
  default_selected INTEGER NOT NULL DEFAULT 0,
  display_order    INTEGER NOT NULL DEFAULT 100,
  notes            TEXT,
  updated_at       INTEGER NOT NULL,
  PRIMARY KEY (country_code, filter_code),
  FOREIGN KEY (filter_code) REFERENCES holiday_filter(code)
);
CREATE INDEX IF NOT EXISTS idx_country_filter_policy_state ON country_filter_policy(country_code, state);

-- ============================================================================
-- holiday_feedback: user reports (Phase 1 of feedback loop)
-- ============================================================================
CREATE TABLE IF NOT EXISTS holiday_feedback (
  id               INTEGER PRIMARY KEY,
  occurrence_id    INTEGER,                      -- NULL if general report
  report_type      TEXT NOT NULL,                -- 'wrong_date' | 'wrong_name' | 'missing_holiday' | 'wrong_scope' | 'other'
  severity         TEXT NOT NULL DEFAULT 'P2',  -- P0 | P1 | P2 | P3
  status           TEXT NOT NULL DEFAULT 'open', -- 'open' | 'reviewing' | 'resolved' | 'rejected'
  description      TEXT NOT NULL,
  reporter_email   TEXT,
  reporter_hash    TEXT,                         -- hashed for rate limiting
  evidence_url     TEXT,
  reviewed_by      TEXT,
  reviewed_at      INTEGER,
  resolution_notes TEXT,
  created_at       INTEGER NOT NULL,
  updated_at       INTEGER NOT NULL,
  FOREIGN KEY (occurrence_id) REFERENCES holiday_occurrence(id) ON DELETE SET NULL
);
CREATE INDEX IF NOT EXISTS idx_holiday_feedback_status ON holiday_feedback(status, severity);
CREATE INDEX IF NOT EXISTS idx_holiday_feedback_occurrence ON holiday_feedback(occurrence_id);
CREATE INDEX IF NOT EXISTS idx_holiday_feedback_hash ON holiday_feedback(reporter_hash);
