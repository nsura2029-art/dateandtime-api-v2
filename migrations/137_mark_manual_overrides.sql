-- Migration 137: Mark 13 M1 manual overrides as 'low' confidence
-- Per spec §28, every manual override has a documented reason.

UPDATE cities
SET timezone_confidence = 'low',
    timezone_source = 'manual:override'
WHERE id IN (
  16179,  -- Atikokan ON, EST no DST
  16347,  -- Creston BC, MST no DST
  132750, -- oceanic city off India coast
  134786, -- Persian Gulf, canonical
  148461, -- Pacific, closest to Galapagos
  154255, -- Aegean Sea
  154256, -- Aegean Sea
  154881, -- Tuamotu Archipelago
  154890, -- Marquesas Islands
  154895, -- Society Islands
  154902, -- Society Islands
  154906, -- Society Islands
  162138  -- Indian Ocean near Reunion
);

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('137_mark_manual_overrides', 'Mark 13 M1 manual overrides as timezone_confidence=low (spec §28)');
