# Data Platform Journey — M0 → M14

> One-stop narrative of how the dateandtime-api-v2 data platform evolved. Read this first to understand the "why" behind every table and column.

## The big picture

We started with one question: **"what time is it in city X?"** and ended up with a global data platform covering 170,253 cities, 250 countries, 462 timezones, 19-language translations, US Census demographics, real climate data, and a worldwide holiday calendar.

The journey: **10 milestones of cities/timezone work → 9 milestones of country/city attribute enrichment → 4 milestones of holidays.**

## Phase 1: Core timezone + cities (M0-M10)

**Goal:** Accurate city-to-timezone lookup with confidence scoring.

### M0 — Repo scaffold
- Hono + Cloudflare D1 + Zod
- `cities`, `countries`, `timezones`, `postcodes` initial tables
- OpenAPI spec, Swagger UI

### M1 — Global timezone polygon
- 3,018 cities verified against IANA timezone boundaries
- Each city gets `tz_id` (IANA timezone) and `polygon` (multi-polygon boundary)
- Created `timezone_polygons` table for high-accuracy boundary lookups

### M2 — Schema enrichment
- Added 7 columns, 4 tables: `subregions`, `admin-1`, alternative names
- 152,970 cities from dr5hn data (US-focused)

### M3 — Cities enrichment
- 152,970 cities with population, alt_names, place_names
- Search ranking with `search_name` field

### M4 — Postcodes
- 844,248 postcodes across all countries
- New `postcodes` table

### M5 — Translations
- 2,965,561 city name translations in 19 languages
- CLDR + GeoNames sources

### M6 — API contract upgrade
- State filter, language search, ranking
- New query params for the main /cities endpoint

### M7 — New endpoints
- `GET /cities/{id}/postcodes`
- `GET /cities/{id}/airports`

### M8 — Data quality metadata
- 10 data quality checks
- `data_quality_checks`, `data_quality_issues` tables

### M9 — Documentation
- 3 spec docs (master data architecture, edge case audit, plan)
- Swagger UI fully wired

### M10 — Final regression
- 76 tests, 14 groups
- F1-F14 regression suite

### M10+ — Edge cases (post-M10 hardening)
- 46 tests E1-E14 for tricky data scenarios
- 14 tests S1-S5 for "did you mean" suggestions
- Doc-update framework: STATUS.md, CHANGELOG.md, sync scripts

**Result of Phase 1:** 152,970 cities, 250 countries, 462 timezones, 844K postcodes, 19-language support, 138 tests passing.

## Phase 2: Data platform foundation (M11.0)

**Goal:** Move from "single source" to "multi-source" with provenance, staging, and merge.

### M11.0 — Data platform foundation
- `source_registry` (10+ sources, tier A-F, license tracking)
- `source_releases` (versioned, SHA-256, R2 raw artifacts)
- `cities_staging` (69,561 GeoNames rows ready to merge)
- 5 new API endpoints (`/sources`, `/cities-staging`, etc.)
- Promote script ready (shadow mode for first migration)

**Key insight:** The dr5hn data is US-focused. We needed global coverage. GeoNames is the de facto standard. But just `INSERT` from GeoNames would conflict with dr5hn. We needed a proper merge.

## Phase 3: Layer merge + city enrichment (M11.1-M11.7)

**Goal:** Bring in 17K GeoNames-only cities + layer in 9 source attributes without losing dr5hn quality.

### M11.1 — Layer merge (dr5hn + GeoNames)
- 11 new cities columns + `city_layer_log` audit table
- `intelligent_merge.py`: 3-tier strategy (exact 1km, fuzzy 10km, historical_alias)
- 69,563 statements applied in 348 chunks (~12 min)
- 170,253 cities total (dr5hn 152,970 + GeoNames-only 17,283)
- 67,999 cities carry the M11.1 layer fields
- 15 new tests, all pass

**Result of M11.1:** Global coverage. 17K cities (mostly non-US) gained.

### M11.1.5 — GeoNames altNames
- 30 historical city renamings (Bombay→Mumbai, Edo→Tokyo, Peking→Beijing)
- 767K alt names indexed for search

### M11.2 — Wikidata (Q-ids + wikiUrl)
- 148,331 cities matched to Wikidata Q-ids
- Wikipedia URLs now in /cities/{id} response

### M11.2.5 — Wikidata alt labels
- 148K alt labels added to search ranking
- Improves "Tokyo Tower" matches in different languages

### M11.2.6 — Wikidata descriptions
- 148K short descriptions (e.g., "capital of Japan")
- Used in /cities/{id} response

### M11.2.7 — Wikidata Q-id backfill
- Closed the gap: 100% of Q-id cities now have descriptions
- Found 226K extra labels in process

### M11.2.8 — Wikidata P-codes (instance-of, country, admin, timezone)
- 5,000 top cities with P31, P17, P131, P421 codes
- 100% instance_of + country_qid, 99.9% admin_qid, 42% timezone_qid

### M11.3 — Unicode CLDR
- 5,000 country localized names
- 19 languages, script detection

### M11.4 — World Bank Indicators
- 216 country populations (2024)
- Country-level economic indicators

### M11.5 — US Census Bureau
- 14,459 US cities with state + county + FIPS
- 2010-2023 vintage tracking

