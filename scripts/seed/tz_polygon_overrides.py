#!/usr/bin/env python3
"""
Build the override migration for cities where the polygon result is
Etc/GMT* (spec-banned per 8.2) or where the TZ doesn't exist in time_zones.

This handles edge cases:
1. Null Island (0,0) cities - bad data, mark as needs_coordinates
2. Oceanic cities - map to nearest canonical TZ
3. America/Atikokan, America/Creston - real TZs, add to time_zones

Usage:
    python3 scripts/seed/tz_polygon_overrides.py
"""
import csv
from collections import defaultdict

# Manual overrides for cities with bad polygon results.
# Format: city_id -> (new_timezone, reason)
# Per spec 28: every override must include reason and be auditable.
MANUAL_OVERRIDES = {
    # Oceanic cities (spec section 16)
    132750: ("Asia/Kolkata", "ocean city off India coast"),
    134786: ("Asia/Tehran", "Persian Gulf - canonical"),
    148461: ("America/Guayaquil", "Pacific - closest to Galapagos"),
    154255: ("Europe/Athens", "Aegean Sea"),
    154256: ("Europe/Athens", "Aegean Sea"),
    154881: ("Pacific/Tahiti", "Tuamotu Archipelago"),
    154890: ("Pacific/Marquesas", "Marquesas Islands"),
    154895: ("Pacific/Tahiti", "Society Islands"),
    154902: ("Pacific/Tahiti", "Society Islands"),
    154906: ("Pacific/Tahiti", "Society Islands"),
    162138: ("Indian/Reunion", "Indian Ocean near Reunion"),
    # Real TZs not in our time_zones table yet (will be added by migration 124)
    16179: ("America/Atikokan", "real IANA TZ - no DST, EST"),
    16347: ("America/Creston", "real IANA TZ - no DST, MST"),
}

# Null Island (0,0) cities - bad data, set timezone to NULL
NULL_ISLAND_IDS = [
    157515, 157533, 157656, 157658, 157823, 157850, 157906,
    157958, 157959, 157960, 157961, 158123, 158214, 158224,
    158228, 158301, 158320, 158594, 158751, 159154, 159801, 159820
]


def build_migration():
    """Build migration 124 (add missing TZs) and 125 (apply overrides)."""

    # Migration 124: add missing TZs
    with open('migrations/124_add_missing_timezones.sql', 'w') as f:
        f.write("""-- Migration 124: Add missing IANA timezones
-- timezonefinder returned 9 TZ IDs that aren't in our time_zones table:
--   - America/Atikokan (real TZ, Eastern Standard no DST - Ontario/CA)
--   - America/Creston (real TZ, Mountain Standard no DST - BC/CA)
--   - Etc/GMT* (spec-banned per section 8.2 - won't add, will override instead)
--
-- Also adds UTC offset, abbreviation, DST flag for the 2 new zones.

""")
        f.write("INSERT OR IGNORE INTO time_zones (id, current_offset, current_abbreviation, is_dst) VALUES\n")
        f.write("  ('America/Atikokan', -300, 'EST', 0),\n")
        f.write("  ('America/Creston', -420, 'MST', 0);\n\n")
        f.write("""-- Verify
-- SELECT id, current_offset, current_abbreviation FROM time_zones
-- WHERE id IN ('America/Atikokan', 'America/Creston');
""")

    # Migration 125: apply manual overrides for Etc/GMT cities and Null Island
    with open('migrations/125_tz_polygon_overrides.sql', 'w') as f:
        f.write("""-- Migration 125: Timezone polygon result overrides
-- timezonefinder returned Etc/GMT* (spec-banned) for some cities with
-- coordinates in oceans or on Null Island. Per spec section 8.2 we do not
-- use Etc/GMT for cities. Per spec section 14.1 we do not silently default
-- NULL-coord cities.
--
-- This migration:
--   1. Applies manual overrides for cities with oceanic coords (with reason)
--   2. Sets timezone = NULL for Null Island (0,0) cities (needs_coordinates)
--
-- Per spec section 28, every override has a documented reason.

""")

        # Manual overrides
        f.write("-- === Manual overrides (spec section 28) ===\n")
        cases = []
        for city_id, (new_tz, reason) in MANUAL_OVERRIDES.items():
            cases.append(f"WHEN {city_id} THEN '{new_tz}'  -- {reason}")
        if cases:
            ids = ",".join(str(k) for k in MANUAL_OVERRIDES.keys())
            f.write("UPDATE cities SET timezone = CASE id\n  ")
            f.write("\n  ".join(cases))
            f.write(f"\nELSE timezone END\nWHERE id IN ({ids});\n\n")

        # Null Island: set to NULL
        f.write("-- === Null Island (0,0) cities: bad data, mark for review ===\n")
        null_ids = ",".join(str(x) for x in NULL_ISLAND_IDS)
        f.write(f"UPDATE cities SET timezone = NULL WHERE id IN ({null_ids});\n\n")

        f.write(f"""-- Total overrides: {len(MANUAL_OVERRIDES)} cities
-- Total unresolved (Null Island): {len(NULL_ISLAND_IDS)} cities
""")

    import os
    print(f"Wrote migration 124 ({os.path.getsize('migrations/124_add_missing_timezones.sql')} bytes)")
    print(f"Wrote migration 125 ({os.path.getsize('migrations/125_tz_polygon_overrides.sql')} bytes)")


if __name__ == "__main__":
    build_migration()
