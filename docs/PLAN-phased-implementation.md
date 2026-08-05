# Phased Implementation Plan

**Source spec:** `docs/SPEC-master-data-architecture.md`
**Total scope:** ~3 months of work for one developer
**Approach:** 5 phases, each independently deployable, each verified end-to-end

---

## Phase overview

| Phase | Title | Effort | Goal | Verification |
|---|---|---|---|---|
| **1** | DB Cleanup + Rebuild | 5-7 days | Replace GeoNames with dr5hn (152,970 cities), IANA timezones, regions + subregions + states | curl returns correct counts |
| **2** | Search Infrastructure | 7-10 days | `place_names` table, search normalization, M2M tables, dedup logic | 17 functional test cases pass |
| **3** | API Endpoints + Postman | 5-7 days | All region/country/state/city/search endpoints, full Swagger UI, Postman collection | All endpoints work in Postman |
| **4** | US-State Gate + DST/IDL | 3-5 days | Coming-soon redirect, DST transitions, IDL, half/quarter-hour zones | All edge case tests pass |
| **5** | User Education Content | 5-7 days (UI repo) | 10-15 SEO-optimized articles in UI repo | Articles live + ranking |

**Total: 25-35 days** (1.5-2 months for one focused developer)

---

## Phase 1: DB Cleanup + Rebuild (5-7 days)

**Goal:** Drop all current data, rebuild with clean schema from dr5hn + IANA.

### Day 1: Schema + drops
- Migration 100: DROP all current tables (cities, countries, timezones, onthisday, city_aliases)
- Migration 101: CREATE new tables (regions, subregions, countries, administrative_regions, cities, place_names, time_zones, city_time_zones, country_time_zones, data_sources, import_history, place_redirects)
- **DESTRUCTIVE** — save D1 backup first

### Day 2: Seed regions + subregions + countries
- seed/regions.py: 6 rows from dr5hn
- seed/subregions.py: 22 rows from dr5hn
- seed/countries.py: 250 rows from dr5hn with FK to region + subregion

### Day 3: Seed administrative_regions
- seed/administrative_regions.py: 5,308 rows from dr5hn (states + provinces + counties)

### Day 4: Seed time_zones
- seed/time_zones.py: ~450 rows from IANA tzdb-2026c (zone1970.tab + backward aliases)
- Includes: id, canonical_id (NULL if canonical), region, subregion, current_offset, etc.

### Day 5-6: Seed cities
- seed/cities.py: 152,970 rows from dr5hn countries+states+cities.json
- Big file (46MB), batched inserts, FK resolution
- 4-6 hours of compute

### Day 7: Verify + deploy
- All 5 health counts: regions=6, subregions=22, countries=250, regions=5,308, cities=152,970, timezones=~450
- Re-deploy dev Worker
- User pulls + verifies

**Deliverable:** A clean D1 with 250 countries, 5,308 regions, 152,970 cities, ~450 timezones, all from authoritative sources.

---

## Phase 2: Search Infrastructure (7-10 days)

**Goal:** Make search work — same name in multiple countries, fuzzy matching, diacritic-insensitive, etc.

### Day 1-2: place_names table + seed
- Migration 102: CREATE place_names
- seed/place_names.py: populate from dr5hn (alt names per city)
  - At least 3 languages per major city
  - Includes: official, ascii, local, transliteration, abbreviation
  - Pre-compute normalized_name (lowercase + diacritics removed)
- Test data: 500K+ rows

### Day 3: Search normalization
- src/lib/search-normalize.ts:
  - `normalize(input: string): string` — NFKD, lowercase, strip diacritics
  - `transliterate(input: string, targetScript: string): string` — for non-Latin
  - Unit tests covering all edge cases

### Day 4: Dedup logic
- src/lib/dedup.ts:
  - `dedupBySource(cities: City[]): City[]` — group by source_id, keep canonical
  - `dedupByProximity(cities: City[]): City[]` — group by coord ± 0.01° + country + admin
  - `canonicalize(name: string, country: string, state: string): string` — return canonical place ID
- Unit tests

### Day 5-7: Search endpoint
- src/routes/search.ts: `GET /api/v1/search?q=...&country=...&state=...&type=...`
  - Use FTS5 on `place_names.normalized_name`
  - Support: exact, prefix, alternate-name, fuzzy
  - Return: city, state, country, code, coords, pop, place_type, iana_tz, current_utc_offset
  - With full Swagger UI + 17 test cases (from spec)

### Day 8-10: Tests
- Duplicate names (Springfield → 30+ results)
- Multiple scripts (東京 / Tokyo / Токио)
- Diacritics (München / Munich)
- Historical (Bombay → Mumbai, Peking → Beijing)
- Misspellings (Munic → Munich)
- Country/state filter (Hyderabad IN vs PK)
- Invalid input
- Pagination

**Deliverable:** `GET /api/v1/search` works for all 17 spec test cases.

---

## Phase 3: API Endpoints + Postman (5-7 days)

**Goal:** All the region/subregion/country/state/city endpoints from the manifest, with Swagger UI + Postman collection.

### Day 1-2: Region + subregion endpoints
- `GET /api/v1/regions` — list 6 regions
- `GET /api/v1/regions/:code/subregions` — list sub-regions
- `GET /api/v1/subregions/:code/countries` — list countries
- Full Swagger UI
- Unit tests

### Day 3-4: Country + state endpoints
- `GET /api/v1/countries/:cca2` — single country
- `GET /api/v1/countries/:cca2/states` — list states
- `GET /api/v1/countries/:cca2/cities` — list cities
- `GET /api/v1/states/:id` — single state
- Full Swagger UI
- Unit tests

