# dateandtime-api-v2 — Product Requirements Document (PRD)

> **Status**: M14.x shipped · M15+ planned
> **Owner**: dateandtime.live team
> **Last updated**: 2026-08-05
> **Live API**: `https://dt-api-v2-dev.nsura2029.workers.dev`
> **Branch state**: `main` == `develop` == `feature/m14-holidays-verify` (synced at `b355a9e`)

---

## 1. What is this?

A single, authoritative **geo-temporal API** powering the `dateandtime.live` product family. It gives applications accurate, multilingual, queryable data about:

- **Where** the world is (cities, countries, regions, timezones, postcodes, airports)
- **What time** it is anywhere (with DST, half/quarter-hour zones, dateline crossings)
- **What holiday** is observed where and when (with country/region variance, computed + sourced)
- **What the climate** is like (NOAA GSOM normals)

Built on **Hono + Cloudflare Workers + D1 (SQLite)** with a strict 10-table schema, fully `zod`-validated OpenAPI 3.1.

### Why it exists

`dateandtime.live` (acquired/sunset in 2023) used to be a top-3K global site for time/holiday data. The traffic moved to `timeanddate.com` post-acquisition. This repo rebuilds the geo-temporal data layer from scratch — **open data only, no Timeanddate scraping** — so a new frontend can be built on top without license risk.

### Product positioning

The two real competitors are:

| Competitor | What they have | What we have | What we beat them on |
|---|---|---|---|
| **TimeandDate.com** (Pro API) | Closed, paywalled, scraped data | Open, free, sourced | Cost, license, transparency |
| **AbstractAPI / Calendarific** | 50+ holiday sources, paywalled | 1 source + 100% computed | Coverage, multilingual, structural integrity |

Our edge is **structural integrity + multilingual + open**. Timezone correctness is `Intl.DateTimeFormat`-backed (IANA in V8) — same engine as Chrome.

---

## 2. Coverage (today)

| Domain | Records | Source | Coverage |
|---|---|---|---|
| **Cities** | 170,253 | GeoNames cities15000 + Wikidata | 5,081 → 170K (M11.2 wikidata merge) |
| **Countries** | 250 | dr5hn + UN M.49 + UN names | 194 → 250 (territories) |
| **Regions / Subregions** | 6 / 22 | UN M.49 | Macros (Africa, Americas, …) |
| **Administrative regions** | 52,857 | GeoNames admin-1/2 + dr5hn | 5,308 level-1 + 47,549 level-2 |
| **Timezones** | 464 | IANA zoneinfo | All official + aliases |
| **Postcodes** | ~844K | GeoNames + national registries | 50+ countries |
| **Airports** | ~8K | OurAirports + IATA | Major + regional |
| **Translations** | 2.97M (19 langs) | Wikidata + native scripts | en, es, fr, de, zh, ja, ko, ru, ar, hi, pt, it, tr, nl, pl, sv, uk, he, fa, th |
| **Holidays (M14)** | 15,638 occurrences | Calendarific API (Tier D) | 190 countries × 2 years (2026-2027) |
| **Holidays (M14 enrichment)** | 1,827 occurrences | Hebcal + UN + computed | US/NL/IN/NZ/GB |
| **Climate (M11.8)** | ~88K | NOAA NCEI GSOM | Monthly normals (2010-2020) |

**Total D1 records**: ~1.3M (in a 10-table schema, fully normalized, single source of truth).

---

## 3. Feature inventory (45 endpoints, 9 domains)

### 3.1 Meta (3) — `src/routes/{health,status,docs}.ts`
- `GET /` — API root with link map
- `GET /api/v1/health` — DB stats + latency (used by monitoring)
- `GET /api/v1/status` — Worker version + uptime
- `GET /docs` — Swagger UI (OpenAPI 3.1)
- `GET /openapi.json` — OpenAPI spec

