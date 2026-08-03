-- Migration 153: Wikidata P-code properties (M11.2.8)
-- Adds P31 (instance of), P17 (country), P131 (admin entity), P625 (coord), P421 (timezone)
-- These enable richer descriptions and cross-source validation.

CREATE TABLE IF NOT EXISTS wikidata_properties (
  qid            TEXT PRIMARY KEY,        -- Wikidata Q-id (e.g. 'Q60')
  instance_of    TEXT,                    -- P31: Q-id of the class (e.g. 'Q515' for city)
  country_qid    TEXT,                    -- P17: Q-id of the country
  admin_qid      TEXT,                    -- P131: Q-id of the administrative entity
  coord_lat      REAL,                    -- P625: latitude
  coord_lon      REAL,                    -- P625: longitude
  timezone_qid   TEXT,                    -- P421: Q-id of the timezone (e.g. 'Q1313' for UTC)
  release_id     TEXT NOT NULL,
  retrieved_at   INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_wikidata_props_country ON wikidata_properties (country_qid);
CREATE INDEX IF NOT EXISTS idx_wikidata_props_instance ON wikidata_properties (instance_of);
