# STATUS

**If you only read one file in this repo, read this one.**

Last updated: 2026-08-02 16:30 UTC (auto-refreshed by scripts/sync-status.sh)

## TL;DR

`dateandtime-api-v2` — Hono + Cloudflare D1 + Zod timezone/cities API. M11.5 complete. 170,253 cities (dr5hn 152,970 + GeoNames 17,283 new), 250 countries, 462 IANA timezones, 19-language translations, 844K postcodes, 767K GeoNames alt names, 144,713 cities with full Wikidata descriptions, 5,000 CLDR country translations, 216 country populations (WB 2024), **10,121 US cities with Census population time series 2020-2025**, **156,111 cities with population (92%)**. Live at `https://dt-api-v2-dev.nsura2029.workers.dev`. **Not deployed to production.**

## Current branch state

| Branch | Purpose | Status |
|---|---|---|
| `main` | Production (empty) | dormant |
| `develop` | Integration | up to date with M0-M11.2.6 |
| `feature/m11.5-us-census` | M11.5 US Census Bureau city attributes | ready to merge |

## Last 5 commits

```
HEAD: M11.4: World Bank country population (216 countries, pivoted from UN WPP)
HEAD~1: M11.2.5: Wikidata alt_labels search strategy (15 new tests)
HEAD~2: M11.3: Unicode CLDR localized country names (5,000 rows, 20 langs, 2 new endpoints)
HEAD~3: M11.2.x: apply Wikidata population values to cities (21,461 filled)
HEAD~4: M11.2: Wikidata ingestion (115K entities, 117K cities with wiki_url)
```

## Test status

**444 / 447 pass** (3 pre-existing failures, all unrelated to M11.x work)

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
| `tests/altnames-search-strategy.test.ts` | 12 | M11.1.5 altNames search |
| `tests/m11.2-wikidata.test.ts` | 12 | M11.2 wikiUrl |
| `tests/m11.2.5-wikidata-altlabels.test.ts` | 15 | M11.2.5 alt_label search |
| `tests/m11.2.6-wikidata-desc.test.ts` | 18 | M11.2.6 wikidata description in /cities/{id} |
| `tests/m11.3-cldr.test.ts` | 18 | M11.3 country localized names |
| `tests/m11.4-worldbank.test.ts` | 18 | M11.4 country population (World Bank 2024) |
| `tests/m11.5-us-census.test.ts` | 20 | M11.5 US Census Bureau attributes |
| `tests/suggestions.test.ts` | 14 | M10+ did-you-mean |
| `tests/endpoints.test.ts` | 14 | M7 |
| `tests/search-ranking.test.ts` | 14 | M6 |
| `tests/translations.test.ts` | 11 | M5 |
| `tests/postcodes.test.ts` | 9 | M4 |
| `tests/enrichment.test.ts` | 3 | M2/M3 |
| `tests/health.test.ts` + `tests/status.test.ts` + `tests/env.test.ts` | (pre-existing) | 30 (1 failing) |

## Next 3 things (priority order)

1. **M11.6: Eurostat (City vs FUA)** (2-3 days)
   - EU-only
   - Distinguish administrative City from FUA

2. **M11.7: Census of India** (1-2 days)
   - 2011 still official
   - Will fix ~684 NULL IN cities (post M11.2.x)

3. **M11.5.1: ACS 5-year demographics** (deferred)
   - Median income, housing, education
   - Per-city US demographics
   - Same FIPS join key

## Future (deferred)

| Item | Estimate | Why deferred |
|---|---:|---|
| M11.2.7: Backfill missing 32,600 Wikidata Q-ids | 1-2 hours | Re-run SPARQL with full Q-id list |
| M11.2.8: Add Wikidata P31/P17/P131 to description | 2-3 days | Need richer SPARQL ingestion |
| Time-calc endpoint (DST + date-line math) | 1-2 days | Separate scope |
| polygon-based confidence (E4 multi-TZ municipality) | 1 week | Needs polygon data per city |
| Add country localized name to /cities/{id} response | 2 hours | Cosmetic, countries object already exists |
| Add /languages endpoint with localized language names | 2 hours | Same CLDR data, different `<language>` section |
| "World time" feature (per user brainstorm) | TBD | Per product PRD |
| Production deployment | when ready | User said "not ready for production" |

