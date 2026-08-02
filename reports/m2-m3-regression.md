# M2 + M3 Regression Report

**Date:** 2026-08-01
**Source:** dr5hn countries-states-cities-database + timezone polygon (M1)

## Test Results

| Section | Test | Result |
|---|---|---|
| M2 | 7 new cities columns | ✅ PASS (all 7 exist) |
| M2 | 4 new tables (postcodes, translations, airports, migrations) | ✅ PASS (all 4 exist) |
| M3 | total = 152,970 cities | ✅ PASS |
| M3 | state_code 100% coverage | ✅ PASS (152,970) |
| M3 | type 98.7% coverage | ✅ PASS (151,070) |
| M3 | type 34 distinct values | ✅ PASS (≥ 33) |
| M3 | wiki_data_id 96.9% coverage | ✅ PASS (148,331) |
| M3 | native 98.6% coverage | ✅ PASS (150,906) |
| M3 | flag=1 for all cities | ✅ PASS (152,970 active, 0 deprecated) |
| M3 | User example East Pensacola Heights (id 115731) | ✅ PASS (matches dr5hn exactly) |
| M1 | Pensacola FL → America/Chicago | ✅ PASS (preserved) |
| M1 | Phoenix AZ → America/Phoenix | ✅ PASS (preserved) |
| M1 | Miami FL → America/New_York | ✅ PASS (preserved) |
| M2 | No parent_id orphans | ✅ PASS (0 orphans) |
| M2 | migrations table populated | ✅ PASS (3 versions) |

**All 15 tests pass.**

## Schema State

### cities columns added (7)
- state_code, native, type, level, parent_id, wiki_data_id, flag

### Tables added (4)
- postcodes, translations, airports, migrations

## User Example (id 115731)

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

✅ All fields match the user's expected output.

## Type Distribution (34 distinct)

| Type | Count |
|---|---:|
| city                      |  99,162 |
| adm2                      |  17,801 |
| adm3                      |  15,759 |
| section                   |   5,346 |
| adm4                      |   3,909 |
| adm1                      |   3,455 |
| district                  |   2,381 |
| county                    |   1,416 |
| regency                   |     390 |
| prefecture                |     369 |
| locality                  |     319 |
| capital                   |     281 |
| municipality              |     209 |
| banner                    |      52 |
| town                      |      48 |
| province                  |      36 |
| adm5                      |      16 |
| parish                    |      16 |
| abandoned                 |      15 |
| area                      |      12 |
| cities                    |      11 |
| village                   |      10 |
| historical                |       9 |
| settlement                |       9 |
| oblast                    |       8 |
| gov_seat                  |       6 |
| special municipality      |       6 |
| administrative zone       |       5 |
| region                    |       4 |
| destroyed                 |       3 |
| township                  |       3 |
| religious                 |       2 |
| historical_capital        |       1 |
| subdistrict               |       1 |

| **Total** | **151,070** |

(Note: 1,900 cities have NULL type, per dr5hn source)

## Migrations Recorded

- 126_schema_enrichment
- 127_cities_enrichment
- 127b_wiki_data_id
