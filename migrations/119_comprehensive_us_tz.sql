-- Migration 119: Comprehensive US timezone fix
-- Migration 117: 37 truth-list cities (excluded from this migration)
-- Migration 119: 26 additional US cities
--   - State default for non-split states
--   - lat/lon rules for split states (FL, IN, KY, TN, MI, ND, SD, NE, KS, TX, ID, OR, NV, AZ, AK)
--
-- Idempotent: sets explicit value.

-- America/Adak (1 cities)
UPDATE cities SET timezone = 'America/Adak' WHERE id IN (111144);

-- America/Denver (15 cities)
UPDATE cities SET timezone = 'America/Denver' WHERE id IN (112002,113635,114454,115386,116523,116898,117452,119356,119402,120266,121573,123717,123958,125999,127866);

-- America/Metlakatla (10 cities)
UPDATE cities SET timezone = 'America/Metlakatla' WHERE id IN (114045,114756,118632,119338,119523,119524,124108,124110,129601,153919);

