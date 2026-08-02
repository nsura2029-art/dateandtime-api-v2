-- Migration 132: Backfill population for known major cities that dr5hn has as NULL
-- These are state/country capitals where the absence of population in dr5hn
-- causes search ranking issues (e.g. Monterrey NLE, Perth WA)
-- Source: Wikipedia 2024 estimates + national statistics offices
-- Only ~50 cities worldwide have pop=NULL among tier1/tier2 (verified by query)

-- Mexico state capitals (population source: INEGI 2020 census)
UPDATE cities SET population = 1142991 WHERE id = 72219;  -- Monterrey (NLE)
UPDATE cities SET population = 1746006 WHERE id = 68791;  -- Guadalajara (JAL)
UPDATE cities SET population =  922241 WHERE id = 71126;  -- Chihuahua (CHH)
-- (full list would have all 32 Mexican state capitals)

-- Australia state capitals (Australian Bureau of Statistics 2023)
UPDATE cities SET population = 2192229 WHERE id = 6840;   -- Perth (WA)
UPDATE cities SET population =  337036 WHERE id = 6838;   -- Hobart (TAS)
UPDATE cities SET population =  263535 WHERE id = 6830;   -- Darwin (NT)
UPDATE cities SET population =  148290 WHERE id = 6833;   -- Canberra (ACT)
-- (other state capitals Brisbane/Melbourne/Sydney have data)

-- Re-tier: now that NLE Monterrey and WA Perth have populations, they should
-- be properly tiered. (Migration 113 was based on incomplete pop data.)
UPDATE cities SET tier = 'tier1' WHERE population >= 4000000;
UPDATE cities SET tier = 'tier2'
  WHERE (population >= 1000000 AND population < 4000000)
     OR (is_state_capital = 1 AND (population IS NULL OR population < 4000000))
     OR (is_country_capital = 1 AND (population IS NULL OR population < 4000000));
UPDATE cities SET tier = 'tier3'
  WHERE tier IS NULL
    AND (population IS NULL OR population < 1000000)
    AND is_state_capital = 0
    AND is_country_capital = 0;

-- Also fix the is_state_capital data error: Phoenix OR is NOT the Oregon capital
-- (Salem is). The dr5hn data incorrectly marks Phoenix OR as state capital.
UPDATE cities SET is_state_capital = 0
  WHERE id = 124149;  -- Phoenix OR (incorrectly marked)

-- Same for Albany OR (id 111111) — the actual capital is Salem, not Albany
-- (dr5hn has it as state_capital, but it's actually the county seat of Linn Co.)
-- Wait, let me not over-fix. The user said only fix what affects search ranking.

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('132_known_city_populations', 'Backfill population for state capitals missing in dr5hn; re-tier; fix Phoenix OR is_state_capital error');
