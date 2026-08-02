# M4: Postcodes Audit Report

**Date:** 2026-08-01
**Source:** dr5hn countries-states-cities-database postcodes.json
**Migration:** 128 (nearest_city_id col) + 129 (20-part import) + 129a (index cleanup)

## Counts

| Metric | Value |
|---|---:|
| Total postcodes | **844,248** |
| Expected | 844,248 |
| Match | ✅ 100% |
| With lat/lon | 104,442 (12.4%) |
| With locality_name | 803,429 (95.2%) |
| With wiki_data_id | 0 (0.0%) |
| With nearest_city_id (polygon-populated) | 0 (deferred to M4.5) |
| NULL state_id | 40,793 |
| NULL country_id | 0 |

## Data Integrity

| Check | Result |
|---|---|
| FK state_id → administrative_regions | ✅ 0 broken |
| FK country_id → countries | ✅ 0 broken |
| Schema columns | ✅ All dr5hn fields + nearest_city_id |

## Top 10 Countries by Postcode Count

| Code | Country | Count |
|---|---|---:|
| PT | Portugal | 197,024 |
| MX | Mexico | 144,600 |
| JP | Japan | 120,677 |
| US | United States | 33,791 |
| MT | Malta | 26,593 |
| AR | Argentina | 23,184 |
| CN | China | 22,656 |
| PL | Poland | 22,090 |
| IN | India | 19,100 |
| AT | Austria | 18,722 |

## Type Coverage (dr5hn `type` field)

| Type | Count |
|---|---:|
| full                 |  833,583 |
| area                 |    4,445 |
| po_box               |    3,576 |
| fsa                  |    1,645 |
| street               |      999 |

## Indexes

- idx_postcodes_code
- idx_postcodes_country
- idx_postcodes_state
- idx_postcodes_nearest_city

## API Verification

City detail endpoint now includes:

```json
{
  "postcodes": {
    "total": 1013,        // state-scoped count
    "sample": [            // first 5 with code, locality, type, lat/lon
      {"code": "32003", "localityName": null, "type": "full", "latitude": 30.095584, "longitude": -81.710162},
      ...
    ]
  }
}
```

## Tests

- tests/postcodes.test.ts: 9 tests pass
- M1 fixtures: still pass (no regression)
- M3 enrichment: now returned in /cities/:id + /cities/search

## Spec Coverage (post-M4)

| Spec section | Status | Test count |
|---|---|---:|
| §17.5 postcodes present in city detail | ✅ Pass | 1 |
| §16.3 small island via postcode | 🟡 Partial (M7 endpoint pending) | 0 (manual) |
| §33.7 postcodes acceptance | ✅ Pass | 1 |
| §23.5 migration idempotency | ✅ Pass (INSERT OR IGNORE) | 1 |

**New tests passing: 9**
**Total tests now: 120 (was 111)**
**Cumulative pass rate: 102/209 spec tests (48.8%)**

## Performance Notes

- Import time: 20 wrangler calls × ~30s = ~10 minutes total
- Per-file size: 4.7 MB each (under 10MB D1 limit)
- Batch size: 100 rows per INSERT (under 100-var limit)
- Index strategy: nearest_city_id (deferred), state+country (workhorse)
