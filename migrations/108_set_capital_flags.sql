-- Migration 108: Set capital flags on cities
-- Updates:
--   is_country_capital = 1  when cities.name matches countries.capital
--   is_state_capital   = 1  when cities.name matches administrative_regions.name
--   is_capital         = OR of both
--   capital_type       = 'country_capital' | 'state_capital' | 'both' | NULL

-- 1. Set is_country_capital where city name matches country capital
UPDATE cities
SET is_country_capital = 1
WHERE id IN (
  SELECT ci.id
  FROM cities ci
  JOIN countries co ON co.id = ci.country_id
  WHERE co.capital IS NOT NULL
    AND LOWER(ci.name) = LOWER(co.capital)
);

-- 2. Set is_state_capital where city name matches state name
UPDATE cities
SET is_state_capital = 1
WHERE id IN (
  SELECT ci.id
  FROM cities ci
  JOIN administrative_regions ar ON ar.id = ci.state_id
  WHERE LOWER(ci.name) = LOWER(ar.name)
);

-- 3. Set is_capital = OR of both
UPDATE cities
SET is_capital = CASE
  WHEN is_country_capital = 1 OR is_state_capital = 1 THEN 1
  ELSE 0
END;

-- 4. Set capital_type based on flags
UPDATE cities
SET capital_type = CASE
  WHEN is_country_capital = 1 AND is_state_capital = 1 THEN 'both'
  WHEN is_country_capital = 1 THEN 'country_capital'
  WHEN is_state_capital = 1 THEN 'state_capital'
  ELSE NULL
END
WHERE is_capital = 1;
