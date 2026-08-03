# NEXT-TASKS — dateandtime-api-v2 (post-M13)

> Generated 2026-08-03 from session "verifying the holidays API for US and edgecases and test cases."
> Each prompt is a self-contained unit of work. Pick by impact × effort.

## Quick index

| ID | Name | Impact | Effort | Status |
|---|---|---|---|---|
| **PROMPT-A** | Holidays Phase 7: US + edge-case verification + tests | HIGH | M | **in progress** |
| PROMPT-B | M14 Holidays data enrichment (5 countries → 20+ countries) | HIGH | XL | queued |
| PROMPT-C | M14.1 Holiday deduplication (same holiday from multiple sources) | HIGH | M | queued |
| PROMPT-D | M14.2 SEASON + WORLD_OBSERVANCE data (filter count > 0) | MED | M | queued |
| PROMPT-E | M14.3 Performance: N+1 query fixes (filters + holidays) | HIGH | S | queued |
| PROMPT-F | M14.4 /countries/{cca2}/holidays broken (recursive fetch) | LOW | XS | queued |
| PROMPT-G | M14.5 /long-weekends dedup + bridge detection | MED | M | queued |
| PROMPT-H | M11.2 Wikidata ingest (see TODO.md) | MED | M | queued |
| PROMPT-I | M11.6 Eurostat — extend to more EU countries | LOW | M | queued |
| PROMPT-J | World Bank Indicators (M11.8 alt) | LOW | M | queued |
| PROMPT-K | India population projections 2011-2036 (M11.9) | LOW | M | queued |
| PROMPT-L | Time-calc endpoint (DST + dateline math) | MED | L | queued |

**Effort legend:** XS = <1h, S = 1-3h, M = 1-2 days, L = 1 week, XL = 2+ weeks.

---

## PROMPT-A — Holidays Phase 7: US + edge-case verification + tests

**Context:** The dev API has M14 data deployed (US=410 occurrences, 22 filters; NL=295, 7 filters; IN=293, 8; NZ=312, 6; GB=292, 7) but the local M13 code at `develop @ 565bed9` only knows about 190 occurrences with US=18 / NL=4. Tests are out of date, and we found several real bugs in the M14-deployed code.

**Goal:** Restore test/verification coverage so we can confidently ship M14.

### Sub-tasks

#### A.1 Update M13 tests to M14 reality
- US: `total = 18` → `total = 22` (UN_OBSERVANCE, JEWISH_MAJOR, JEWISH_MORE, OBS_IMPORTANT, OBS_COMMON, CLOCK_CHANGE, BANK_CLOSURE, GOVERNMENT_CLOSURE, SEASON, OPTIONAL_HOLIDAY, SCHOOL_HOLIDAY, SPORTING_EVENT, WORLD_OBSERVANCE, OBS_OTHER, OBS_LOCAL, MUSLIM_MAJOR, HINDU_MAJOR, ORTHODOX_MAJOR added)
- NL: `total = 4` → `total = 7` (UN_OBSERVANCE, JEWISH_MAJOR, JEWISH_MORE, OBS_COMMON, SEASON added)
- US PUBLIC_NATIONAL: 10 → 14 (more granular: federal + state-level via Nager.Date)
- NL PUBLIC_NATIONAL: 11 (unchanged)

#### A.2 New test file: `tests/m14-holidays-verify.test.ts`
- **Variance (5 countries):** US=22, NL=7, IN=8, GB=7, NZ=6
- **US specific:**
  - 10 federal holidays present in PUBLIC_NATIONAL (New Year, MLK, Presidents, Memorial, Juneteenth, Independence, Labor, Columbus, Veterans, Thanksgiving, Christmas = 11)
  - Independence Day 2026-07-04 (Sat) has observed date 2026-07-03
  - All 11 federal holidays have `dateStatus = confirmed`
  - 450+ UN observances for US
  - JEWISH_MAJOR contains Rosh Hashana, Yom Kippur, Passover, Sukkot, Hanukkah (5 minimum)
- **Year boundary:**
  - 2026-12-25 + 2027-01-01 both in range 2026-12-25..2027-01-05
  - US 2025 + 2026 + 2027 PUBLIC_NATIONAL ≈ 10-12 each year (federal count stable)
