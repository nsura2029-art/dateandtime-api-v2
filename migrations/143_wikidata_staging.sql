-- Migration 143: wikidata_staging + new cities.wiki_url column
--
-- Brings in additional city data from Wikidata:
--   - English label (often the canonical name, may differ from dr5hn's "name")
--   - Alt labels (skos:altLabel) — additional alternate names
--   - Wikipedia sitelink URL
--   - Population (P1082) — better than dr5hn's in some cases
--
-- The flow:
--   1. Read dr5hn's wiki_data_id from cities (148K cities have one)
--   2. For each batch of 5K Q-ids, query Wikidata Query Service SPARQL
--   3. Store results in wikidata_staging
--   4. Re-run intelligent_merge.py to add wiki_url to cities
--   5. Layer the Wikidata English label into display_name where it differs
--
-- wikidata_staging holds the raw response; we materialize the layer later.

CREATE TABLE IF NOT EXISTS wikidata_staging (
  staging_id            INTEGER PRIMARY KEY AUTOINCREMENT,
  release_id            TEXT NOT NULL,
  qid                   TEXT NOT NULL,           -- e.g. 'Q656' for Saint Petersburg
  english_label         TEXT,                    -- canonical English name
  alt_labels_json       TEXT,                    -- JSON array of alt names
  wikipedia_url         TEXT,                    -- https://en.wikipedia.org/wiki/...
  wikidata_population   INTEGER,                 -- P1082 (population)
  retrieved_at          INTEGER NOT NULL,
  UNIQUE(release_id, qid)
);

CREATE INDEX IF NOT EXISTS idx_wikidata_staging_qid
  ON wikidata_staging (qid, release_id);

-- Add the new wiki_url column to cities (M11.1 deferred this).
-- NULL by default; populated by post-Wikidata layer merge.
ALTER TABLE cities ADD COLUMN wiki_url TEXT;