### Day 5: City endpoints
- `GET /api/v1/cities` — list with filter (region, subregion, country, state, search)
- `GET /api/v1/cities/:id` — single city with FULL live data (Current Time info card fields)
- `GET /api/v1/cities/near` — proximity search
- `GET /api/v1/cities/:id/climate` — climate data
- `GET /api/v1/cities/:id/aliases` — historical names
- Full Swagger UI
- Unit tests

### Day 6-7: Postman collection
- scripts/extract-postman.ts: reads openapi.json → generates Postman v2.1.0 JSON
- Includes: all endpoints, example requests, test scripts, env vars
- docs/api/dateandtime-api-v2.postman_collection.json (committed)
- CI: validate Postman collection matches OpenAPI spec

**Deliverable:** All API endpoints work, documented in Swagger UI + Postman.

---

## Phase 4: US-State Gate + DST/IDL (3-5 days)

**Goal:** Coming-soon redirect + handle all timezone edge cases.

### Day 1: US-state middleware
- src/middleware/us-state-gate.ts:
  - US_STATES_AND_DC = Set of 51 codes
  - Redirect non-US-state cities to /coming-soon
- Tests: PR/GU/VI/AS/MP all redirect, all 50 states + DC pass

### Day 2: DST transitions
- Test: spring forward (2:00 AM → 3:00 AM) — 2:30 AM doesn't exist
- Test: fall back (2:00 AM → 1:00 AM) — 1:30 AM occurs twice
- Implementation: use Temporal API or zoneinfo (Python equivalent in JS via @internationalized/date)

### Day 3: International Date Line
- Test: UTC-12 (Baker Island) and UTC+14 (Kiribati) on the same UTC timestamp
- Same date different days handling

### Day 4: Half/quarter-hour zones
- Test: Asia/Kolkata (UTC+05:30), Asia/Kathmandu (UTC+05:45), Pacific/Chatham (UTC+12:45)
- Verify offset calculation

### Day 5: Integration tests
- End-to-end test suite for all edge cases
- Run in CI

**Deliverable:** All timezone edge cases handled correctly, US-state gate works.

---

## Phase 5: User Education Content (5-7 days, separate UI repo)

**Goal:** 10-15 SEO-optimized articles in the UI repo.

### Day 1-2: Content strategy
- Finalize 10 article topics (from spec)
- SEO keyword research for each
- Outline each article (1,500-3,000 words)

### Day 3-5: Write articles
- 2-3 articles per day
- 10 articles total
- Include: live city/timezone data from API
- Internal links to API endpoints

### Day 6-7: Publish + measure
- Deploy articles
- Submit sitemap to Google
- Setup Search Console
- Initial ranking check

**Deliverable:** 10 articles live, ranking for target keywords.

---

## Dependencies between phases

```
Phase 1 (DB rebuild) ──┐
                       ├──> Phase 2 (Search) ──┐
                       │                        ├──> Phase 4 (US gate + edge cases) ──> Phase 5 (Content)
                       │                        │
                       └──> Phase 3 (Endpoints + Postman) ──┘
```

- **Phase 1 must come first** (foundation)
- **Phase 2 and 3 can run in parallel** after Phase 1
- **Phase 4 needs Phase 2 + 3 complete** (depends on search + endpoints)
- **Phase 5 can start after Phase 3** (needs API working to embed in articles)

---

## What we can defer

For MVP, these can wait:

| Item | Why defer | When |
|---|---|---|
| CLDR integration (locale data) | Not blocking search or display | Phase 6 |
| Natural Earth (map data) | Not blocking | Phase 6 |
| 50+ articles | Start with 10, expand based on traction | Phase 5+ |
| Climate data | Optional, already in D1 | Phase 6 |
| Holidays (Nager.Date) | Already in D1, re-validate | Phase 6 |
| Multilingual UI (hreflang) | i18n is its own project | Phase 6+ |
| User accounts (Clerk) | LocalStorage works for MVP | Phase 6+ |
| Calendar export (.ics) | Nice-to-have | Phase 7 |

---

## Risk analysis

### Phase 1 risks
- **D1 destructive migration** — mitigated by backup
- **Big file parsing (46MB JSON)** — mitigated by batched inserts + D1 batch size limits
- **FK resolution** — pre-validate all country/state IDs exist before inserting cities

### Phase 2 risks
- **place_names volume** — 500K+ rows is a lot for D1; may need to denormalize
- **Search performance** — FTS5 indexes are fast; < 50ms p95 expected
- **Fuzzy matching complexity** — start with prefix, add Levenshtein later

### Phase 3 risks
- **OpenAPI spec gets too large** — keep responses lean, use `?fields=` to limit
- **Postman collection drift** — auto-generate from OpenAPI, fail CI on mismatch

### Phase 4 risks
- **DST transition bugs** — extensive testing, use battle-tested libraries (Temporal, luxon)
- **IDL edge cases** — well-tested but easy to miss; add explicit tests

### Phase 5 risks
- **Content quality** — hire writer or use AI carefully
- **SEO indexing** — slow; track rankings, iterate

---

## Communication plan

After each phase:
1. Commit code with full message
2. Push to feature branch
3. Re-deploy dev Worker (if API-affecting)
4. User pulls + verifies
5. User says lgtm
6. Merge to develop, delete feature branch

---

## Immediate next step

**Start Phase 1** (DB cleanup + rebuild) — the user has approved.

I'll create `feature/db-cleanup-and-rebuild` and start with:
1. Save D1 backup
2. Migration 100 (drop all)
3. Migration 101 (create new schema)
4. Seed scripts 1-5

User will pull and verify after each major step.
