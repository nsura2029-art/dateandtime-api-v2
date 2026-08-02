# STATUS

**If you only read one file in this repo, read this one.**

Last updated: 2026-08-02 07:15 UTC (auto-refreshed by scripts/sync-status.sh)

## TL;DR

`dateandtime-api-v2` — Hono + Cloudflare D1 + Zod timezone/cities API. MVP complete. 152,970 cities, 250 countries, 462 IANA timezones, 19-language translations, 844K postcodes. Live at `https://dt-api-v2-dev.nsura2029.workers.dev`. **Not deployed to production.**

## Current branch state

| Branch | Purpose | Status |
|---|---|---|
| `main` | Production (empty) | dormant |
| `develop` | Integration | 15 commits behind `feature/global-timezone-polygon` |
| `feature/global-timezone-polygon` | M0-M10+ work | **15 commits, ready to merge to develop** |
| `feature/population-tier` | M6 (merged into global-timezone-polygon) | stale |
| `feature/postman-collection` | M10 Postman generator (merged) | stale |

## Last 5 commits

```
154aa00 M10+ Option C: 'Did you mean' suggestions when 0 results
624e074 docs: analysis of 'vinjanampadu' missing-from-search
b3d81ee M10+: Add 46 edge case tests covering E1-E14
0c224fc feat: M10 final regression — endpoint docs, edge case tests, Postman collection
54860d0 docs: M9 documentation + swagger UI enhancements
```

## Test status

**310 / 311 pass** (1 pre-existing `tests/env.test.ts` failure, unrelated to M0-M10+)

| Test file | Tests | Covers |
|---|---:|---|
| `tests/timezone-fixtures.test.ts` | 84 | M1 polygon truth |
| `tests/data-quality.test.ts` | 15 | M8 metadata |
| `tests/edge-cases.test.ts` | 46 | M10+ E1-E14 |
| `tests/final-regression.test.ts` | 76 | M10 F1-F14 |
| `tests/endpoints.test.ts` | 14 | M7 |
| `tests/search-ranking.test.ts` | 14 | M6 |
| `tests/translations.test.ts` | 11 | M5 |
| `tests/postcodes.test.ts` | 9 | M4 |
| `tests/suggestions.test.ts` | 14 | M10+ did-you-mean |
| `tests/enrichment.test.ts` | 3 | M2/M3 |
| `tests/health.test.ts` + `tests/status.test.ts` | (pre-existing) | 22 |

## Next 3 things (priority order)

1. **Merge `feature/global-timezone-polygon` → `develop`** (15 min)
   - Run `bash scripts/sync-status.sh` to refresh this file
   - Open PR, run CI, merge
   - After merge: `develop` is the new "live" branch

2. **Trigram same-country preference** (5 min, when convenient)
   - When `?country=IN` is given AND trigram candidates exist, sort trigram
     matches so same-country results come first
   - File: `src/routes/cities.ts` STEP 8 strategy 2

3. **Fix `tests/env.test.ts` failure** (15 min, optional)
   - Pre-existing failure, not blocking
   - Likely a Cloudflare auth token check or wrangler version issue
   - Check the test output before deciding

## Future (deferred)

| Item | Estimate | Why deferred |
|---|---:|---|
| Time-calc endpoint (DST + date-line math) | 1-2 days | Separate scope |
| polygon-based confidence (E4 multi-TZ municipality) | 1 week | Needs polygon data per city |
| boundary_distance_km compute | 1 day | Heavy operation, low value |
| Airport data import (cron 426125193814084) | monthly | Already scheduled, will run 9 AM ET |
| Option B: GeoNames cities5000/villages | 1-2 days | Sub-15K villages; user said no |
| "World time" feature (per user brainstorm) | TBD | Per product PRD |
| Production deployment | when ready | User said "not ready for production" |

## Known issues

- **BUG-1 (open)**: Swagger UI CORS via `wrangler dev --remote` proxy. Workaround: open `https://dt-api-v2-dev.nsura2029.workers.dev/docs` directly.
- **BUG-3 (resolved but watch for it)**: Silent FK failures when `run-all.sh` skips failed files with `|| { ... true; }`. Always check final city count vs expected.
- **env.test.ts** (pre-existing): 1 failure, unrelated to recent work.
- **Phoenix OR**: dr5hn incorrectly marks `is_state_capital=1` — fixed in M6 migration 132, but watch for re-occurrence in dr5hn updates.
- **22 Null Island cities** (0,0 coords): flagged `unresolved` in M8.
- **35,546 cities with NULL population** (23% of dataset): 97.3% flagged `no_pop` in M8.

## DB stats (D1 `timeandtimepro-full-v2`)

| Table | Count | Source |
|---|---:|---|
| cities | 152,970 | dr5hn cities15000 |
| countries | 250 | dr5hn |
| administrative_regions | 5,308 | dr5hn |
| time_zones | 462 | IANA + 71 dr5hn extras |
| postcodes | 844,248 | dr5hn postcodes (M4) |
| translations | 2,965,561 | dr5hn (M5, 19 langs) |
| place_names | 451,000+ | dr5hn alt names |
| data_sources | 8 | M8 |
| data_quality_checks | 10 | M8 |

## Deployment

| Env | Worker | URL | Last deploy |
|---|---|---|---|
| dev | `dt-api-v2-dev` | https://dt-api-v2-dev.nsura2029.workers.dev | 2026-08-02 06:25 UTC (version 6cd207fc) |
| prod | `dateandtime-api` (planned) | TBD | not deployed |

## How to resume work

```bash
cd /workspace/dateandtime-api-v2
git checkout feature/global-timezone-polygon
git pull origin feature/global-timezone-polygon
npx vitest run                  # 310/311 expected
bash scripts/sync-status.sh     # refresh this file
```

## See also

- `README.md` — endpoint reference
- `TODO.md` — milestone checklist
- `CHANGELOG.md` — per-PR notes
- `docs/timezone-core-logic.md` — how TZ is determined
- `docs/timezone-data-audit.md` — M1-M8 metrics
- `docs/timezone-test-plan.md` — test plan + status
- `reports/` — per-milestone audits (M0-M10+)
- `KNOWN_ISSUES.md` (planned) — bug log