### 3.2 Cities (8) — `src/routes/cities*.ts`
- `GET /api/v1/cities/search` — FTS5 text search + geo + filter (limit ≤ 500)
- `GET /api/v1/cities` — list by country, capital, region, tier
- `GET /api/v1/cities/{id}` — single city by dr5hn id (joined: country, admin, timezone, translations, postcodes)
- `GET /api/v1/cities/near` — cities within radius (lat/lon/km)
- `GET /api/v1/cities/{id}/aliases` — historical/alternate names
- `GET /api/v1/cities/{id}/climate` — monthly NOAA climate normals
- `GET /api/v1/cities/{id}/postcodes` — postcodes for a city
- `GET /api/v1/cities/{id}/translations` — all translations
- `GET /api/v1/cities/{id}/translations/{lang}` — single translation
- `GET /api/v1/cities/{id}/airports` — airports near a city
- `GET /api/v1/cities/{id}/resources` — climate + nearby + schools (composite)

### 3.3 Countries (2) — `src/routes/countries.ts`
- `GET /api/v1/countries` — list (with `?lang=xx` for localized names)
- `GET /api/v1/countries/{cca2}` — single country detail (with localized names + cca3 + region + subregion)

### 3.4 Regions / States / Sub-regions (8) — `src/routes/{regions,states,subregions}.ts`
- `GET /api/v1/regions` — 6 macros
- `GET /api/v1/regions/{code}/subregions` — 22 sub-regions
- `GET /api/v1/subregions/{code}/countries` — countries in a sub-region
- `GET /api/v1/countries/{cca2}/admin1` (in `countries.ts`) — states/provinces
- `GET /api/v1/countries/{cca2}/admin2` — counties (with city counts)
- `GET /api/v1/admin1/{id}` — state detail
- `GET /api/v1/admin2/{id}` — county detail
- `GET /api/v1/countries/{cca2}/states` — alt path for admin1

### 3.5 Time (2) — `src/routes/time.ts`
- `GET /api/v1/time/now?city=NYC` — current local time in a city (uses `Intl.DateTimeFormat`)
- `GET /api/v1/time/convert?from=NYC&to=Tokyo&at=2026-08-03T15:00:00` — convert wall-clock time between cities

**Edge cases handled**: DST spring-forward, fall-back, half-hour (Asia/Kolkata +5:30), quarter-hour (Pacific/Chatham +12:45), date-line crossings (UTC-12 vs UTC+14), historic tz changes.

### 3.6 Translations (3) — `src/routes/translations.ts`
- `GET /api/v1/translations/search?q=tokyo&lang=ja` — search across 2.97M translations
- `GET /api/v1/cities/{id}/translations[/{lang}]` — nested in cities (above)
- Search returns: name + script + country code + language code + native script

### 3.7 Postcodes (2) — `src/routes/postcodes.ts`
- `GET /api/v1/postcodes/search?code=10001&country=US&exact=true` — search by code/country
- `GET /api/v1/postcodes/{id}` — postcode detail
- `GET /api/v1/cities/{id}/postcodes` — nested in cities (above)

### 3.8 Airports (2) — `src/routes/airports.ts`
- `GET /api/v1/airports/near?lat=X&lon=Y&radius=100` — within radius
- `GET /api/v1/cities/{id}/airports` — nested in cities (above)
- Includes IATA + ICAO + runway length + type

### 3.9 Holidays (13) — `src/routes/holidays.ts` ★
The crown jewel — built over M13-M14, 5 months of work.

- `GET /api/v1/filters` — global catalog of 36 filter codes
- `GET /api/v1/countries/{cca2}/filters` — **the variance endpoint** (US=22, NL=7, IN=17, GB=7, NZ=6)
- `GET /api/v1/holidays` — list with filters, date range, country, subdivision, mode (country/international/combined)
- `GET /api/v1/countries/{cca2}/holidays` — country shortcut
- `GET /api/v1/holidays/today` — widget: today's holidays
- `GET /api/v1/holidays/upcoming` — widget: next N days
- `GET /api/v1/holidays/{id}` — single occurrence detail
- `GET /api/v1/long-weekends` — SEO/legacy LW finder
- `GET /api/v1/countries/{cca2}/long-weekends/{year}` — **enhanced LW finder** (multi-day + PTO strategies + custom work schedules)
- `GET /api/v1/countries/{cca2}/pto-strategy/{year}` — **greedy year-PTO planner**
- `GET /api/v1/calendars/holidays.ics` — RFC 5545 ICS export (Apple/Google/Outlook)
- `POST /api/v1/feedback` — submit correction
- `POST /api/v1/feedback/{id}/vote` — upvote/downvote

