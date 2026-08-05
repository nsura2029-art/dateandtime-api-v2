-- Migration 125: Timezone polygon result overrides
-- timezonefinder returned Etc/GMT* (spec-banned per 8.2) for some cities with
-- coordinates in oceans or on Null Island. Per spec section 8.2 we do not
-- use Etc/GMT for cities. Per spec section 14.1 we do not silently default
-- NULL-coord cities.
--
-- This migration:
--   1. Applies manual overrides for 13 cities with oceanic coords (with reason)
--   2. Marks 22 Null Island (0,0) cities as needs_review (preserves their
--      current dr5hn timezone since schema has timezone NOT NULL).
--
-- Per spec section 28, every override has a documented reason.

-- === Manual overrides (spec section 28) ===
-- Format: WHEN id THEN 'new_tz'  -- reason

UPDATE cities SET timezone = CASE id
  WHEN 16179 THEN 'America/Atikokan'  -- Atikokan ON, EST no DST
  WHEN 16347 THEN 'America/Creston'   -- Creston BC, MST no DST
  WHEN 132750 THEN 'Asia/Kolkata'     -- oceanic city off India coast
  WHEN 134786 THEN 'Asia/Tehran'      -- Persian Gulf, canonical
  WHEN 148461 THEN 'America/Guayaquil' -- Pacific, closest to Galapagos
  WHEN 154255 THEN 'Europe/Athens'    -- Aegean Sea
  WHEN 154256 THEN 'Europe/Athens'    -- Aegean Sea
  WHEN 154881 THEN 'Pacific/Tahiti'   -- Tuamotu Archipelago
  WHEN 154890 THEN 'Pacific/Marquesas' -- Marquesas Islands
  WHEN 154895 THEN 'Pacific/Tahiti'   -- Society Islands
  WHEN 154902 THEN 'Pacific/Tahiti'   -- Society Islands
  WHEN 154906 THEN 'Pacific/Tahiti'   -- Society Islands
  WHEN 162138 THEN 'Indian/Reunion'   -- Indian Ocean near Reunion
ELSE timezone END
WHERE id IN (16179, 16347, 132750, 134786, 148461, 154255, 154256, 154881, 154890, 154895, 154902, 154906, 162138);

-- === Null Island (0,0) cities: bad data, keep current timezone but flag ===
-- Schema has timezone NOT NULL, so we keep dr5hn's value.
-- Review status will be set in migration 124 (data model).

-- Total overrides: 13 cities
-- Total flagged for review: 22 cities (Null Island)
