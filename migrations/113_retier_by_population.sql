-- Migration 113: Re-tier cities based on population + capital status
-- Rules (per user spec 2026-08-01):
--   tier1: population > 4,000,000 (largest, most developed metros)
--   tier2: 1M-4M population OR state/country capital
--   tier3: < 1M, not a capital
--
-- ORDER MATTERS: tier1 first, then capitals → tier2, then 1M-4M (non-capital) → tier2,
-- finally rest → tier3. Otherwise capitals with >4M pop get demoted to tier2.
--
-- Idempotent: resets tier to NULL first.

-- Step 0: Reset all tiers
UPDATE cities SET tier = NULL;

-- Step 1: tier1 — population > 4M
UPDATE cities SET tier = 'tier1' WHERE population IS NOT NULL AND population > 4000000;

-- Step 2: tier2 — state or country capital (any pop) — overrides tier1 only for capitals
-- Wait, we want capitals with pop > 4M to STAY tier1. So:
-- Set capitals to tier2 ONLY if they're not already tier1.
UPDATE cities
SET tier = 'tier2'
WHERE is_capital = 1 AND (population IS NULL OR population <= 4000000);

-- Step 3: tier2 — 1M-4M (and not already tier1 or tier2)
UPDATE cities
SET tier = 'tier2'
WHERE population IS NOT NULL
  AND population >= 1000000
  AND population <= 4000000
  AND tier IS NULL;

-- Step 4: tier3 — everything else
UPDATE cities SET tier = 'tier3' WHERE tier IS NULL;
