-- Migration 130: Translations table
-- dr5hn translations.csv: 2,965,565 rows
-- Schema: (place_id, place_type, language, translation)
-- - place_id: references the place (FK varies by place_type)
-- - place_type: 'city' | 'state' | 'country' | 'subregion' | 'region'
-- - language: ISO 639-1 code (e.g. 'ja', 'es', 'ar', 'zh-CN')
-- - translation: name in that language
-- Composite PK: (place_id, place_type, language) — each place has at most
-- one translation per language.

CREATE TABLE IF NOT EXISTS translations (
  place_id INTEGER NOT NULL,
  place_type TEXT NOT NULL CHECK (place_type IN ('city', 'state', 'country', 'subregion', 'region')),
  language TEXT NOT NULL,
  translation TEXT NOT NULL,
  PRIMARY KEY (place_id, place_type, language)
) WITHOUT ROWID;

-- Indexes for common queries
CREATE INDEX IF NOT EXISTS idx_translations_city ON translations(place_id, language) WHERE place_type = 'city';
CREATE INDEX IF NOT EXISTS idx_translations_country ON translations(place_id, language) WHERE place_type = 'country';
CREATE INDEX IF NOT EXISTS idx_translations_state ON translations(place_id, language) WHERE place_type = 'state';
CREATE INDEX IF NOT EXISTS idx_translations_lang_search ON translations(language, translation) WHERE place_type = 'city';

-- FTS5 for searching translations (e.g. "find city named '東京' in Japanese")
-- Will be populated in migration 132 after data load.
CREATE VIRTUAL TABLE IF NOT EXISTS translations_fts USING fts5(
  translation,
  content='translations',
  content_rowid='rowid',
  tokenize='unicode61'
);

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('130_translations_schema', 'Create translations table + FTS5 index for 19 langs');
