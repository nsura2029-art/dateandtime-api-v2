-- Migration 117: Apply authoritative US timezone truth list
-- 42 test cases for split US timezone states.
-- This overwrites ANY previous value (including the broken migration 116).
-- Idempotent: sets the explicit value.

-- America/New_York (2 cities)
UPDATE cities SET timezone = 'America/New_York' WHERE id IN (121746, 119694);

-- America/Chicago (10 cities)
UPDATE cities SET timezone = 'America/Chicago' WHERE id IN (124045, 117106, 112628, 122577, 116396, 126462, 122479, 123463, 129215, 114990);

-- America/Detroit (1 cities)
UPDATE cities SET timezone = 'America/Detroit' WHERE id IN (115291);

-- America/Menominee (1 cities)
UPDATE cities SET timezone = 'America/Menominee' WHERE id IN (121662);

-- America/Indiana/Indianapolis (1 cities)
UPDATE cities SET timezone = 'America/Indiana/Indianapolis' WHERE id IN (118924);

-- America/Indiana/Knox (1 cities)
UPDATE cities SET timezone = 'America/Indiana/Knox' WHERE id IN (119682);

-- America/Indiana/Tell_City (1 cities)
UPDATE cities SET timezone = 'America/Indiana/Tell_City' WHERE id IN (127488);

-- America/Kentucky/Louisville (1 cities)
UPDATE cities SET timezone = 'America/Kentucky/Louisville' WHERE id IN (120813);

-- America/North_Dakota/Center (1 cities)
UPDATE cities SET timezone = 'America/North_Dakota/Center' WHERE id IN (113639);

-- America/North_Dakota/Beulah (1 cities)
UPDATE cities SET timezone = 'America/North_Dakota/Beulah' WHERE id IN (112296);

-- America/Denver (6 cities)
UPDATE cities SET timezone = 'America/Denver' WHERE id IN (124894, 126060, 117385, 115930, 129004, 129376);

-- America/Boise (2 cities)
UPDATE cities SET timezone = 'America/Boise' WHERE id IN (112508, 123487);

-- America/Los_Angeles (3 cities)
UPDATE cities SET timezone = 'America/Los_Angeles' WHERE id IN (114366, 124565, 120163);

-- America/Phoenix (1 cities)
UPDATE cities SET timezone = 'America/Phoenix' WHERE id IN (124148);

-- America/Anchorage (1 cities)
UPDATE cities SET timezone = 'America/Anchorage' WHERE id IN (111305);

-- America/Metlakatla (1 cities)
UPDATE cities SET timezone = 'America/Metlakatla' WHERE id IN (121735);

-- Pacific/Honolulu (1 cities)
UPDATE cities SET timezone = 'Pacific/Honolulu' WHERE id IN (118623);

-- America/Puerto_Rico (1 cities)
UPDATE cities SET timezone = 'America/Puerto_Rico' WHERE id IN (143202);

-- Pacific/Guam (1 cities)
UPDATE cities SET timezone = 'Pacific/Guam' WHERE id IN (160269);

