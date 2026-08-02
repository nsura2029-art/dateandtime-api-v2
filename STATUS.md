# STATUS

**If you only read one file in this repo, read this one.**

Last updated: 2026-08-02 09:45 UTC (auto-refreshed by scripts/sync-status.sh)

## TL;DR

`dateandtime-api-v2` — Hono + Cloudflare D1 + Zod timezone/cities API. MVP + data platform foundation complete. 170,253 cities (dr5hn 152,970 + GeoNames 17,283 new), 250 countries, 462 IANA timezones, 19-language translations, 844K postcodes. Live at `https://dt-api-v2-dev.nsura2029.workers.dev`. **Not deployed to production.**

## Current branch state

| Branch | Purpose | Status |
|---|---|---|
| `main` | Production (empty) | dormant |
| `develop` | Integration | up to date with M0-M10+ |
| `feature/data-platform-geonames` | M11.0/M11.1 work | **8+ commits, ready to merge to develop** |
| `feature/global-timezone-polygon` | M0-M10+ work (now in develop) | stale (merged) |

## Last 5 commits

```
HEAD: M11.1 layer merge applied — 11 new city fields, 170K cities
HEAD~1: M11.0 data platform foundation — 5 endpoints, source registry
HEAD~2: docs: M11.1 layer design + reconciliation report
HEAD~3: M11.0 reconcile GeoNames — 100% match, validated
HEAD~4: M11.0 R2 upload — 5.6MB GeoNames cities5000 zip
```

## Test status

**343 / 344 pass** (1 pre-existing `tests/env.test.ts` failure, unrelated to recent work)

| Test file | Tests | Covers |
|---|---:|---|
| `tests/timezone-fixtures.test.ts` | 84 | M1 polygon truth |
| `tests/data-quality.test.ts` | 15 | M8 metadata |
| `tests/edge-cases.test.ts` | 46 | M10+ E1-E14 |
| `tests/final-regression.test.ts` | 76 | M10 F1-F14 |
| `tests/sources.test.ts` | 13 | M11.0 source registry |
| `tests/cities-staging.test.ts` | 5 | M11.0 staging |
| `tests/m11.1-layer.test.ts` | 15 | M11.1 layer fields |
| `tests/suggestions.test.ts` | 14 | M10+ did-you-mean |
| `tests/endpoints.test.ts` | 14 | M7 |
| `tests/search-ranking.test.ts` | 14 | M6 |
| `tests/translations.test.ts` | 11 | M5 |
| `tests/postcodes.test.ts` | 9 | M4 |
| `tests/enrichment.test.ts` | 3 | M2/M3 |
| `tests/health.test.ts` + `tests/status.test.ts` + `tests/env.test.ts` | (pre-existing) | 30 (1 failing) |

## Next 3 things (priority order)

1. **Merge `feature/data-platform-geonames` → `develop`** (15 min)
   - Run `bash scripts/sync-status.sh` to refresh this file
   - Open PR, run CI, merge
   - After merge: `develop` is the new "live" branch

2. **M11.2: Wikidata ingestion** (1-2 days)
   - Additional alt names, Wikipedia URLs, official languages
   - Source already registered in source_registry

3. **M11.3: Unicode CLDR** (1 day)
   - Territory-language official-status mapping
   - Source already registered in source_registry

## Future (deferred)

| Item | Estimate | Why deferred |
|---|---:|---|
| Time-calc endpoint (DST + date-line math) | 1-2 days | Separate scope |
| polygon-based confidence (E4 multi-TZ municipality) | 1 week | Needs polygon data per city |
| Load GeoNames `alternateNames` for historical_alias | 1 day | Would unlock Mumbai↔Bombay, Edo↔Tokyo merges |
| Update /cities/search to use `search_name` field | 2 hours | FTS5 already works; cosmetic |
| "World time" feature (per user brainstorm) | TBD | Per product PRD |
| Production deployment | when ready | User said "not ready for production" |
| UN WPP, US Census, Eurostat, Census of India | TBD | Sources registered, not yet ingested |

## Known issues

