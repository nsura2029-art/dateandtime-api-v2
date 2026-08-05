# Cities Enrichment Audit — Milestone 3 Complete

**Date:** 2026-08-01
**Source:** dr5hn countries-states-cities-database v2025-12

## Coverage (152,970 cities)

| Field | Filled | Coverage |
|---|---:|---:|
| state_code | 152,970 | 100.0% |
| type (33 distinct values) | 151,070 | 98.8% |
| wiki_data_id | 148,331 | 97.0% |
| native (local script) | 150,906 | 98.7% |
| parent_id (hierarchy) | 2,721 | 1.8% |
| level (admin level) | 3,105 | 2.0% |
| flag = 1 (active) | 152,970 | 100.0% |

## Type Distribution (33 distinct values)

| Type | Count |
|---|---:|
| city                 |  99,162 |
| adm2                 |  17,801 |
| adm3                 |  15,759 |
| section              |   5,346 |
| adm4                 |   3,909 |
| adm1                 |   3,455 |
| district             |   2,381 |
| county               |   1,416 |
| regency              |     390 |
| prefecture           |     369 |
| locality             |     319 |
| capital              |     281 |
| municipality         |     209 |
| banner               |      52 |
| town                 |      48 |
| province             |      36 |
| adm5                 |      16 |
| parish               |      16 |
| abandoned            |      15 |
| area                 |      12 |
| cities               |      11 |
| village              |      10 |
| historical           |       9 |
| settlement           |       9 |
| oblast               |       8 |
| gov_seat             |       6 |
| special municipality |       6 |
| administrative zone  |       5 |
| region               |       4 |
| destroyed            |       3 |
| township             |       3 |
| religious            |       2 |
| historical_capital   |       1 |
| subdistrict          |       1 |

## User Example Verification

```json
{
  "id": 115731,
  "name": "East Pensacola Heights",
  "state_id": 1436,
  "state_code": "FL",
  "country_id": 233,
  "country_code": "US",
  "type": "city",
  "level": null,
  "parent_id": null,
  "latitude": 30.42881,
  "longitude": -87.17997,
  "native": "East Pensacola Heights",
  "population": 54104,
  "timezone": "America/Chicago",
  "wiki_data_id": "Q3459226",
  "flag": 1
}
```

✅ All fields match the user's expected shape.
- ✅ `timezone: "America/Chicago"` (correct, FL panhandle is Central)
- ✅ `wiki_data_id: "Q3459226"` matches dr5hn source
- ✅ `state_code: "FL"` matches dr5hn source

## Migrations Applied

1. **127_cities_enrichment** (4 parts): 152,970 cities × 7 fields (state_code, native, type, level, parent_id, wiki_data_id, flag)
2. **127b_wiki_data_id** (4 parts): camelCase `wikiDataId` → snake_case `wiki_data_id` fix
3. **127c_set_flag_default**: Set flag=1 for all cities (dr5hn flag is always null)

## Files Added

- `migrations/127_parts/127_cities_enrichment_pt[1-4].sql` (7.2 MB each)
- `migrations/127b_parts/127b_wiki_data_id_pt[1-4].sql` (1.2 MB each)
- `migrations/127c_set_flag_default.sql`
- `scripts/seed/cities_enrichment.py` (generator)
