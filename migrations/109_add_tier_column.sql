-- Migration 109: Add tier classification to cities
-- tier1: country or state capital
-- tier2: top 3 cities per state (alphabetical fallback — will improve with GeoNames population)
-- tier3: everything else

-- 1. Add column
ALTER TABLE cities ADD COLUMN tier TEXT;

-- 2. Index for fast filtering
CREATE INDEX IF NOT EXISTS idx_cities_tier ON cities(tier);

-- 3. tier1: capitals
UPDATE cities
SET tier = 'tier1'
WHERE is_capital = 1;

-- 4. tier2: top 3 by name in each state (alphabetical as a placeholder)
-- Uses ROW_NUMBER() partitioned by state_id
UPDATE cities
SET tier = 'tier2'
WHERE id IN (
  SELECT id FROM (
    SELECT
      id,
      ROW_NUMBER() OVER (PARTITION BY state_id ORDER BY name ASC) as rn
    FROM cities
    WHERE state_id IS NOT NULL
      AND tier IS NULL
  )
  WHERE rn <= 3
);

-- 5. tier3: everything else
UPDATE cities
SET tier = 'tier3'
WHERE tier IS NULL;
