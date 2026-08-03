# NEXT-TASKS — Recommended Prompts

> Drop one of these prompts into the next chat session to continue building. Each prompt is self-contained with the goal, scope, and acceptance criteria.

## Tier 1: Highest ROI (start here)

### 🚀 PROMPT-A: Holidays Phase 7 — Worldwide Onboarding

**Goal:** Add computed/adapter holiday loaders for 10+ more countries, following the GB pattern.

**Scope:**
- **Tier A official sources to add:**
  - GOV.UK (https://www.gov.uk/bank-holidays.json) — England&Wales, Scotland, Northern Ireland
  - Australian Fair Work (per state) — NSW, VIC, QLD, etc.
  - Canada federal + provincial
  - France Service-Public
  - Germany federal/Länder
  - India DoPT
- **Tier D fallback:** Nager.Date for all (covers 200+ countries)

**Tasks:**
1. Add GB England+Wales, Scotland, N.Ireland as subdivisions (we already have GB at country level)
2. Add CA: federal + 13 provinces/territories
3. Add AU: 6 states + 2 territories with state-level holidays
4. Add FR: national holidays via computed rules (fixed dates like Bastille Day, religious via Computus)
5. Add DE: federal + 16 Länder (state-specific religious holidays)
6. Add IN: full DoPT + 28 states (currently we have 9 from Nager.Date)
7. Update country_filter_policy for each new country
8. Update variance endpoint counts
9. Add tests for each new country

**Acceptance criteria:**
- 10+ new countries loaded with holidays for 2026 + 2027
- Each country has a variance endpoint showing applicable filters
- All tests pass
- Country filter policies updated

**Time:** 2-3 days
**Files to touch:**
- `scripts/seed/holiday_enrichment/computed.py` (add more generators)
- `scripts/seed/holiday_enrich.py` (add more branches)
- `tests/m14-holiday-enrichment.test.ts` (or new test file)
- `docs/references/holidays/<country>.md` for each new country

---

### 🚀 PROMPT-B: Time-calc endpoint (DST + date-line math)

**Goal:** Add `GET /api/v1/time/calc` that converts a datetime from one timezone to another, handling DST and date-line crossing.

**Scope:**
- One endpoint: `/api/v1/time/calc?from=America/New_York&to=Asia/Tokyo&datetime=2026-07-01T15:00:00`
- Returns: `from` datetime, `to` datetime, both with timezone abbreviations, UTC offset, is_dst

**Tasks:**
1. Add Zod schema for query params
2. Use Python `zoneinfo` equivalent (Luxon or date-fns-tz) or call out to a Worker-compatible TZ library
3. Handle DST transitions: if datetime falls in a DST gap, return both interpretations
4. Handle date-line crossing: e.g., Mon 11pm Hawaii = Tue 9am NY
5. Add tests: 20+ scenarios including DST gap, date-line, leap year

**Acceptance criteria:**
- Endpoint works for all 462 IANA timezones
- DST transition is handled correctly (e.g., 2026-03-08 02:30 in NYC → 03:30 EDT)
- Date-line crossing is correct
- Performance < 100ms

**Time:** 1-2 days
**Files to touch:**
- `src/routes/time.ts`
- `docs/api/openapi.json`
- `tests/time-calc.test.ts`

---

### 🚀 PROMPT-C: Holidays Phase 2 — IANA clock changes + seasons + observances

**Goal:** Expose the IANA-derived clock changes (DST transitions) and the worldwide observances in the API as filterable holidays.

**Scope:**
- Already loaded: 1,560 DST transitions, 4 seasons, 178 UN days
- API gap: these aren't visible via `mode=international` for the right filters

**Tasks:**
1. Add a filter for "Clock change" that shows DST transitions for any timezone
2. Add a filter for "International observance" that shows UN days + worldwide
3. Make sure all worldwide events have proper filter codes assigned
4. Add `?tz=America/New_York` query param for DST transitions to filter by timezone

**Acceptance criteria:**
- `/api/v1/holidays?filters=CLOCK_CHANGE&tz=America/New_York&year=2026` returns 2 entries
- All worldwide events are visible via `mode=international&filters=UN_OBSERVANCE`
- Filters work correctly

**Time:** 1 day
**Files to touch:**
- `src/routes/holidays.ts`
- `tests/m14-holiday-enrichment.test.ts`

---

## Tier 2: High value (post-MVP)

### 🎯 PROMPT-D: Long-Weekend Finder (SEO win)

**Goal:** Build a public-facing long-weekend finder for SEO. 80K searches/mo for "long weekend [country] [year]".

**Scope:**
- `GET /api/v1/long-weekends?country=US&year=2026` (already exists, enhance)
- Algorithm: scan all public holidays in the year, combine with adjacent weekends + PTO days
- Show 3-day, 4-day, 5-day weekends

**Tasks:**
1. Enhance the existing `/long-weekends` endpoint with smarter algorithm
2. Add per-state variation (e.g., TX gets MLK Day off → long weekend)
3. Add SEO landing pages at `/long-weekend/{country}/{year}/` (front-end)
4. Add structured data (schema.org/Event) for SEO

**Acceptance criteria:**
- US 2026 returns 8-10 long weekends (MLK, Presidents, Memorial, July 4, Labor, Columbus, Thanksgiving, Christmas-NYE)
- Includes 4-day weekends (Independence Day observed Monday, Christmas + observed Tue)

**Time:** 1-2 days
**Files to touch:**
- `src/routes/holidays.ts` (enhance the endpoint)
- `tests/m13-holidays.test.ts` (more scenarios)
- Front-end: `tdp-landing` Worker (separate repo)

---

### 🎯 PROMPT-E: Production deployment

**Goal:** Deploy to production after user sign-off.

**Scope:**
- Set up production D1 database
- Set up production Worker
- Configure custom domain (api.timeandtime.com or similar)
- Smoke tests
- Handoff checklist

**Tasks:**
1. Create production D1 database
2. Apply all 157 migrations to production
3. Deploy Worker
4. Set up CNAME / route 53
5. Verify with smoke tests
6. Update STATUS.md and CHANGELOG.md

**Acceptance criteria:**
- All 669 tests pass against production
- Latency is similar to dev
- Monitoring is set up (Cloudflare Analytics)

**Time:** 1 day
**Files to touch:**
- `wrangler.toml` (add `[env.production]` block)
- `migrations/` (all 157 files)

---

## Tier 3: Big investments (multi-day)

### 📈 PROMPT-F: ERA5 climate for 19K cities

**Goal:** Add real climate data for cities without NCEI stations. 19K cities currently use lat-based fallback.

**Scope:**
- ERA5 reanalysis data from Copernicus CDS
- 31 km resolution, hourly → aggregate to monthly
- TMAX, TMIN, PRCP
- 19K cities × 12 months = 228K rows

**Tasks:**
1. Set up Copernicus API account (free, but requires registration)
2. Get lat/lon for each city
3. Query ERA5 nearest grid point
4. Aggregate to monthly averages
5. Load into `climate_real` table (extend schema)
6. Update API: prefer ERA5 over lat-based fallback

**Acceptance criteria:**
- 19K cities have real climate data
- Quality is better than lat-based fallback (validate against known cities)
- API shows `source='era5'` vs `source='ncei-gsom'` vs `source='lat-based-model'`

**Time:** 3-5 days
**Files to touch:**
- `scripts/seed/era5_climate.py` (new)
- `migrations/158_climate_era5.sql` (new)
- `src/routes/city-resources.ts`

---

### 📈 PROMPT-G: Admin-2 population/area/coords

**Goal:** Add population and area for the 47,549 admin-2 regions.

**Scope:**
- Source: Wikidata SPARQL (has P1082 population, P2046 area)
- Some admin-2 regions don't have Wikidata items (manual fallback to GADM)

**Tasks:**
1. SPARQL query for admin-2 Wikidata items
2. For each region with P31 admin-2, get P1082 (population) and P2046 (area)
3. Compute centroid lat/lon from contained cities
4. Load into administrative_regions table
5. API: enrich `/admin2/{id}` with these fields

**Acceptance criteria:**
- 70% of admin-2 regions have population
- 90% have computed centroid
- `/admin2/{id}` returns 6+ fields instead of 4

**Time:** 1 week
**Files to touch:**
- `scripts/seed/admin2_population.py` (new)
- `migrations/159_admin2_population.sql` (new)
- `src/routes/subregions.ts`

---

## Tier 4: New ideas (explore the roadmap)

### 💡 PROMPT-H: "World time" / meeting planner

**Goal:** Build a cross-timezone meeting planner. From the user brainstorm.

**Scope:**
- `GET /api/v1/meeting/find?from=...&to=...&date=2026-07-01`
- Returns: overlapping business hours across N cities
- Visual: a world clock face showing each city's time

**Tasks:**
1. Add `/meeting/find` endpoint
2. Algorithm: 9-5 business hours overlap
3. SEO landing pages: `/meeting-planner/tokyo-new-york/`
4. Front-end: interactive world clock

**Acceptance criteria:**
- 3-city overlap works
- Handles DST in each city independently
- Front-end UX is clean

**Time:** 3-5 days

---

### 💡 PROMPT-I: Calendarific integration (post-revenue)

**Goal:** Add Calendarific as a tier C cross-check source. 230+ countries.

**Scope:**
- Requires paid Calendarific API key ($49/mo+)
- Use as cross-check for our holiday data
- Show "verified by Calendarific" badge

**Tasks:**
1. Get API key
2. Add Calendarific as a source
3. Cross-check 1,827 occurrences
4. Show discrepancies in admin UI

**Time:** 1-2 days (after API key is acquired)

---

### 💡 PROMPT-J: Polygon-based confidence (E4)

**Goal:** For cities that span multiple IANA timezones, use polygon intersection to pick the right tz.

**Scope:**
- Some Tennessee cities span Central/Eastern
- Some South Dakota cities span Central/Mountain
- Some Kansas cities span Central/Mountain

**Tasks:**
1. Get polygon data per city (or admin-2)
2. Intersect with IANA zone polygons
3. Pick the dominant zone by area
4. Set `tz_confidence` < 1.0 for ambiguous cities

**Acceptance criteria:**
- 100+ US cities get a non-default `tz_confidence`
- API exposes `tz_confidence` field

**Time:** 1 week

---

### 💡 PROMPT-K: SEO landing pages

**Goal:** Generate 1000+ SEO landing pages for "what time is it in [city]" queries.

**Scope:**
- Per city: time, timezone, DST, holidays, climate
- Pre-render as static HTML
- Submit to search engines

**Tasks:**
1. Use the new world-time + city APIs
2. Pre-render top 10K cities
3. Add structured data
4. Add sitemap.xml
5. Submit to Google Search Console

**Time:** 1 week
**Note:** Front-end Worker, separate repo

---

## How to use this doc

When you start a new session, copy one of these prompts and paste it. The prompt contains:
- The goal
- The scope (what's in/out)
- The tasks (ordered)
- The acceptance criteria
- The estimated time
- The files to touch

This gives you full context without needing to re-read all 157 migrations and 41 reports.

## What to do after the next task

After completing a task, update:
1. `CHANGELOG.md` — what shipped
2. `STATUS.md` — new counts, test status
3. `TODO.md` — move from "next-up" to "done"
4. `docs/references/` — new data source if added
5. `reports/` — per-milestone report

And append the next-tier task to this doc.
