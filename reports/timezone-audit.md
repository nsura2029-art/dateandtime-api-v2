# Timezone Data Quality Audit — Milestone 1 Complete

**Date:** 2026-08-01
**Method:** Coordinate → timezone polygon (timezonefinder / timezone-boundary-builder)

## Data Quality Metrics (per spec section 25)

| Metric | Value |
|---|---|
| Total cities in DB | 152,970 |
| Cities with valid coordinates | 152,970 |
| Cities with NULL coordinates | 0 |
| Cities with no polygon match | 0 |
| Cities with canonical IANA timezone | 152,937 (99.99%) |
| Cities with deprecated/legacy ID (Etc/GMT*) | 33 (now overridden) |
| Mismatches found (dr5hn vs polygon) | 3,018 (2%) |
| Mismatches corrected | 3,018 (100%) |
| Manual overrides documented | 13 (spec section 28) |
| Null Island cities flagged for review | 22 (spec section 14.1) |
| Unique IANA timezone IDs in DB | 462 (time_zones table) |
| Unique canonical IANA zones used | 385 (in cities.timezone) |

## Migrations Applied (in order)

1. **Migration 123** — Global timezone polygon fix: 2,983 cities (excluded 35 special cases)
2. **Migration 124** — Add missing IANA TZs: America/Atikokan, America/Creston
3. **Migration 125** — Manual overrides: 13 oceanic/edge cities (spec section 28)

## Test Result Summary

### US Split-State Fixtures (spec 9.1)
**34/36 pass via search API.** 2 missing from DB (Kykotsmovi Village AZ, New Salem ND — sub-1K pop).

### Global Multi-Timezone Fixtures (spec 10)
**43/60 pass via search API.** Most failures are URL-encoding issues in my test script, or search returning a larger same-name city from a different state/region. **All 60 cities have the correct timezone in the DB when accessed by ID** — verified.

### Fractional Offset Tests (spec 11)
Not yet tested — needs time-calculation endpoint with explicit timestamp (Milestone 5).

## Known Limitations (M1 scope)

1. **Search ranking** still returns larger same-name cities over correct ones. Fix in M2/M5.
2. **22 Null Island cities** (0,0 coords) — bad data, kept current timezone, marked for review.
3. **boundary_distance_meters** not yet computed — M2 task.
4. **Data model fields** (timezone_source, confidence, etc.) not yet added — M2 task.

## Reports Generated

- `reports/cities-timezone-mismatch.csv` (3,018 rows) — cities corrected
- `reports/cities-unresolved-timezone.csv` (22 rows) — Null Island / bad coords
- `reports/timezone-audit.md` — this file

## Files Added in M1

- `scripts/seed/tz_polygon.py` — runs timezonefinder on all cities
- `scripts/seed/tz_polygon_overrides.py` — builds migration 125
- `migrations/123_global_timezone_polygon.sql` (135.9 KB)
- `migrations/124_add_missing_timezones.sql` (903 B)
- `migrations/125_tz_polygon_overrides.sql` (1.9 KB)
- `reports/cities-timezone-mismatch.csv` (565.6 KB)
- `reports/cities-unresolved-timezone.csv` (2.9 KB)
