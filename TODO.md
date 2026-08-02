# TODO

## Active

- **M11.0: Data platform foundation** (in progress on `feature/data-platform-geonames`)
  - source_registry table (10 sources, GeoNames first)
  - source_releases table (versioned)
  - R2 bucket setup (raw, normalized, reports)
  - Two-phase commit pipeline (cities_staging → cities_live)
  - /api/v1/sources endpoints
  - GeoNames Cities5000 raw → R2 → D1
  - Reconciliation report
  - Estimated: 1-2 days

## Future

- M11.1: Wikidata ingest (after GeoNames validates the pattern)
- M11.2: Unicode CLDR (territory-language, scripts, locale)
- M11.3: UN WPP 2024 (country pop)
- M11.4: US Census (US state/city pop, vintage tracking)
- M11.5: Eurostat (City vs FUA distinction for EU)
- M11.6: Census of India (IN city/village pop, 2011 official)
- M11.7: World Bank Indicators
- M11.8: India population projections (2011-2036)
- Time-calc endpoint (DST + date-line math)
- polygon-based confidence (E4 multi-TZ municipality)
- boundary_distance_km computation
- airport data import (cron 426125193814084, monthly 9 AM ET)

## Done (M0-M10+)

- [x] M0: Repo scaffold (Hono + D1 + Zod)
- [x] M1: Global timezone polygon (3,018 cities verified)
- [x] M2: Schema enrichment (7 cols, 4 tables)
- [x] M3: Cities enrichment (population, alt_names, place_names)
- [x] M4: Postcodes (844,248 rows)
- [x] M5: Translations (2,965,561 rows, 19 langs)
- [x] M6: API contract upgrade (state filter, lang search, ranking)
- [x] M7: New endpoints (postcodes, airports)
- [x] M8: Data quality metadata
- [x] M9: Documentation (3 spec docs + Swagger)
- [x] M10: Final regression (76 tests, 14 groups)
- [x] M10+: Edge cases (46 tests E1-E14) + suggestions (14 tests S1-S5)
- [x] Doc framework: STATUS.md, CHANGELOG.md, sync-status.sh, pre-merge-to-develop.sh
