# M8: Data Quality Metadata Audit

**Date:** 2026-08-02

## Schema additions (migration 133)

| Column | Purpose |
|---|---|
| timezone_confidence | 'high' / 'medium' / 'low' / 'unresolved' |
| timezone_source | Where the TZ came from (polygon, dr5hn, manual, etc.) |
| boundary_distance_km | Distance to nearest TZ boundary line (deferred) |
| near_boundary | 1 if boundary_distance < 1 km |
| data_quality_flags | 'null_island', 'no_pop', 'no_wiki', etc. |

## Confidence distribution (all 152,970 cities)

| Confidence | Count | Source |
|---|---:|---|
| high | 2,983 | M1 polygon-verified (timezonefinder) |
| medium | 149,952 | dr5hn:default |
| low | 13 | M1 manual override (spec §28) |
| unresolved | 22 | Null Island (0,0 coords) |
| **Total** | **152,970** | |

## Data quality flags

| Flag | Count |
|---|---:|
| no_pop | 31,665 |
| no_pop,no_wiki | 2,891 |
| no_wiki | 759 |
| null_island,no_pop,no_wiki | 20 |
| null_island,no_pop | 1 |
| null_island,no_wiki | 1 |

## Data sources (migration 138)

8 sources registered: dr5hn, GeoNames, IANA tz, UN M49, Nager.Date, Wikipedia/Wikidata, timezonefinder, US Census

## New API endpoints

| Endpoint | Purpose |
|---|---|
| GET /api/v1/data-quality | Confidence counts, sources, migrations |
| GET /api/v1/data-quality/issues?type= | List cities with quality issues (filterable) |
| /cities/{id} now returns dataQuality | timezoneConfidence, timezoneSource, flags[] |

## Migrations added (M8)

- 133: data quality columns
- 134 (20 parts): populate timezone_confidence + source for 152,970 cities
- 135: fix 970 NULL confidence (rounding bug)
- 136: mark 22 Null Island as unresolved
- 137: mark 13 manual overrides as low
- 138: populate data_sources with 8 actual sources

## Test results

15/15 pass:
- M8.1: confidence counts
- M8.2: 8 data sources listed
- M8.3: migrations listed
- M8.4: deprecated Etc/GMT count is 0 (spec §8.2)
- M8.5-9: issues filter (null_island=22, manual_override=13, low_confidence=35, etc_gmt=0)
- M8.10-13: city detail dataQuality (Tokyo medium, Atikokan low, Alderetes high, Null Island unresolved)
- M8.14-15: distribution stats

**Total test count: 174/175 pass** (1 pre-existing env.test.ts)

## Spec coverage progress

| Section | Before M8 | After M8 | New passing |
|---|---:|---:|---:|
| §14.3 Null Island flag | 0 | 1 | +1 (22 cities) |
| §25 Data quality audit | 0 | 3 | +3 |
| §28 Manual override audit | 0 | 2 | +2 |
| §33.5 Quality endpoint | 0 | 1 | +1 |
| §33.17-18 Acceptance | 0 | 2 | +2 |

**Cumulative: 151/209 spec tests (72.2%)**

## Deferred

- boundary_distance_km: requires polygon-based distance computation. 
  Would need to test all 152K cities against the nearest boundary line.
  Heavy compute (~1 hour), but useful for §15 boundary cases.
  Will revisit in M10.