- **Multi-day:**
  - NL Goede Vrijdag, Pasen, Pinksteren are single days (not multi-day) — but check if any country has multi-day (e.g. Diwali, Eid)
- **Cross-country:**
  - 5 countries have PUBLIC_NATIONAL between 8-12 days
  - 5 countries have UN_OBSERVANCE = 450 (same set of UN days in each)
- **Performance:**
  - /holidays?country=US&year=2026&limit=100 < 3000ms
  - /countries/US/filters?year=2026 < 1000ms
  - /long-weekends?country=US&year=2026 < 500ms (currently 128ms ✓)
- **Edge cases:**
  - Invalid country code (XX) → 404 with `COUNTRY_NOT_FOUND`
  - Invalid holiday id (99999999) → 404 with `HOLIDAY_NOT_FOUND`
  - `limit > 500` → 400 with ZodError
  - `from > to` → empty results, no error
  - `year=1900` (very old) → empty results
  - `year=2099` (very future) → empty results
  - Feedback with no description → 400 with ZodError
  - Feedback with bad email → 400 with ZodError

#### A.3 Document bugs found (to be fixed in PROMPT-C/D/E/F/G)
1. `/holidays/today` returns `filters: [], sources: []` (empty arrays) — should populate
2. `/holidays/upcoming` same as #1
3. `/countries/{cca2}/filters` is 1.8s for US (22 filters × 2 count queries = 45 queries)
4. `/holidays?country=US&year=2026&limit=100` is 8.5s (100 rows × 2 queries = 200 queries)
5. `/countries/{cca2}/holidays` returns 404 (recursive fetch bug, same URL passed to itself)
6. `/long-weekends?country=US&year=2026` returns 74 entries (one per occurrence, should dedup)
7. SEASON filter shows `rangeCount=4` but `/holidays?filters=SEASON` returns 0 (data not loaded or filter SQL wrong)
8. Same holiday appears multiple times: MLK Day "Jr. Day" vs "Jr Day" (2 concepts), Presidents "Day" vs "'" Day, Labor vs Labour, Independence 7/3 vs 7/4 — needs dedup strategy
9. `Labour Day` (UK spelling) and `Labor Day` (US spelling) are different concepts — should they be the same?
10. `Independence Day 2026-07-03` (nager_date) and `Independence Day 2026-07-04 observed=2026-07-03` (computed_federal_us) — which is the "real" date for display?

### Acceptance criteria

- All 30+ tests in `m14-holidays-verify.test.ts` pass
- M13 tests pass with updated assertions
- Bugs #1-#7 (fixable in code) have PR-ready patches
- Bugs #8-#10 (data issues) have design proposals in `reports/m14-bugs-and-design.md`

### Files to touch

- `tests/m13-holidays.test.ts` — update assertions (US=22, NL=7)
- `tests/m14-holidays-verify.test.ts` — NEW
- `reports/m14-bugs-and-design.md` — NEW
- (No source changes for A.1-A.2; fixes go in PROMPT-C through G)

---

## PROMPT-B — M14 Holidays data enrichment (5 → 20+ countries)

**Why:** The M14 spec says 13 golden countries. We have 5. The other 8 are: UK (we have GB), AU, NZ (we have), CA, DE, FR, ES, IT, NO, SE, PT, CN, IN, UAE, SG, JP, KR. Pick by customer demand.

**Sources by country:**
- AU, NZ, GB, CA, IN: Nager.Date (free, MIT-style, has 100+ countries)
- DE, FR, ES, IT, NO, SE, PT: OpenHolidays API (free, ODbL, EU-focused)
- CN: China State Council (manual curation, no API)
- JP: Cabinet Office (manual, calendar)
- KR: Korean Government (manual)
- AE/SG: Nager.Date or manual

**Output:**
- 20+ countries loaded
- ~10K occurrences total
- 13 country_filter_policy rows
- Reconciliation tests pass for all 13 golden countries

**Effort:** XL (~2 weeks). Requires per-country manifest + fetcher + parser + reconciliation tests.

---

## PROMPT-C — M14.1 Holiday deduplication

**Why:** Same holiday from multiple sources (Nager.Date, computed_federal_us, hebcal, un_official) creates duplicate entries with slight concept name variations.

**Approach options:**
1. **Concept merge:** When loading, merge concepts with same date+country+name (case-insensitive, fuzzy match for punctuation like "Jr." vs "Jr")
2. **Display dedup:** Add a `dedupKey` to response, client groups by key
3. **Source priority:** Show only one source per (country, date) — priority: official > licensed > open

