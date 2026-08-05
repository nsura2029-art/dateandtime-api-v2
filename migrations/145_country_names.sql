-- Migration 145: country_names (CLDR territory translations)
--
-- Brings localized country names from Unicode CLDR (cldr-common-48.2).
-- The 20 target languages: en, es, fr, de, zh, ja, ko, ru, ar, hi,
-- pt, it, tr, nl, pl, sv, uk, he, fa, th.
--
-- Schema:
--   country_id  - links to countries.id
--   language    - ISO 639-1 (en, es, fr, de, ...) — also supports regional codes
--                 like 'zh-CN', 'pt-BR' (treat as separate language entries)
--   name        - localized name (e.g. "Estados Unidos")
--   short_name  - optional short form (e.g. "U.K.") — only 6-10 entries per language
--   source      - which dataset (always 'cldr' for now)
--   release_id  - which CLDR release was used
--
-- Notes:
--   - CLDR uses ISO 3166-1 alpha-2 codes for territory type, matching our countries.cca2.
--     Numeric territory codes (UN M.49 like 142 = Asia) are skipped.
--   - CLDR territory names may not match official names; they're customary names
--     (e.g. "Estados Unidos" instead of "Estados Unidos Mexicanos" for Mexico).
--   - Our dr5hn `countries.name` and `countries.official_name` remain the base values
--     (English name + local official name). The CLDR layer adds 19 more languages.

CREATE TABLE IF NOT EXISTS country_names (
  country_id   INTEGER NOT NULL,
  language     TEXT NOT NULL,
  name         TEXT NOT NULL,
  short_name   TEXT,
  source       TEXT NOT NULL DEFAULT 'cldr',
  release_id   TEXT NOT NULL,
  PRIMARY KEY (country_id, language, source)
);

CREATE INDEX IF NOT EXISTS idx_country_names_lang
  ON country_names(language);

CREATE INDEX IF NOT EXISTS idx_country_names_country
  ON country_names(country_id);

CREATE INDEX IF NOT EXISTS idx_country_names_lookup
  ON country_names(language, name);
