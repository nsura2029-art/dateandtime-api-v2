-- Migration 144: Index alt_names_staging.alternate_name for the M11.1.5 search strategy
--
-- The M11.1.5 search strategy A2 in src/routes/cities.ts does:
--   WHERE LOWER(ans.alternate_name) LIKE LOWER(?)
--   AND ans.isolanguage IN ('', 'en')
--   AND ans.release_id = ?
--
-- Without an index, this is a 767K-row table scan (~150ms each).
-- With the index, it's ~5ms.
--
-- Index is on (release_id, isolanguage, alternate_name) so the prefix
-- LIKE can use the index range scan.
--
-- Idempotent: CREATE INDEX IF NOT EXISTS.

CREATE INDEX IF NOT EXISTS idx_alt_names_staging_search
  ON alt_names_staging (release_id, isolanguage, alternate_name);
