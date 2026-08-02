# TODO

## Active

- **M11.2: Wikidata ingest** — 1-2 day task
  - Source already in source_registry
  - Brings: alt names, Wikipedia URLs, populations, official languages
  - Re-uses M11.0 ingestion scripts pattern (download → R2 → staging → reconcile)
  - Then layer merge (M11.2.5) for new alt names

- **Load GeoNames `alternateNames`** to enable historical_alias matches — 1 day
  - Current: 1,310 historical_alias merges caught (dr5hn's place_names only)
  - Goal: also catch Mumbai↔Bombay, Edo↔Tokyo, Peking↔Beijing via GeoNames's own alt names
  - File: GeoNames alternateNamesV2.zip (40M+ rows)

## Future

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
- Update /cities/search to use `search_name` field (FTS5 still works, this is cosmetic)
- airport data import (cron 426125193814084, monthly 9 AM ET)
- "World time" feature (per user brainstorm)
- Long weekend finder (per user brainstorm)

## Done (M0-M11.1)

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
- [x] M11.1: Layer merge (dr5hn + GeoNames) — APPLIED
  - 11 new cities columns + city_layer_log audit table
  - intelligent_merge.py: 3-tier (exact 1km, fuzzy 10km, historical_alias)
  - 69,563 statements applied in 348 chunks (~12 min)
  - 170,253 cities total (dr5hn 152,970 + GeoNames-only 17,283)
  - 67,999 cities carry the M11.1 layer fields
  - 15 new tests, all pass
  - Reports: m11.1-layer-design.md, m11.1-layer-result.md

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