**Data sources (M14 tiered model)**:
- **Tier A (official)**: gov.uk, gov.in, OPM (US), school calendars — **deferred** (see `docs/enrichment-roadmap.md`)
- **Tier B (community)**: Wikipedia, drikpanchang, astrosage, hebcal — partial
- **Tier C (regional)**: employment_nz, nager_date — partial
- **Tier D (open providers)**: calendarific_api — **single source for MVP**

**M14.5 long weekend algorithm** (`src/lib/longWeekend.ts`, 23 unit tests):
- Multi-day holidays (Diwali 5-day)
- Optional holidays (IN Restricted, UK Boxing Day, etc.)
- Subdivision filtering (e.g. only US-CA)
- Custom work schedules (mon-fri, sun-thu, fri-sat, sat-wed)
- PTO extension strategies (1-3 days before/after)
- Trip value scoring (0-100, season + duration + cluster + urgency)

### 3.10 Data Quality (6) — `src/routes/data-quality.ts`
- `GET /api/v1/data-quality` — run 10 live checks (integrity, freshness, completeness)
- `GET /api/v1/data-quality/issues` — list issues (paginated)
- `GET /api/v1/data-quality/issues/{id}` — issue detail
- `POST /api/v1/data-quality/issues/{id}/resolve` — mark resolved
- `GET /api/v1/data-quality/sources` — source registry (8 sources)
- `GET /api/v1/data-quality/imports` — import history

---

## 4. Data architecture

### 4.1 Schema (10 tables, fully normalized)

```
regions (6) ──── subregions (22) ──── countries (250)
                                          │
                                          ├──── administrative_regions (52,857) — admin-1 + admin-2
                                          │           │
                                          │           └──── cities (170,253)
                                          │                  │
                                          │                  ├──── place_names (aliases)
                                          │                  ├──── translations
                                          │                  ├──── postcodes (~844K)
                                          │                  └──── airports (~8K)
                                          │
                                          └──── country_time_zones ──→ time_zones (464)
                                                                       │
                                                                       └──── city_time_zones
```

Plus 6 M14 holiday tables:
- `holiday_concept` (~30 canonical holidays)
- `holiday_occurrence` (15,638 dates)
- `holiday_occurrence_filter` (15,638 × N filter codes)
- `holiday_filter` (36 filter codes)
- `holiday_source` (8+ sources)
- `holiday_feedback` (user-reported corrections)

Plus 3 enrichment tables (M11.5 US Census ACS):
- `city_attribute_source` (12 attribute tables joined by source + as_of_date)
- attribute tables: `census_acs_*`, `census_*`, `eurostat_*`, `census_india_*`, `climate_*`, `acs_*`

**Why 12 attribute tables?** Multi-source, multi-vintage data needs to be queryable by `city_id + source + as_of_date`. Joining the actual values into a wide table is wrong (source mixing, vintage collapsing). Wide-table patterns = source mixups = bad data.

### 4.2 Data sources (tier model)

| Tier | Examples | License | Scope | Use |
|---|---|---|---|---|
| **A — Official** | gov.uk, gov.in, OPM, school calendars | Public domain | National | Future (M15+) |
| **B — Community** | Wikipedia, drikpanchang, astrosage, hebcal | Various | Multilingual | Enrichment |
| **C — Regional** | employment_nz, nager_date | Various | Single country | Gaps |
| **D — Open providers** | calendarific_api, weatherapi | Paid (Calendarific free tier) | Global | **MVP single source** |

Rule: **higher tiers override lower**. Calendarific is the current floor; everything else is additive.

### 4.3 D1 (SQLite) quirks (the gotchas)

