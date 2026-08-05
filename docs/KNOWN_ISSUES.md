# Known Issues

Tracked bugs and TODOs. Format follows `docs/AGENTS.md`.

## BUG-1: Swagger UI CORS via `wrangler dev --remote` proxy

**Status:** Open (low impact — has workaround)
**Severity:** Low
**Affects:** Local development with `wrangler dev --remote`
**Workaround:** Open `https://dt-api-v2-dev.nsura2029.workers.dev/docs` directly
**Root cause:** Browser CORS preflight on the local proxy
**Fix:** Add a custom dev CORS handler in `src/index.ts` (deferred — dev convenience only)

## BUG-2: /api/v1/countries/{cca2}/holidays returns 404

**Status:** Open
**Severity:** Medium
**Affects:** All country shortcut endpoint
**Workaround:** Use `/api/v1/holidays?country=XX` instead — same data
**Root cause:** Hono route registration conflict between `/countries/{cca2}/holidays` and other routes
**Fix:** Investigate route registration order in `src/routes/holidays.ts:439` (1 hour)

## TODO-1: D1 100-var limit documentation

**Status:** Done (in schema-evolution.md)
**Severity:** Low
**Affects:** Anyone writing bulk INSERTs
**Workaround:** See `docs/references/schema-evolution.md` for BATCH_ROWS reference
**Notes:** Handled via reference table for each col count

## Pre-existing test failures (3 + 1 unrelated)

These have been failing since M0-M11.5.1, unrelated to M14 work:

- **env.test.ts:** localhost CORS test (1 failure)
- **data-quality.test.ts (M8.5):** data quality metric changed (1 failure)
- **final-regression.test.ts (Rio Branco):** timezone edge case (1 failure)
- **m11.5.1-acs.test.ts:** perf test on cold start (1 timeout)

## Deferred items (captured in TODO.md)

- ERA5 climate (3-5 days) — user said "weather after MVP"
- M11.6.1: URAU GeoJSON expansion
- M11.7.2: Full PCA town-level data (India)
- Admin-2 population/area/coords
- Holidays Phase 6: Admin/review UI
- Polygon-based confidence (E4 multi-TZ)
- "World time" feature (meeting planner)
- Production deployment
- Calendarific / Holiday API (paid)
- Long-weekend finder (1-2 days)
- Holidays Phase 7: Worldwide onboarding (CA, AU, FR, DE, IT, ES, IE, NO, SE, DK, FI)
- Time-calc endpoint (DST + date-line math)
- 10 deferred holidays endpoints (business-day calc, CSV, subdivision, etc.)