- **BUG-1 (open)**: Swagger UI CORS via `wrangler dev --remote` proxy. Workaround: open `https://dt-api-v2-dev.nsura2029.workers.dev/docs` directly.
- **env.test.ts** (pre-existing): 1 failure, unrelated to recent work.
- **State code mismatch (5-10% merge misses)**: dr5hn uses ISO 3166-2, GeoNames uses FIPS. 10-km fuzzy tier catches many but not all.
- **GeoNames `elevation_m` is NULL for all cities**: cities5000.txt doesn't include elevation; needs alternate dataset.
- **Phoenix OR**: dr5hn incorrectly marks `is_state_capital=1` — fixed in M6 migration 132, but watch for re-occurrence in dr5hn updates.
- **22 Null Island cities** (0,0 coords): flagged `unresolved` in M8.
- **35,546 cities with NULL population** (now ~19% post GeoNames merge): 97.3% flagged `no_pop` in M8.

## DB stats (D1 `timeandtimepro-full-v2`)

| Table | Count | Source |
|---|---:|---|
| **cities** | **170,253** | dr5hn (152,970) + GeoNames merge (17,283 new) |
| countries | 250 | dr5hn |
| administrative_regions | 5,308 | dr5hn |
| time_zones | 462 | IANA + 71 dr5hn extras |
| postcodes | 844,248 | dr5hn postcodes (M4) |
| translations | 2,965,561 | dr5hn (M5, 19 langs) |
| place_names | 451,000+ | dr5hn alt names |
| data_sources | 8 | M8 |
| data_quality_checks | 10 | M8 |
| **source_registry** | **10** | **M11.0 (1 active = GeoNames)** |
| **source_releases** | **1** | **M11.0 (geonames-cities5000-2026-08-02, validated)** |
| **cities_staging** | **69,561** | **M11.0 (raw, validated)** |
| **city_layer_log** | **69,563** | **M11.1 (merge audit log)** |

## M11.1 layer field coverage

| Field | Populated | Notes |
|---|---:|---|
| display_name | 67,999 | "Saint Petersburg" not "St. Petersburg" |
| short_name | 67,999 | Strips qualifiers (City of, Greater, The) |
| search_name | 67,999 | Normalized: lowercase, no diacritics |
| geonames_id | 67,999 | Cross-reference to GeoNames raw id |
| elevation_m | 0 | NULL (cities5000 has no elevation) |
| source_primary | 67,999 | 'dr5hn' (50,768) or 'geonames' (17,231) |
| source_merged_with | 50,768 | 'geonames' for dr5hn-primary |
| merge_method | 67,999 | 'exact' (47,815), 'fuzzy' (1,643), 'historical_alias' (1,310), 'geonames_only' (17,231) |
| merge_run_id | 67,999 | UUID of M11.1 run |
| merged_at | 67,999 | Unix timestamp |

## Deployment

| Env | Worker | URL | Last deploy |
|---|---|---|---|
| dev | `dt-api-v2-dev` | https://dt-api-v2-dev.nsura2029.workers.dev | 2026-08-02 09:38 UTC (version 1ef42791) |
| prod | `dateandtime-api` (planned) | TBD | not deployed |

## R2 bucket (`dt-data-raw`)

| Path | Size | Notes |
|---|---|---|
| `raw/geonames/cities5000/2026-08-02/` | 5.6 MB | Cities5000.zip + manifest.json + SHA-256 |

## How to resume work

```bash
cd /workspace/dateandtime-api-v2
git checkout feature/data-platform-geonames
git pull origin feature/data-platform-geonames
TEST_API_URL=https://dt-api-v2-dev.nsura2029.workers.dev npx vitest run
bash scripts/sync-status.sh     # refresh this file
```

## See also

- `README.md` — endpoint reference
- `TODO.md` — milestone checklist
- `CHANGELOG.md` — per-PR notes
- `docs/timezone-core-logic.md` — how TZ is determined
- `docs/timezone-data-audit.md` — M1-M8 metrics
- `docs/timezone-test-plan.md` — test plan + status
- `reports/` — per-milestone audits (M0-M11.1)
- `KNOWN_ISSUES.md` (planned) — bug log