- **100-var per prepared statement limit** (not 999 like standard SQLite)
  - 4-5 cols: 20+ rows
  - 6 cols: 16 rows
  - 7 cols: 14 rows
  - 9 cols: 11 rows
  - 10 cols: 9-10 rows
  - 11 cols: 9 rows (e.g. `holiday_occurrence`)
  - 12 cols: 8 rows
  - 14 cols: 7 rows
  - 15 cols: 4-6 rows
- **D1 HTTP API 100KB per-statement limit** (not 100MB like Cloudflare KV) → split large SQL into batches
- **No DateTime type** → use ISO 8601 strings + `substr()` for year extraction
- **No FULL OUTER JOIN** → use UNION + COALESCE patterns
- **No native JSON ops** → use `json_extract()` from v2 API (limited)
- **Wrangler 3 quirks** (not 4): `wrangler dev` URL is `localhost:8787`, not 8788

### 4.4 Internationalization

- **Field naming**: `name`, `asciiName`, `native` (always populated), `shortName`, `searchName`
- **Translations**: separate `translations` table keyed by `entity_id + entity_type + language + script`
- **Search**: `place_names_fts` FTS5 index supports native script + romanized
- **Languages supported** (19): en, es, fr, de, zh, ja, ko, ru, ar, hi, pt, it, tr, nl, pl, sv, uk, he, fa, th

---

## 5. Tech stack

| Layer | Choice | Why |
|---|---|---|
| **Runtime** | Cloudflare Workers (V8 isolate) | Edge, low latency, generous free tier |
| **Framework** | Hono | Tiny, OpenAPI-native, fast cold start |
| **API spec** | @hono/zod-openapi | One source of truth (zod schemas → OpenAPI 3.1) |
| **DB** | Cloudflare D1 (SQLite) | 0-ops, edge-replicated, 5GB free |
| **Validation** | Zod | TS-native, runtime + compile-time |
| **Tests** | Vitest | 37 test files, 644+ passing, ~30s full suite |
| **Deploy** | Wrangler | First-party, GitHub Actions integration |
| **Lint** | ESLint + Prettier | Standard |
| **TS** | strict mode | Always |

No ORM. No client SDK. SQL strings are written by hand with `?` bindings. This is intentional — D1's tight limits and specific semantics make an ORM fight the platform.

---

## 6. Use cases (what the API enables)

### 6.1 World time widget
```js
// "What time is it in Tokyo?"
const r = await fetch('https://api/time/now?city=Tokyo');
// → "Tuesday, August 5, 2026, 3:42 AM JST"
```
**Powered by**: `time.ts` + `Intl.DateTimeFormat` (IANA tz database in V8).

### 6.2 Long weekend vacation planner
```js
// "Show me long weekends in India 2026, considering 5 PTO days"
const r = await fetch('https://api/countries/IN/pto-strategy/2026?available_pto=5');
// → 13 strategies, 94 days off total
```
**Powered by**: `longWeekend.ts` (computeLongWeekends + planYearPTO).

### 6.3 Holiday calendar export
```js
// "Add all Indian holidays 2026 to my Google Calendar"
const r = await fetch('https://api/calendars/holidays.ics?country=IN&year=2026');
// → RFC 5545 ICS file, importable
```
**Powered by**: `holidays.ts` (ICS export).

### 6.4 City detail page
```js
// "Tell me everything about Mumbai"
const r = await fetch('https://api/cities/122795?lang=hi');
// → name (Hindi), population, admin, timezone, climate, airports, postcodes, translations
```
**Powered by**: 6 joined tables + CLDR translations.

### 6.5 Proximity search
```js
// "Cities within 500km of Paris"
const r = await fetch('https://api/cities?lat=48.85&lon=2.35&radius=500');
// → ~120 cities sorted by distance
```
**Powered by**: `cities/near` with PostGIS-equivalent haversine in SQL.

### 6.6 Data quality monitoring
```js
// "Are there any duplicate cities?"
const r = await fetch('https://api/data-quality');
// → 10 checks, 1 currently failing (43 dupes, info)
```
**Powered by**: 10 SQL checks in `data-quality.ts` (run on demand, cached 5min).

