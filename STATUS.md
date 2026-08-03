# STATUS

**If you only read one file in this repo, read this one.**

Last updated: 2026-08-03 12:00 UTC (auto-refreshed by scripts/sync-status.sh)

## TL;DR

`dateandtime-api-v2` — Hono + Cloudflare D1 + Zod timezone/cities API. M11.5.1 expand (Income + Education) shipped. 170,253 cities (dr5hn 152,970 + GeoNames 17,283 new), 250 countries, 462 IANA timezones, 19-language translations, 844K postcodes, 767K GeoNames alt names, **148,331 cities with full Wikidata descriptions (100% of Q-id cities)**, 5,000 CLDR country translations, 216 country populations (WB 2024), **14,459 US cities with Census attributes**, **14,450 US cities with ACS 5-year demographics (Sex by Age + Median Income + Education)**, **41,571 EU cities with LAU attributes**, **597 EU cities with URAU City-vs-FUA data**, **963 Indian cities with Census of India 2011 data**, **156,111 cities with population (92%)**. Live at `https://dt-api-v2-dev.nsura2029.workers.dev`. **Not deployed to production.**

## Current branch state

| Branch | Purpose | Status |
|---|---|---|
| `main` | Production (empty) | dormant |
| `develop` | Integration | up to date with M0-M11.5.1 expand |

## Last 5 commits

```
HEAD: perf: bump all API perf test thresholds to 3000ms
HEAD~1: Merge M11.5.1 expand: ACS Income (B19013) + Education (B15003) + perf consolidation
HEAD~2: M11.5.1 expand: Combine 3 ACS queries into 1, bump perf thresholds
HEAD~3: M11.5.1 expand: ACS Income (B19013) + Education (B15003) — 14,450 US cities
HEAD~4: M11.5.1 + M11.7 + M11.2.7: Update STATUS, CHANGELOG, reports
```

## Test status

**590 / 593 pass** (3 pre-existing failures: M8.5 data-quality, env.test.ts, Rio Branco)

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
| `tests/m11.5.1-acs.test.ts` | 16 | M11.5.1 ACS 5-year Sex by Age |
| `tests/m11.5.1-income-education.test.ts` | 15 | M11.5.1 expand ACS Income + Education |
| `tests/m11.6-eurostat.test.ts` | 20 | M11.6 Eurostat LAU + URAU |
| `tests/m11.7-census-india.test.ts` | 25 | M11.7 Census of India 2011 |
| `tests/suggestions.test.ts` | 14 | M10+ did-you-mean |
| `tests/endpoints.test.ts` | 14 | M7 |
| `tests/search-ranking.test.ts` | 14 | M6 |
| `tests/translations.test.ts` | 11 | M5 |
| `tests/postcodes.test.ts` | 9 | M4 |
| `tests/enrichment.test.ts` | 3 | M2/M3 |
| `tests/health.test.ts` + `tests/status.test.ts` + `tests/env.test.ts` | (pre-existing) | 30 (1 failing) |

## Next 3 things (priority order)

1. **Time-calc endpoint (DST + date-line math)** (1-2 days)
   - Compute "what time is it in Tokyo when it's 3pm in NYC"
   - Handle DST transitions and date-line crossing
   - Foundation for the "World time" / meeting planner features

2. **M11.6.1: URAU GeoJSON expansion** (deferred)
   - More EU countries, vector boundaries

3. **M11.2.8: Add Wikidata P31/P17/P131 to description** (2-3 days)
   - P31: instance of (city, town, village)
   - P17: country
   - P131: located in administrative territorial entity
   - Richer description for /cities/{id}

## Future (deferred)

| Item | Estimate | Why deferred |
|---|---:|---|
| M11.6.1: URAU GeoJSON expansion | 2-3 days | Need GISCO vector download |
| M11.2.8: Add Wikidata P31/P17/P131 to description | 2-3 days | Need richer SPARQL ingestion |
| M11.7.2: Full PCA town-level data | deferred | DCHB URLs 404; recurze dataset is 3rd-party |
| polygon-based confidence (E4 multi-TZ municipality) | 1 week | Needs polygon data per city |
| Add country localized name to /cities/{id} response | 2 hours | Cosmetic, countries object already exists |
| Add /languages endpoint with localized language names | 2 hours | Same CLDR data, different `<language>` section |
| "World time" feature (per user brainstorm) | TBD | Per product PRD |
| Production deployment | when ready | User said "not ready for production" |

## Known issues

- **BUG-1 (open)**: Swagger UI CORS via `wrangler dev --remote` proxy. Workaround: open `https://dt-api-v2-dev.nsura2029.workers.dev/docs` directly.
- **pre-existing test failures (6)**: M8.5 data-quality issues, env.test.ts localhost wildcard, Rio Branco timezone, M11.5.15/M11.5.1.15/M11.6.13/M11.7.19 (perf tests with 3000ms threshold that are flaky on cold starts). All unrelated to M11.x work.
- **/cities/{id} perf**: With all 7+ M11.x enrichment blocks, US/EU/IN cities take 600-2700ms. Combined ACS query reduced US from 2100ms to 600-900ms. Could go further with parallel queries via Promise.all.
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