### M11.5.1 — ACS 5-Year Demographics (Sex by Age, Income, Education, Tenure, Transport)
- 14,450 US cities with full demographic profile
- B01001 (Sex by Age), B19013 (Income), B15003 (Education), B25003 (Tenure), B08301 (Transport)
- 3-way LEFT JOIN for fast city detail lookup

### M11.6 — Eurostat (LAU + URAU)
- 41,571 EU cities with LAU attributes
- 597 EU cities with URAU City-vs-FUA data
- 2-pass parser: FUAs first, then LAUs at 10 writes/s

### M11.7 — Census of India 2011
- 963 Indian cities with population, state, district
- PCA11-UA-0000.xlsx as source (2011 is still latest official)

### M11.8 — Real climate (NCEI GSOM 2020-2023)
- 10,559 cities with real monthly climate (TMAX, TMIN, PRCP)
- 1,869 NCEI stations matched via 1-degree grid
- Median city-to-station distance: 20 km
- Lat-based model fallback for cities without NCEI data

**Result of Phase 3:** 170,253 cities, 14 source attributes per city, 4 new country attributes. 405 tests passing.

## Phase 4: Admin-2 (M12)

**Goal:** Add counties, districts, communes — the "where" below country.

### M12 — Global admin-2
- 47,549 admin-2 regions across 189 countries
- 56,293 cities mapped (33% of 170K)
- Source: GeoNames admin2Codes.txt (free, 2.4MB)
- New `/cities/{id}.subRegion` field
- New endpoints: `/countries/{cca2}/admin2`, `/admin2/{id}`

**Why it matters:** US users want "Pasco County, Florida" not just "Florida". Indian users want "Mumbai Suburban, Maharashtra". This unlocks that.

## Phase 5: Holidays (M13-M14)

**Goal:** Worldwide holiday calendar with per-country filter variance.

### M13 — Holidays MVP
- 10 endpoints, 190 occurrences (US=168, NL=22)
- 36 filter codes
- **Variance endpoint** (US=18 filters, NL=4) — the spec's key insight
- Sources: OpenHolidays (NL) + Nager.Date (US)
- Migration 156: 8 new tables (filter, concept, occurrence, source, etc.)

### M14 — Holiday enrichment (Tier 1 + Tier 2 + India)
- **Schema migration 157:** worldwide flag, category, origin, holiday_occurrence_state, holiday_un_day
- **Tier 1 — Computed:** US federal (5 U.S.C. § 6103), Easter-related (Computus), seasons (Meeus), DST changes, US observances, GB bank holidays, IN national holidays
- **Tier 2 — Hebcal:** 18 Jewish holidays per country (Yom Kippur, Passover, etc.)
- **Tier 2 — UN:** 178 international days (International Women's Day, etc.)
- 1,602 country-specific + 225 worldwide = 1,827 holiday occurrences for 2026
- US: 410, NL: 295, IN: 293, NZ: 312, GB: 292
- 21 new tests, all green
- Docs: 5 research files in `docs/references/holidays/`

**Result of Phase 5:** Worldwide holiday calendar with rich filter system.

## Total picture (post-M14)

| Metric | Value |
|---|---:|
| Cities | 170,253 |
| Countries | 250 |
| IANA timezones | 462 |
| Admin-2 regions | 47,549 |
| Postcodes | 844,248 |
| City translations | 2,965,561 (19 langs) |
| Alt names (search) | 767K |
| Wikidata descriptions | 148,331 |
| Wikidata P-codes (top 5K) | 5,000 |
| US Census / ACS cities | 14,450 |
| EU LAU cities | 41,571 |
| Indian Census cities | 963 |
| NCEI real climate cities | 10,559 |
| Holidays (2026, 5 countries) | 1,827 |
| Sources registered | 14+ |
| API endpoints | 41 |
| Tests passing | 644 / 648 |
| Migrations | 1-157 |

## What we deferred (post-MVP)

- ERA5 climate for 19K cities without NCEI stations
- Admin-2 population/area/coords (needs Wikidata SPARQL or GADM)
- Holidays: 10 deferred endpoints (subdivision, business-day calc, CSV, etc.)
- Holidays: Phase 7 worldwide onboarding (UK, AU, NZ already done; need CA, IN, DE, FR, etc.)
- Calendarific/Holiday API integration (paid)

## Key learnings

1. **D1 100-var limit is real.** Every multi-row INSERT needs `BATCH_SIZE = floor(99 / cols)`.
2. **Layer merge beats source replacement.** dr5hn + GeoNames layer = best of both, not worse than either.
3. **Computed rules > scraping.** US federal holidays from 5 U.S.C. § 6103 + nth-weekday formula is more reliable than scraping OPM.
4. **Hebcal is gold for Jewish holidays.** Free, MIT-licensed, 150 items/year. Add per-country, dedupe by date.
5. **UN days = UN.org tier B.** Don't scrape; we have 178 public knowledge days.
6. **Variance endpoint is the spec's key insight.** US=18 filters, NL=4 — same data, different applicability.
7. **Idempotency is hard in D1.** `IS ?` with NULL parameters is broken. Use explicit `IS NULL` / `IS NOT NULL` clauses.