### 6.7 SEO landing pages
```js
// "Long weekends in Brazil 2026" — for the Brazil landing page
const r = await fetch('https://api/countries/BR/long-weekends/2026');
// → 30 LWs, used to generate 30 unique SEO pages
```
**Powered by**: `long-weekends/{year}`. Same data powers /holidays/{id}, /countries/{cca2}/holidays, etc.

---

## 7. Non-goals

What this API is **NOT**:

- ❌ **Not a timezone-conversion SaaS** — we don't render calendars, schedule meetings, or compete with `timezone.io` (yet)
- ❌ **Not a horoscope/astrology API** — religious observances are documented but not interpreted
- ❌ **Not a flight booking engine** — Skyscanner/Booking are deep-link partners
- ❌ **Not a CMS** — no content management, no editorial, no user accounts (yet)
- ❌ **Not a B2B SaaS** — free, no rate limits beyond Cloudflare's defaults
- ❌ **Not a private API** — public, free, undocumented competition encouraged

---

## 8. Operating constraints

- **Free tier only** — Cloudflare Workers (100K req/day free), D1 (5GB free), R2 (10GB free)
- **Single developer** — ~1 person-week per milestone, not enterprise scale
- **Open data only** — no Timeanddate scraping, no Calendarific scraping beyond rate limits
- **No vendor lock-in** — D1 schema is plain SQLite (Hono is portable)
- **CORS-everywhere** — every endpoint has `Access-Control-Allow-Origin: <echoed>` for browser usage
- **Idempotent reads** — all GETs are safe to retry, no side effects

---

## 9. Milestones (M0 → M14.6)

| M | Theme | Endpoints added | Data added | Status |
|---|---|---|---|---|
| **M0** | Bootstrap | 3 (meta) | — | ✓ |
| **M11.1** | Time + tz | 2 | 464 tz | ✓ |
| **M11.2** | Wikidata merge | 4 | +165K cities | ✓ |
| **M11.2.x** | Wikidata P-codes | 1 | +50K altnames | ✓ |
| **M11.3** | CLDR translations | 3 | 2.97M translations | ✓ |
| **M11.4** | UN WPP demographics | 2 | — | ✓ |
| **M11.5** | US Census ACS | 5 | 12 attribute tables | ✓ |
| **M11.6** | Eurostat LAU | 2 | 5K+ EU admin-2 | ✓ |
| **M11.7** | Census India | 1 | 4K+ cities | ✓ |
| **M11.8** | NOAA NCEI GSOM | 2 | 88K climate normals | ✓ |
| **M12** | Global admin-2 | 4 | 47,549 admin-2 (dr5hn) | ✓ |
| **M13** | Holidays MVP | 10 (US + NL) | 190 occurrences | ✓ |
| **M14** | Holidays enrichment | +5 (5 countries) | 1,827 occurrences (Hebcal + UN) | ✓ |
| **M14.5** | Calendarific | +1 (single source) | 15,638 occurrences × 2,364 concepts | ✓ |
| **M14.6** | Trip planner UI | (UI only, parked) | preview/ + 23 tests | ✓ |
| **M15+** | Weather self-host | planned | Open-Meteo + NOAA | (parked) |
| **M16+** | Tier A holidays | planned | gov.in, gov.uk, OPM | (parked) |
| **M17+** | User accounts | planned | profile + saved trips | (parked) |

---

## 10. Test plan

- **37 test files**, ~644 passing cases
- **Approach**: end-to-end via Worker (no mocking) — tests hit `https://dt-api-v2-dev.nsura2029.workers.dev`
- **Run**: `TEST_API_URL=... npx vitest run`
- **Coverage targets**: 100% of route handlers, 80% of lib functions
- **Quality gates**:
  - Migrations applied via wrangler (no manual SQL)
  - New endpoints must have at least 1 test
  - Breaking changes go to `/api/v2/`

---

## 11. Deployment

