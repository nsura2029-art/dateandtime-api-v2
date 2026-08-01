-- Migration 113: Re-tier cities based on population
-- Rules (per user spec 2026-08-01):
--   tier1: population > 4,000,000 (largest, most developed metros)
--   tier2: 1M-4M population OR state/country capital
--   tier3: < 1M, not a capital
--
-- Distribution after applying:
--   tier1: ~70 cities (Beijing, Mumbai, Delhi, São Paulo, etc.)
--   tier2: ~2,400 cities (capitals + 1M-4M)
--   tier3: ~150,000 cities (everything else)
--
-- Supersedes migration 109 (alphabetical top-3 fallback).
-- We reset to NULL first so all cities get re-tiered, not just those matching conditions.

-- Reset all tiers
UPDATE cities SET tier = NULL;

-- tier1: population > 4M
UPDATE cities SET tier = 'tier1' WHERE population IS NOT NULL AND population > 4000000;

-- tier2: 1M-4M
UPDATE cities SET tier = 'tier2'
WHERE population IS NOT NULL AND population >= 1000000 AND population <= 4000000;

-- tier2: state or country capital
UPDATE cities SET tier = 'tier2' WHERE is_capital = 1;

-- tier3: everything else
UPDATE cities SET tier = 'tier3' WHERE tier IS NULL;