## Known issues

- **BUG-1 (open)**: Swagger UI CORS via `wrangler dev --remote` proxy. Workaround: open `https://dt-api-v2-dev.nsura2029.workers.dev/docs` directly.
- **pre-existing test failures (3)**: M8.5 data-quality issues, env.test.ts localhost wildcard, Rio Branco timezone. All unrelated to M11.x.
- **State code mismatch (5-10% merge misses)**: dr5hn uses ISO 3166-2, GeoNames uses FIPS. 10-km fuzzy tier catches many but not all.
- **GeoNames `elevation_m` is NULL for all cities**: cities5000.txt doesn't include elevation; needs alternate dataset.
- **Phoenix OR**: dr5hn incorrectly marks `is_state_capital=1` — fixed in M6 migration 132, but watch for re-occurrence in dr5hn updates.
- **22 Null Island cities** (0,0 coords): flagged `unresolved` in M8.
- **14,153 cities with NULL population**: 100% flagged `no_pop` in M8 (post M11.2.x + M11.4 data quality fixes).
- **34 countries without WB data**: small territories (Anguilla, Bouvet, etc.) that World Bank doesn't track. Falls back to dr5hn (which may also be NULL for uninhabited).
- **3,618 cities with wiki_data_id but no wikidata_staging row**: M11.2 ingestion stopped at 115K Q-ids. Empty `wikidata` block in API response (label=null).

## DB stats (D1 `timeandtimepro-full-v2`)

| Table | Count | Source |
|---|---:|---|
| **cities** | **170,253** | dr5hn (152,970) + GeoNames merge (17,283 new) |
| **cities with population** | **156,111 (92%)** | **+21,461 from M11.2.x Wikidata** |
| **cities with `wiki_url`** | **117,711 (69%)** | **M11.2 Wikidata** |
| countries | 250 | dr5hn |
| administrative_regions | 5,308 | dr5hn |
| time_zones | 462 | IANA + 71 dr5hn extras |
| postcodes | 844,248 | dr5hn postcodes (M4) |
| translations | 2,965,561 | dr5hn (M5, 19 langs) |
| place_names | 451,000+ | dr5hn alt names |
| data_sources | 8 | M8 |
| data_quality_checks | 10 | M8 |
| **source_registry** | **10** | **M11.0 (2 active = GeoNames + us_census)** |
| **source_releases** | **7** | **M11.0 + M11.1.5 + M11.2 + M11.3 + M11.4 + M11.5 (gaz + sub-est)** |
| **cities_staging** | **69,561** | **M11.0 (raw, validated)** |
| **alt_names_staging** | **767,572** | **M11.1.5 (GeoNames alt names, validated)** |
| **wikidata_staging** | **115,731** | **M11.2 (Wikidata entities, raw-stored)** |
| **country_names** | **5,000** | **M11.3 (CLDR 48.2 country names, 20 langs × 250 countries)** |
| **country_populations** | **216** | **M11.4 (World Bank SP.POP.TOTL year=2024, 216 of 250 countries)** |
| **us_census_attributes** | **14,459** | **M11.5 (US Census Bureau: 14,459 with FIPS, 10,121 with pop time series)** |
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
| `raw/cldr/territories-48.2/2026-08-02/` | 8.6 MB | CLDR 48.2: 20 lang XMLs + tarball + manifest |
| `raw/world_bank/pop-totl/2026-08-02/` | 78.7 KB | World Bank SP.POP.TOTL 2024 (216 countries JSON + manifest) |
| `raw/us_census/gazetteer/2024/2026-08-03/` | 1.2 MB | US Census 2024 Gazetteer (zip + manifest) |
| `raw/us_census/sub-est/2025/2026-08-03/` | 7.1 MB | US Census SUB-EST2025 (CSV + manifest) |

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