- **Production**: `wrangler deploy` → `dt-api-v2` Worker (prod env, real D1)
- **Dev**: `wrangler deploy --env dev` → `dt-api-v2-dev` Worker (same D1, debug logging, dev origins)
- **Local**: `wrangler dev --persist` → `http://localhost:8787`
- **CI**: GitHub Actions deploys develop → dev env on push
- **Versioning**: Worker versions tracked via Version IDs (e.g. `5cee24af-6c8b-4eee-b15e-99c81f0dfd53`)

---

## 12. Success metrics

What "done" looks like for this product:

| Metric | Target | Current |
|---|---|---|
| **Uptime** | 99.9% | TBD (Cloudflare SLA) |
| **API latency (p50)** | <100ms | TBD |
| **Coverage** | 200+ countries × 2 years holidays | 190 × 2 ✓ |
| **Multilingual** | 20+ languages | 19 ✓ |
| **Test pass rate** | 100% | 644/648 (4 pre-existing) |
| **Endpoint count** | 50+ | 45 |
| **Data volume** | 1.5M+ records | ~1.3M ✓ |
| **Open source** | Yes | Yes (Hono + D1, both permissively licensed) |

---

## 13. Roadmap (next 3 milestones)

### M15 — Weather self-hosted (Q3 2026)
- Open-Meteo Docker self-host (~$10/mo on Hetzner)
- New schema: `city_climate_normals` + `city_forecast`
- 3 new endpoints: climate, forecast, climate filter
- See `docs/ROADMAP-weather-data.md`

### M16 — Tier A holiday sources (Q4 2026)
- gov.uk (England + Scotland + N.Ireland) — JSON, public domain
- gov.in (DoPT + 28 states) — annual gazette, public domain
- OPM (US federal holidays) — 5 U.S.C. § 6103
- US school calendars (NCES — 58K schools)
- See `docs/enrichment-roadmap.md`

### M17 — User accounts (Q1 2027)
- Email + password (Cloudflare Access)
- Saved trips (favorites, custom LW plans)
- Personalized year calendar
- Trip reminders (email + push)

---

## 14. Glossary

- **D1** — Cloudflare's managed SQLite. Tight limits (100 vars/stmt, 100KB/stmt via HTTP).
- **dr5hn** — `dehiyh-naeg`, our internal short code for the dataset (don't ask, internal joke)
- **ISO 3166-1 alpha-2** — 2-letter country codes (US, GB, IN, …)
- **ISO 3166-2** — subdivision codes (US-CA, GB-ENG, IN-MH, …)
- **IANA** — Internet Assigned Numbers Authority. Owns the tz database.
- **Nager.Date** — Open holiday API (90+ countries, MIT-style license)
- **Calendarific** — Paid holiday API (free tier 1K calls/day)
- **Hebcal** — Jewish holiday + calendar API (REST + iCal)
- **UN M.49** — UN standard country/region codes (3-digit, e.g. 840 = US)
- **CLDR** — Unicode Common Locale Data Repository (used for translated country names)
- **NOAA NCEI GSOM** — Global Summary of the Month (15K weather stations, monthly)
- **JW** — `Jerusalem Writer`, no, just joking. JW = Joint Week.

---

## 15. See also

- **`README.md`** — project overview, getting started
- **`CHANGELOG.md`** — version history
- **`STATUS.md`** — current sprint status
- **`NEXT-TASKS.md`** — Tier 1-4 recommended next prompts
- **`KNOWN_ISSUES.md`** — known bugs with repro steps
- **`docs/AGENTS.md`** — agent docs conventions
- **`docs/api/README.md`** — full API reference (45 endpoints)
- **`docs/references/`** — deep-dive docs (data platform journey, schema evolution, sources)
- **`docs/m14.6-trip-planner/USE_CASES.md`** — 35+ long weekend planner use cases
- **`docs/ROADMAP-weather-data.md`** — M15 weather roadmap
- **`docs/enrichment-roadmap.md`** — M16 Tier A holiday sources
- **`docs/postman/dt-api-v2.postman_collection.json`** — Postman collection (all 45 endpoints)
- **`preview/longweekend.html`** — M14.5 long weekend calendar preview
- **`preview/trip-planner.html`** — M14.6 trip planner (parked for UI)
