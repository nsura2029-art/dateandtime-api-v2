# TODO

## Active

None right now — the holiday enrichment engine is done and the data is loaded for 5 countries (US, NL, IN, NZ, GB).

## Next-up (priority order)

1. **Holidays Phase 7: Worldwide onboarding** (2-3 days) — Recommended next
   - Add CA, AU, FR, DE, IT, ES, IE, NO, SE, DK, FI
   - Pattern: each gets a computed/adapter loader (like GB bank holidays)
   - High SEO value: per-country holiday pages

2. **Time-calc endpoint (DST + date-line math)** (1-2 days)
   - `GET /api/v1/time/calc?from=America/New_York&to=Asia/Tokyo&datetime=...`
   - Foundation for the "World time" / meeting planner features

3. **ERA5 climate for 19K cities without NCEI stations** (3-5 days)
   - 10,559 cities have real NCEI data, 19K don't
   - User said "weather and climate after MVP" — check if MVP is shipped

4. **Holidays: 10 deferred endpoints** (3-5 days) per `reports/holidays-deferred-work.md`
   - `GET /holidays/{id}/states` (subdivision scope)
   - `GET /holidays/concepts` (list concept IDs)
   - `GET /business-day/calc?country=US&date=2026-01-01&count=5`
   - `GET /calendars/holidays.csv`
   - `GET /holidays/sources/{id}` (source lineage)
   - `GET /holidays/{id}/corrections` (feedback history)
   - `POST /calendars/holidays.subscribe` (webhook)
   - `GET /holidays/today?lat=X&lon=Y` (location-based)
   - `GET /holidays/count/{country}` (for SEO meta)
   - `GET /admin/holidays/sources/{id}/reconcile`

## Future (post-MVP)

| Item | Estimate | Why deferred |
|---|---:|---|
| M11.6.1: URAU GeoJSON expansion | 2-3 days | Need GISCO vector download |
| M11.7.2: Full PCA town-level data (India) | 1 week | DCHB URLs 404 |
| Admin-2 population/area/coords | 1 week | Needs Wikidata SPARQL or GADM |
| Holidays Phase 6: Admin/review UI | 1-2 days | Source assertion review queue |
| Polygon-based confidence (E4 multi-TZ) | 1 week | Needs polygon data per city |
| "World time" feature | TBD | Per product PRD (meeting planner) |
| Production deployment | when ready | User said "not ready for production" |
| Calendarific / Holiday API integration | TBD | Paid, post-revenue |
| Long-weekend finder (per user brainstorm) | 1-2 days | SEO win, 80K searches/mo |

## Done (M0-M14)

### M11.7+ / M11.8 (real climate)

- [x] M11.8: NCEI GSOM real climate (10,559 cities) — Migration 154
- [x] D1 100-var limit reference table
- [x] Meeus astronomical algorithm (seasons accurate to 1 day)
- [x] M11.5.1 expand 1: ACS Income + Education
- [x] M11.5.1 expand 2: ACS Tenure + Transport

### M11.2.x (Wikidata family)

- [x] M11.2.7: Wikidata Q-id backfill (100% descriptions)
- [x] M11.2.8: Wikidata P-codes for top 5K cities (P31, P17, P131, P421)

### M12 (Global admin-2)

- [x] 47,549 admin-2 regions across 189 countries
- [x] 56,293 cities mapped to admin-2
- [x] 2 new endpoints: `/countries/{cca2}/admin2`, `/admin2/{id}`
- [x] `subRegion` field in /cities/{id} response

### M13 (Holidays MVP)

- [x] 10 endpoints, 190 occurrences (US=168, NL=22)
- [x] 36 filter codes
- [x] **Variance endpoint** (US=18, NL=4) — the spec's key insight
- [x] OpenHolidays (NL) + Nager.Date (US) loaders

### M14 (Holiday enrichment — Tier 1 + Tier 2 + India + GB)

- [x] Migration 157: worldwide flag, category, origin, holiday_occurrence_state, holiday_un_day
- [x] Tier 1 computed: US federal, Easter, seasons, DST, US observances, GB bank holidays, IN national
- [x] Tier 2 Hebcal: 18 Jewish holidays × 5 countries
- [x] Tier 2 UN days: 178 international days
- [x] NZ loaded from Employment New Zealand (Tier A official)
- [x] 21 new tests, all green
- [x] 5 holiday research docs in `docs/references/holidays/`
- [x] 5 new reference docs in `docs/references/` (data-platform-journey, data-sources-master, schema-evolution, api-endpoints, timezone-architecture, regions-countries-cities, data-enrichment-engine)

### M11.0-M11.7 (Data platform foundation + enrichment)

- [x] M11.0: Source registry, source_releases, cities_staging, 5 new endpoints, R2 raw artifacts
- [x] M11.1: Layer merge (dr5hn + GeoNames) — 17,283 new cities
- [x] M11.1.5: GeoNames altNames (30 historical renamings)
- [x] M11.2: Wikidata (148,331 cities)
- [x] M11.2.5: Wikidata alt labels
- [x] M11.2.6: Wikidata descriptions
- [x] M11.3: Unicode CLDR (5,000 country names × 19 langs)
- [x] M11.4: World Bank (216 country populations)
- [x] M11.5: US Census (14,459 cities)
- [x] M11.5.1: ACS Sex by Age
- [x] M11.6: Eurostat LAU (41,571 EU cities) + URAU (597)
- [x] M11.7: Census of India 2011 (963 cities)

### M0-M10+ (Core timezone + cities)

- [x] M0: Repo scaffold (Hono + D1 + Zod)
- [x] M1: Global timezone polygon (3,018 cities verified)
- [x] M2: Schema enrichment (7 cols, 4 tables)
- [x] M3: Cities enrichment (population, alt_names, place_names)
- [x] M4: Postcodes (844,248 rows)
- [x] M5: Translations (2,965,561 rows, 19 langs)
- [x] M6: API contract upgrade (state filter, lang search, ranking)
- [x] M7: New endpoints (postcodes, airports)
- [x] M8: Data quality metadata
- [x] M9: Documentation (3 spec docs + Swagger)
- [x] M10: Final regression (76 tests, 14 groups)
- [x] M10+: Edge cases (46 tests E1-E14) + suggestions (14 tests S1-S5)
- [x] Doc framework: STATUS.md, CHANGELOG.md, sync-status.sh, pre-merge-to-develop.sh