**Recommendation:** Approach 1 (concept merge) + Approach 3 (source priority). One canonical concept per "real" holiday. Multiple sources tracked in `holiday_occurrence_source` for lineage.

**Output:** Independence Day appears once, with `sources: ["nager_date", "computed_federal_us"]` showing both contributed.

**Effort:** M.

---

## PROMPT-D — M14.2 SEASON + WORLD_OBSERVANCE data

**Why:** US SEASON filter says 4 occurrences, but list query returns 0. Either data not loaded or filter SQL excludes them.

**Debug steps:**
1. Query `holiday_occurrence` directly: `SELECT * WHERE country_id = (US) AND event_domain = 'astronomical'` — should return 4
2. If empty: data wasn't loaded (seed script issue)
3. If non-empty: filter SQL doesn't include astronomical events in SEASON filter
4. Same check for WORLD_OBSERVANCE

**Output:** SEASON returns 4 (Spring Equinox, Summer Solstice, Autumn Equinox, Winter Solstice) for every country.

**Effort:** M.

---

## PROMPT-E — M14.3 Performance: N+1 fixes

**Bug:** `/countries/US/filters` runs 45 queries (22 × 2). `/holidays?country=US&year=2026&limit=100` runs 200 queries (100 × 2).

**Fix:** Use GROUP BY + JOIN to get all counts in a single query.

```sql
-- For /countries/{cca2}/filters: 1 query instead of 2N
SELECT f.filter_code,
  COUNT(DISTINCT CASE WHEN occ.start_date <= ? AND COALESCE(occ.end_date, occ.start_date) >= ? THEN occ.id END) as range_count,
  COUNT(DISTINCT CASE WHEN substr(occ.start_date, 1, 4) = ? THEN occ.id END) as annual_count
FROM country_filter_policy p
LEFT JOIN holiday_occurrence_filter f ON f.filter_code = p.filter_code
LEFT JOIN holiday_occurrence occ ON occ.id = f.occurrence_id AND occ.country_id = ?
WHERE p.country_code = ? AND p.state != 'unsupported'
GROUP BY p.filter_code

-- For /holidays list: 1 query for filters + 1 for sources, batched
SELECT of.occurrence_id, GROUP_CONCAT(of.filter_code) as filters FROM holiday_occurrence_filter of WHERE of.occurrence_id IN (...) GROUP BY of.occurrence_id
```

**Expected impact:** /countries/US/filters: 1.8s → 200ms (9× faster). /holidays list: 8.5s → 500ms (17× faster).

**Effort:** S.

---

## PROMPT-F — M14.4 /countries/{cca2}/holidays broken (recursive fetch)

**Bug:** Endpoint returns 404 because it does `fetch(url.toString())` with the same URL (only adds a query param, not a different path).

**Current code:**
```ts
const url = new URL(c.req.url);
url.searchParams.set("country", p.cca2);
const r = await fetch(url.toString(), ...);  // ← same path!
```

**Fix:** Just inline the query (copy the `/holidays` handler logic) or use a helper function. No need for self-fetch.

**Effort:** XS.

---

## PROMPT-G — M14.5 /long-weekends dedup + bridge detection

**Bug:** US 2026 returns 74 long-weekend entries (duplicates per occurrence). Should be ~10-12.

**Fix:**
1. Dedup by (start, end) — keep one entry per long-weekend
2. For Thu/Fri holidays that touch weekend, check if the surrounding day is also a holiday (true bridge = 4-day weekend)
3. Remove "possible bridge" speculation for Tue/Thu — only show 3-day if adjacent day is actually off

**Output:** US 2026 = 11 long-weekends (3-day, 4-day, 5-day). E.g., Independence Day Sat 7/4 → observed Fri 7/3 = 4-day weekend (Fri-Sat-Sun-Mon).

**Effort:** M.

---

## Cross-references

- `TODO.md` — old task list, mostly M11.x done
- `reports/holidays-deferred-work.md` — original M13 spec deferred work
- `reports/m13-holidays-result.md` — M13 ship report
- `docs/references/data-platform-journey.md` — TBD (not yet written)
- `docs/references/data-sources-master.md` — TBD (not yet written)
