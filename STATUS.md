# STATUS

**If you only read one file in this repo, read this one.**

Last updated: 2026-08-02 11:00 UTC (auto-refreshed by scripts/sync-status.sh)

## TL;DR

`dateandtime-api-v2` — Hono + Cloudflare D1 + Zod timezone/cities API. M11.5 complete. 170,253 cities (dr5hn 152,970 + GeoNames 17,283 new), 250 countries, 462 IANA timezones, 19-language translations, 844K postcodes, 767K GeoNames alt names. Live at `https://dt-api-v2-dev.nsura2029.workers.dev`. **Not deployed to production.**

## Current branch state

| Branch | Purpose | Status |
|---|---|---|
| `main` | Production (empty) | dormant |
| `develop` | Integration | up to date with M0-M11.5 |
| `feature/search-layer-ranking` | M11.1+ search + M11.1.5 altNames | **merged to develop** |

## Last 5 commits

```
HEAD: merge: M11.1+ search_name strategy + M11.1.5 altNames
HEAD~1: M11.1.5: GeoNames alternateNamesV2 loaded + 12 new historical_alias_v2 matches
HEAD~2: WIP: alt_names_staging + Wikidata staging + HTTP API loader
HEAD~3: M11.1+ search: add cities.search_name LIKE strategy + index
HEAD~4: merge: M11.0 data platform + M11.1 layer merge (dr5hn + GeoNames)
```

## Test status

**353 / 354 pass** (1 pre-existing `tests/env.test.ts` failure, unrelated to recent work)

| Test file | Tests | Covers |
|---|---:|---|
| `tests/timezone-fixtures.test.ts` | 84 | M1 polygon truth |
| `tests/data-quality.test.ts` | 15 | M8 metadata |
| `tests/edge-cases.test.ts` | 46 | M10+ E1-E14 |
| `tests/final-regression.test.ts` | 76 | M10 F1-F14 |
| `tests/sources.test.ts` | 13 | M11.0 source registry |
| `tests/cities-staging.test.ts` | 5 | M11.0 staging |
| `tests/m11.1-layer.test.ts` | 15 | M11.1 layer fields |
| `tests/search-name-strategy.test.ts` | 10 | M11.1+ search ranking |
| `tests/suggestions.test.ts` | 14 | M10+ did-you-mean |
| `tests/endpoints.test.ts` | 14 | M7 |
| `tests/search-ranking.test.ts` | 14 | M6 |
| `tests/translations.test.ts` | 11 | M5 |
| `tests/postcodes.test.ts` | 9 | M4 |
| `tests/enrichment.test.ts` | 3 | M2/M3 |
| `tests/health.test.ts` + `tests/status.test.ts` + `tests/env.test.ts` | (pre-existing) | 30 (1 failing) |

## Next 3 things (priority order)

1. **M11.2: Wikidata ingestion** (1-2 days)
   - Source already in `source_registry`
   - Brings: Wikipedia URLs, official alt names, populations
   - Uses the parallel HTTP API loader pattern from M11.1.5
   - 148K cities have a `wiki_data_id` to query

2. **Use alt names in search ranking** (4-6 hours)
   - Add new strategy to `/cities/search` that joins `alt_names_staging`
     on `alternate_name LIKE ?` and returns the city_id
   - Lets users search "Bombay" → Mumbai, "Chimkent" → Shymkent
   - Expected: 10-20% more matches for cross-language / historic queries

3. **Add alt_name display in /cities/{id}** (2 hours)
   - Show all known alt names grouped by language
   - Flag historic ones with "(historic)" label
   - 4-5 API response fields added

## Future (deferred)

| Item | Estimate | Why deferred |
|---|---:|---|
| Time-calc endpoint (DST + date-line math) | 1-2 days | Separate scope |
| polygon-based confidence (E4 multi-TZ municipality) | 1 week | Needs polygon data per city |
| M11.3 Unicode CLDR (territory-language) | 1 day | Pattern proven, just need data |
| M11.4 UN WPP 2024 (country pop) | 1-2 days | Per-country, low complexity |
| M11.5 US Census (state/city pop) | 2-3 days | Vintage tracking adds complexity |
| M11.6 Eurostat (City vs FUA) | 2-3 days | EU-only |
| M11.7 Census of India | 1-2 days | 2011 still official |
| M11.8 World Bank Indicators | 1 day | Easy API |
| M11.9 India population projections | 1 day | Already have data from M11.7 |
| "World time" feature (per user brainstorm) | TBD | Per product PRD |
| Production deployment | when ready | User said "not ready for production" |

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
| **source_releases** | **2** | **M11.0 + M11.1.5 (both validated)** |
| **cities_staging** | **69,561** | **M11.0 (raw, validated)** |
| **alt_names_staging** | **767,572** | **M11.1.5 (GeoNames alt names, validated)** |
| **city_layer_log** | **0** | **M11.1 (table created, audit inserts skipped)** |

## M11.1 layer field coverage

| Field | Populated | Notes |
|---|---:|---|
| display_name | 68,098 | "Saint Petersburg" not "St. Petersburg" |
| short_name | 68,098 | Strips qualifiers (City of, Greater, The) |
| search_name | 68,098 | Normalized: lowercase, no diacritics |
| geonames_id | 68,098 | Cross-reference to GeoNames raw id |
| elevation_m | 0 | NULL (cities5000 has no elevation) |
| source_primary | 68,098 | 'dr5hn' (50,815) or 'geonames' (17,283) |
| source_merged_with | 50,815 | 'geonames' for dr5hn-primary |
| merge_method | 68,098 | 'exact' (47,859), 'fuzzy' (1,638), 'historical_alias' (1,306), 'historical_alias_v2' (12), 'geonames_only' (17,283) |
| merge_run_id | 68,098 | UUID of M11.1 run |
| merged_at | 68,098 | Unix timestamp |

## Deployment

| Env | Worker | URL | Last deploy |
|---|---|---|---|
| dev | `dt-api-v2-dev` | https://dt-api-v2-dev.nsura2029.workers.dev | 2026-08-02 10:10 UTC (version 9f24ae9b) |
| prod | `dateandtime-api` (planned) | TBD | not deployed |

## R2 bucket (`dt-data-raw`)

| Path | Size | Notes |
|---|---|---|
| `raw/geonames/cities5000/2026-08-02/` | 5.6 MB | Cities5000.zip + manifest.json + SHA-256 |
| `raw/geonames/alternateNamesV2/2026-08-02/` | 30 MB | Filtered alt names for cities5000 |

## How to resume work

```bash
cd /workspace/dateandtime-api-v2
git checkout develop
git pull origin develop
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
- `reports/` — per-milestone audits (M0-M11.5)
- `KNOWN_ISSUES.md` (planned) — bug log
