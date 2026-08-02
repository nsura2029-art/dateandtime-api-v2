-- Migration 141: Index cities.search_name for the new M11.1 ranking strategy
--
-- M11.1 added the `search_name` column (pre-normalized: lowercase, no diacritics,
-- alphanum only) but didn't index it. The new search ranking strategy A in
-- src/routes/cities.ts does `WHERE ci.search_name LIKE ?` with a prefix pattern.
-- Without an index, this is a full table scan (170K rows, ~50ms each).
-- With the index, it's ~5ms.
--
-- Index is partial (WHERE search_name IS NOT NULL) because 60% of cities
-- (dr5hn untouched) don't have search_name set. The index only covers
-- the 40% that do.
--
-- Idempotent: CREATE INDEX IF NOT EXISTS.

CREATE INDEX IF NOT EXISTS idx_cities_search_name ON cities (search_name)
WHERE search_name IS NOT NULL;
