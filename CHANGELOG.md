# CHANGELOG

Per-PR notes. Newest first. Update on every merge to develop.

---

## [unreleased] — feature/data-platform-geonames (M11.0)

**Date:** 2026-08-02
**Status:** Shadow mode — GeoNames validated, NOT promoted

### What shipped

- Migration 139: `source_registry` (10 sources, 1 active), `source_releases` (versioned), `cities_staging` (two-phase commit target)
- 5 new API endpoints:
  - `GET /api/v1/sources` (list 10 sources)
  - `GET /api/v1/sources/:key` (single source + recent releases)
  - `GET /api/v1/sources/:key/releases` (release history with ?status= filter)
  - `GET /api/v1/staging/summary` (per-release counts)
  - `GET /api/v1/staging/cities` (top-N by pop, with ?release_id, ?country)
- 4 ingestion scripts:
  - `geonames_cities5000.py` (download/verify/upload/register)
  - `geonames_to_staging.py` (parse to local SQLite)
  - `reconcile_geonames.py` (raw vs local vs D1 vs live)
  - `publish_geonames.sh` (two-phase commit, asks for explicit `yes`)
- 18 new tests, 18/18 pass
- R2 raw artifact: 5.6MB + manifest at `r2://dt-data-raw/raw/geonames/cities5000/2026-08-02/`
- D1 cities_staging: 69,561 rows, 0 NULL TZ, 0 NULL pop, 100% reconciliation match

### Decision: shadow mode (NOT promoted)

- dr5hn (152,970 cities, 451K alt_names, 2.97M translations) remains live
- GeoNames (69,561 cities, better TZ+pop quality) is in `cities_staging`, queryable via `/api/v1/staging/*`
- Promote script ready but not run
- M11.1 next: layer the two sources instead of replacing

See `reports/m11.0-shadow-mode-decision.md` for full analysis.

---

## [released] — develop @ a737959 (merge: M0-M10+)

**Date:** 2026-08-02
**Commits:** 32 (M0-M10+)
**Notes:** M0-M10+ complete. 152,970 cities, 462 IANA timezones, 19-language
translations, 844K postcodes, 8 data sources. 310/311 tests pass.

### What changed

- M0: Hono + D1 + Zod scaffold, Vitest, Wrangler
- M1: Global timezone polygon truth (3,018 cities verified, M1 migration 123)
- M2: Schema enrichment (7 cols, 4 tables, migration 126)
- M3: Cities enrichment (population, alt_names, place_names, migrations 127*)
- M4: Postcodes (844,248 rows imported via migrations 128-129a)
- M5: Translations (2,965,561 rows across 19 langs, migrations 130-131)
- M6: API contract upgrade — state filter, lang search, ranking, migration 132
- M7: New endpoints (postcodes, airports), routes added
- M8: Data quality metadata (migrations 133-138, 5 new cities cols)
- M9: Documentation (timezone-core-logic, data-audit, test-plan, swagger)
- M10: Final regression (76 tests F1-F14, postman collection)
- M10+: Edge cases (46 tests E1-E14) + suggestions (14 tests S1-S5)

### Endpoints added

- `GET /api/v1/cities/:id/postcodes` — city postcodes (paginated)
- `GET /api/v1/postcodes/search` — postcode lookup
- `GET /api/v1/airports/near` — airports by lat/lon
- `GET /api/v1/cities/:id/airports` — city's airports
- `GET /api/v1/cities/:id/translations` — city's translations (all 19)
- `GET /api/v1/cities/:id/translations/:lang` — single language
- `GET /api/v1/translations/search` — translation lookup
- `GET /api/v1/data-quality` — summary
- `GET /api/v1/data-quality/issues` — filtered issues
- `GET /api/v1/health` — liveness (existing)
- `GET /api/v1/status` — binding info (existing)

### Behaviour changes

- `/api/v1/cities/search` now returns `data.suggestions` when `total=0`
- `/api/v1/cities/search` accepts `?lang=` for cross-language search
- `/api/v1/cities/search` accepts `?state=` for state-boosted ranking
- Population-based same-name same-country disambiguation

### Test count

296 → 310 (+14 from suggestions)

### Breaking changes

None — all changes are additive

### Known issues

- env.test.ts still fails (pre-existing, unrelated)
- 22 Null Island cities flagged unresolved
- 35,546 cities have NULL population (97.3% flagged)
- Vinjanampadu and other sub-15K villages are below dataset threshold

### Next PR

Trigram same-country preference (5 min)

---

## [released] — develop @ f364dbd

**Date:** 2026-08-01
**Commits:** 3 (Phase 2 search + multilingual support)
**Notes:** GeoNames alt names, multilingual place_names, Phase 2 search
