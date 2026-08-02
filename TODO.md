# TODO

## Active

- **M11.1: Layer dr5hn + GeoNames (NOT replace)** — 2-3 day task
  - Build merge pipeline: dr5hn base + GeoNames augmentation
  - Add `source_id`, `release_id`, `source_population`, `source_timezone_confidence` to `cities`
  - For each GeoNames city: if dr5hn has it (name+state), keep dr5hn (richer data); else insert
  - Bulk update dr5hn's TZ + pop where GeoNames is more authoritative
  - Re-validate, re-test, re-stage
  - Then promote the layered result
  - **Why:** swapping alone loses 451K alt_names + 2.97M translations

## Future

- M11.2: Wikidata ingest (after GeoNames layer pattern works)
- M11.3: Unicode CLDR (territory-language, scripts, locale)
- M11.4: UN WPP 2024 (country pop)
- M11.5: US Census (US state/city pop, vintage tracking)
- M11.6: Eurostat (City vs FUA distinction for EU)
- M11.7: Census of India (IN city/village pop, 2011 official)
- M11.8: World Bank Indicators
- M11.9: India population projections (2011-2036)
- Time-calc endpoint (DST + date-line math)
- polygon-based confidence (E4 multi-TZ municipality)
- boundary_distance_km computation
- airport data import (cron 426125193814084, monthly 9 AM ET)

## Done (M0-M11.0)

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
- [x] M11.0: Data platform foundation
  - source_registry (10 sources, GeoNames first)
  - source_releases (versioned, SHA-256)
  - cities_staging (69,561 GeoNames rows, 0 NULL TZ, 0 NULL pop)
  - 5 new API endpoints
  - R2 raw artifact
  - 18 new tests (13 sources + 5 staging)
  - Promote script ready (NOT run, shadow mode)

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
