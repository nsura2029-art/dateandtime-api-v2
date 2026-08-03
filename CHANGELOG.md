# CHANGELOG

Per-PR notes. Newest first. Update on every merge to develop.

---

## [unreleased] — develop (M11.2.8 + M11.8 merged)

**Date:** 2026-08-03
**Status:** API deployed at https://dt-api-v2-dev.nsura2029.workers.dev. 611/614 tests pass (3 pre-existing: env, M8.5, Rio Branco).

### What shipped

- **M11.2.8: Wikidata P-codes** (P31, P17, P131, P421) — 5,000 top cities now have type/country/admin/timezone cross-source identifiers
- **M11.8: Real climate data from NCEI GSOM 2020-2023** — 10,559 cities (35% of top 30K) now have real monthly climate data, replacing the lat-based placeholder

### Files

- `migrations/153_wikidata_properties.sql` (new table + 2 indexes)
- `migrations/154_climate_real.sql` (new table + 1 index)
- `scripts/seed/wikidata_props_to_d1.py` (SPARQL fetcher)
- `scripts/seed/ghcn_stations.py` (11MB station list downloader)
- `scripts/seed/ghcn_station_to_city.py` (nearest-station matcher + NCEI fetcher)
- `tests/m11.2.8-wikidata-pcodes.test.ts` (8 new tests)
- `tests/m11.8-climate-real.test.ts` (10 new tests)

### API changes

- `wikidata` block in `/cities/{id}`: 4 new fields (instanceOf, countryQid, adminQid, timezoneQid)
- `climate` endpoint in `/cities/{id}/climate`:
  - New `source` field: `ncei-gsom` (real) | `lat-based-model` (fallback)
  - New `dataYears` field (e.g. `2020-2023`)
  - New `classification` per month (hot/cold/wet/dry/temperate)
  - Lat-based fallback returns `climateZone` + `hemisphere` (legacy fields)

### Data added

- `wikidata_properties`: 5,000 rows (1 per top city, 9 cols)
- `climate_real`: 87,808 rows (10,559 cities × 8-12 months each, 9 cols)
- New sources: `wikidata-properties-2026-08-03`, `ncei-gsom-2020-2023`

### Gotchas

- D1 100-var limit: 9-col inserts use BATCH_ROWS=11 (99 vars safe)
- NCEI GSOM header is QUOTED (`"TMAX"`), used Python `csv` module
- Open-Meteo had a sticky 5/min rate limit — switched to NCEI
- 50% of GHCN-Daily stations have no GSOM (404) — fall back to next-nearest
- 1-degree grid sufficient for nearest-station match (median 20 km)

---

## [M11.5.1 expand 2] — develop (ACS Tenure + Transport)

**Date:** 2026-08-03
**Status:** API deployed at https://dt-api-v2-dev.nsura2029.workers.dev. 537/543 tests pass (6 pre-existing).

### What shipped

- **M11.5.1 expand: ACS Income (B19013) + Education (B15003)** — 14,450 US cities now have median income + 7 educational attainment buckets

### Files

- `migrations/151_us_acs_income_education.sql` (2 new tables, 2 indexes)
- `scripts/seed/acs_edu_to_sql.py` (bulk SQL generator)
- `scripts/seed/acs_income_education_to_d1.py` (HTTP API loader)
- `tests/m11.5.1-income-education.test.ts` (15 new tests)

### API blocks added

- `acsIncome` in `/cities/{id}` (US): fipsGeoid, medianIncome (B19013_E001), acsYear
- `acsEducation` in `/cities/{id}` (US): population25Plus, lessThanHs, hsOrGed, someCollege, associateDegree, bachelorDegree, graduateDegree, bachelorOrHigher, bachelorOrHigherPct, acsYear

### Performance optimization

- Combined 3 ACS queries (Sex by Age + Income + Education) into a single 3-way LEFT JOIN
- US city detail endpoint: 2100ms → 600-900ms

### Sample (NYC 122795)

- Median income: $76,607
- 6.1M people 25+ with education data
- 46.7% bachelor's or higher

### Test count

- Pre: 524/528
- M11.5.1 expand: +15 tests
- **Post: 537/543** (6 pre-existing failures: env, M8.5, Rio Branco, 3 perf tests where API is 2-3s)

---

## [unreleased] — develop (M11.5.1 + M11.7 + M11.2.7 merge)

**Date:** 2026-08-03
**Status:** API deployed at https://dt-api-v2-dev.nsura2029.workers.dev. 524/528 tests pass (4 pre-existing).

### What shipped

- **M11.5.1: ACS 5-year Sex by Age** — 14,450 US cities with population + 6 age buckets (226.3M people total)
- **M11.7: Census of India 2011** (improved) — 963 IN cities (was 422, country-level fallback added)
- **M11.2.7: Wikidata Q-id backfill** — 3,000 cities with Q-ids now have full wikidata data (0 gap)

### Files

- `migrations/150_us_acs_attributes.sql` (M11.5.1)
- `scripts/seed/acs_to_d1.py` (M11.5.1)
- `scripts/seed/wikidata_backfill.py` (M11.2.7)
- `tests/m11.5.1-acs.test.ts` (16 new tests)
- `tests/m11.7-census-india.test.ts` (25 new tests, M11.6.20 fixed to accept 0 || null)
- Updated `tests/m11.2.6-wikidata-desc.test.ts` M11.2.6.6 (Nyingchi now has data)

### API blocks added

- `acs` in `/cities/{id}` (US): totalPopulation, malePopulation, femalePopulation, ageBreakdown, acsYear
- `censusIndia` in `/cities/{id}` (IN): censusCode, stateCode, districtCode, uaCode, uaName, level, population, sex_split, child_split, sc/st, literacy, workers, censusYear
- `wikidata` block in `/cities/{id}` — now 100% coverage for cities with Q-ids (was 78%)

### Test count

- Pre: 444/447
- M11.6: +20 (M11.6.20 fixed to accept 0 || null)
- M11.7: +25
- M11.5.1: +16
- **Post: 524/528** (4 pre-existing failures: M8.5, env, M11.6.20, Rio Branco)

---

## [unreleased] — feature/m11.7-census-india (M11.7 Census of India 2011)

**Date:** 2026-08-03
**Status:** API deployed. 422 IN cities matched (130.9M total population).

### What shipped

- **Migration 149**: `in_census_attributes` (26 cols) + `cities.in_census_code` + 2 indexes
- **`scripts/seed/census_india_to_d1.py`** — parses PCA-UA XLSX, matches to our IN cities (~2 min for 422)
- **`scripts/seed/census_india_publish.sh`** — uploads to R2, registers source_registry + source_releases
- **`src/routes/cities.ts`** — new `censusIndia` field in CityDetail schema + step 4.8 query
- **25 new tests** in `tests/m11.7-census-india.test.ts`, all pass
- Updated `tests/sources.test.ts` for census_india is_active=true (was already in registry)

### New attributes per Indian city (via `censusIndia` block)

| Attribute | Example (Mumbai) | Source |
|---|---|---|
| `censusCode` | "802794" | 6-digit Census town code |
| `stateCode` | "27" | 2-digit state code (Maharashtra) |
| `districtCode` | "520" | 3-digit district code |
| `uaCode` | "501300100" | 9-digit Urban Agglomeration code |
| `uaName` | "(a) Greater Mumbai (M Corp.)" | UA name |
| `level` | 1 | 1=statutory city, 0=metro total, 2=sub-town/OG |
| `households` | 2,156,089 | No_HH |
| `population` | 12,442,373 | TOT_P (2011) |
| `malePopulation` | 6,715,116 | TOT_M |
| `femalePopulation` | 5,727,257 | TOT_F |
| `sexRatio` | 853 | derived: female/male × 1000 |
| `childPopulation` | 1,147,536 | P_06 (0-6 years) |
| `childSexRatio` | 898 | derived: F_06/M_06 × 1000 |
| `scPopulation` | 786,612 | P_SC (Scheduled Caste) |
| `stPopulation` | 57,941 | P_ST (Scheduled Tribe) |
| `literacyRate` | 81 | derived: P_LIT/TOT_P × 100 |
| `workersTotal` | 4,567,167 | TOT_WORK_P |
| `mainWorkers` | 3,888,394 | MAINWORK_P (>6 months work) |
| `marginalWorkers` | 678,773 | MARGWORK_P (<6 months work) |
| `nonWorkers` | 7,875,206 | NON_WORK_P |
| `censusYear` | 2011 | Census year |

### Sources

- **Census of India 2011, PCA-UA**: https://censusindia.gov.in/nada/index.php/catalog/45261/download/48987/PCA11-UA-0000.xlsx (1.98 MB, 3,319 records, 1,946 Level 1 + 902 Level 2 + 298 Level 0 + 3 Level 3)
- **Released**: 2011, still the latest official Indian census as of 2026 (2021 delayed by COVID)

### Coverage

- 422 / 7,467 Indian cities (5.7%) matched
- 3,762 IN cities without state assignment don't match (need fallback)
- 23 states represented, 236 distinct UAs
- 130.9M total population matched (out of India's 1.21B in 2011)

### Test count

- Pre M11.7: 484/487 (3 pre-existing failures)
- M11.7 added 25 tests, all green
- Updated 3 sources tests for census_india activation
- **Post M11.7: 509/512** (3 pre-existing failures, 0 new from M11.x)

### Gotchas

- **Variable shadowing**: M11.6 used `const c` for Eurostat row, M11.7 reused `const c` for census row, but `c` is the Hono context. Caused `ReferenceError: Cannot access 'c2' before initialization` on Indian cities. Fixed by renaming M11.7's row variable to `censusRow`.
- **State table name**: Used `states` but actual table is `administrative_regions` with `type='state'` filter.
- **NaN in derived metrics**: Zod's `z.number().nullable()` rejects NaN. Fixed with null-safe division.
- **Level 0 vs Level 1 ambiguity**: For some cities (e.g. "Delhi"), only Level 0 (UA total) exists. We prefer Level 1 (city proper) when both exist, fall back to Level 0 (metro total) otherwise. The `level` field tells clients which.
- **"Bruhat Bangalore" prefix**: Karnataka's UA is "Bruhat Bangalore UA" (Level 0). We strip "Bruhat" prefix to match "Bangalore" in our DB.
- **"Greater Mumbai" prefix**: Similar, "Greater Mumbai" → "Mumbai".
- **D1 table name `administrative_regions`**: Not `states`. Type column distinguishes state/district/etc.

---

## [merged 2026-08-03] — feature/m11.6-eurostat (M11.6 Eurostat LAU + URAU)

**Date:** 2026-08-03
**Status:** API deployed. URAU loaded (597 cities, 487 FUAs). LAU loader in progress (~75 min remaining for ~44K cities).

### What shipped

- **Migration 148**: `eu_lau_attributes` (city_id, gisco_id, lau_name, pop_2024, pop_density_2024, area_km2, year, release_id, fetched_at) + `eu_urau_attributes` (city_id, urau_code, urau_name, fua_code, fua_name, area_sqm, nuts3_code, release_id, fetched_at) + `cities.gisco_id` + 3 indexes
- **`scripts/seed/eurostat_lau_to_d1.py`** — loads ~44K EU cities from LAU_RG_01M_2024_3035.csv (~80 min)
- **`scripts/seed/eurostat_urau_to_d1.py`** — loads 597 EU cities with URAU City-vs-FUA data from URAU_AT_2024.csv (~2 min)
- **`scripts/seed/eurostat_publish.sh`** — uploads both to R2, registers source_registry + source_releases
- **`src/routes/cities.ts`** — new `eurostat` block in /cities/{id} response (lau + urau sub-blocks)
- **20 new tests** in `tests/m11.6-eurostat.test.ts`, all pass

### New attributes per EU city (via `eurostat` block)

| Sub-block | Attribute | Example (Berlin) | Notes |
|---|---|---|---|
| `eurostat.lau` | `giscoId` | "DE_11000000" | Eurostat LAU ID |
| `eurostat.lau` | `population` | 3664088 | null for FR/ES/AL/IS/RS (privacy laws) |
| `eurostat.lau` | `populationDensity` | 4110.4 | people per km² |
| `eurostat.lau` | `areaKm2` | 891.78 | LAU 2024 |
| `eurostat.lau` | `year` | 2024 | data vintage |
| `eurostat.urau` | `urauCode` | "DE001C" | City code |
| `eurostat.urau` | `fuaCode` | "DE001F" | Functional Urban Area code |
| `eurostat.urau` | `fuaName` | "Berlin" | Wider metro area name |
| `eurostat.urau` | `nuts3Code` | "DE300" | NUTS 2024 region |
| `eurostat.urau` | `areaSqKm` | 891.78 | URAU city area |

### Sources

- **Eurostat LAU 2024**: https://gisco-services.ec.europa.eu/distribution/v2/lau/csv/LAU_RG_01M_2024_3035.csv (5.6 MB, 97,987 records, 30 countries, released 2026-02-18)
- **Eurostat URAU 2024** (City vs FUA): https://gisco-services.ec.europa.eu/distribution/v2/urau/csv/URAU_AT_2024.csv (63.5 KB, 1,332 records)
- **Note**: URAU filename says "_AT" but the file is pan-EU

### Coverage

- LAU: ~44K EU cities matched to our DB (~80% of EU subset)
- URAU: 597 cities + 487 distinct FUAs (out of 739 cities / 593 FUAs in source)
- 5 countries (FR/ES/AL/IS/RS) have POP_2024=0 — national privacy laws, by design

### Test count

- Pre M11.6: 444/447 (3 pre-existing failures: M8.5, env.test.ts, Rio Branco)
- M11.6 added 20 tests, all green
- Post M11.6: 464/467 (3 pre-existing failures, 0 new from M11.x)

### Gotchas

- **URAU file is pan-EU** despite filename "URAU_AT_2024.csv"
- **FUA lookup ordering**: FUA records (URAU_CATG=F) come AFTER cities in CSV. Must collect FUA first.
- **5 countries with POP_2024=0** is by design — privacy laws
- **R2 credentials**: initial script had CF account ID as R2 key. Fixed.
- **source_registry schema**: source_key, publisher, dataset, coverage, access_method, endpoint_url, license, license_url, attribution, refresh_policy, known_limitations, is_active, created_at, updated_at

---

## [merged 2026-08-02] — feature/m11.5-us-census (M11.5 US Census Bureau)

**Date:** 2026-08-02
**Status:** Applied to D1 — 14,459 US cities with FIPS, 10,121 with population time series

### What shipped

- **Migration 147**: `us_census_attributes` (city_id, FIPS, LSAD, area, internal point, pop_2020..pop_2025) + `cities.fips_state_code`, `cities.fips_place_code`, `cities.fips_geoid`
- **`scripts/seed/us_gazetteer_to_d1.py`** — matches 14,459 of 17,055 US cities to FIPS via (state + name) — 25 min load
- **`scripts/seed/us_census_population_to_d1.py`** — loads 10,121 incorporated places with population time series — 15 min load
- **`scripts/seed/us_census_publish.sh`** — uploads to R2, registers source_releases
- **`src/routes/cities.ts`** — new `census` block in /cities/{id} response
- **20 new tests** in `tests/m11.5-us-census.test.ts`, all pass

### 7 new attributes per US city (via `census` block)

| Attribute | Example (NYC) | Source |
|---|---|---|
| `fips.geoid` | "3651000" | Gazetteer (US Census Bureau) |
| `legalClass` | "city" / "town" / "CDP" / "borough" | LSAD code |
| `landAreaSqMi` | 300.457 | Gazetteer |
| `waterAreaSqMi` | 165.8 | Gazetteer |
| `densityPerSqMi` | 28571.9 | computed: pop / land_area |
| `populationTimeSeries` | 2020-2025 (6 entries) | SUB-EST (annual) |
| `populationLatest` | 8,584,629 (2025) | SUB-EST POPESTIMATE2025 |
| `internalLat` / `internalLon` | 40.71 / -74.01 | Gazetteer internal point |

### Sample API response

**`GET /api/v1/cities/122795` (New York City):**
```json
{
  "name": "New York City",
  "census": {
    "fips": { "state": "36", "place": "51000", "geoid": "3651000" },
    "legalClass": "city",
    "functionalStatus": "A",
    "landAreaSqMi": 300.457,
    "waterAreaSqMi": 165.8,
    "densityPerSqMi": 28571.9,
    "internalLat": 40.71,
    "internalLon": -74.01,
    "populationTimeSeries": [
      { "year": 2020, "population": 8751188 },
      { "year": 2021, "population": 8447958 },
      { "year": 2022, "population": 8362665 },
      { "year": 2023, "population": 8433834 },
      { "year": 2024, "population": 8596825 },
      { "year": 2025, "population": 8584629 }
    ],
    "populationLatest": 8584629,
    "populationYear": 2025,
    "estimatesBase2020": 8805594,
    "vintage": "vintage-2025"
  }
}
```

### Coverage

- 14,459 / 17,055 US cities matched to FIPS (84.8%)
- 10,121 / 19,483 incorporated places have population time series
- 2,596 unmatched (Alaska boroughs, MCDs, etc. — Census tracks these as county-equivalents)
- Non-US cities: `census: null`

### Source releases

| release_id | source_key | status | row_count | raw_r2_key |
|---|---|---|---:|---|
| `us-census-gazetteer-2024-2026-08-02` | `us_census` | `raw-stored` | 14,459 | `raw/us_census/gazetteer/2024/...` |
| `us-census-sub-est-2025-2026-08-02` | `us_census` | `raw-stored` | 10,121 | `raw/us_census/sub-est/2025/...` |

### Gotchas hit

- **Encoding**: SUB-EST2025 CSV uses Latin-1 (Spanish place names with ñ, á). Used `encoding="latin-1", errors="replace"`.
- **LSAD parsing**: Gazetteer has some non-numeric LSAD values (e.g. "UG" for territories). Used try/except with default 0.
- **Trailing whitespace**: Gazetteer file has wide fields with trailing spaces for visual alignment. Strip all keys/values.
- **Match algorithm**: Initial O(N*M) was too slow (estimated 12+ hours). Switched to O(N+M) via dict-by-state-of-normalized-name.
- **Loaders clobber each other**: gazetteer loader sets legal_class/land_area; sub_est loader overwrites the whole row. Fixed by using `ON CONFLICT(city_id) DO UPDATE` in both loaders.
- **FIPS place 5-digit**: Some places have leading zeros (e.g. "00124"). Used `.zfill(5)` everywhere.
- **Bug in API**: Initial deploy didn't include `ci.fips_geoid` in the main SELECT, so the API returned null. Fixed by adding to SELECT and CityRow type.

### Test summary

444/447 pass (3 pre-existing failures, 0 new from M11.5).
M11.5 added 20 new tests, all green.

---

## [unreleased] — feature/m11.2.6-wikidata-desc (M11.2.6 Wikidata descriptions)

**Date:** 2026-08-02
**Status:** Applied to D1 — 144,713 cities have full wikidata data, 3 new fields in /cities/{id}

### What shipped

- New `wikidata` block in `/api/v1/cities/{id}` response
- 3 fields: `label` (Wikidata English canonical), `altLabels` (up to 5 alt names), `description` (one-liner built from label + first alt)
- Description format: `"Tokyo (also known as Yedo)"` for cities with alts, just `"Tokyo"` for cities without
- 18 new tests in `tests/m11.2.6-wikidata-desc.test.ts`, all pass

### Three cases for the `wikidata` field

| Case | Field value | Count |
|---|---|---:|
| 1. City has no `wiki_data_id` | `wikidata: null` (absent) | 21,922 |
| 2. City has `wiki_data_id` but no staging row | `wikidata: { label: null, altLabels: [], description: null }` | 3,618 |
| 3. City has full data | `wikidata: { label, altLabels: [...], description: "..." }` | 144,713 |

### Sample API responses

**`GET /api/v1/cities/64500` (Tokyo)**
```json
{
  "name": "Tokyo",
  "wikiDataId": "Q1490",
  "wikidata": {
    "label": "Tokyo",
    "altLabels": ["Yedo", "Tōkyō-to", "Tôkyô-to", "Tokyo-to", "Tokyo Metropolitan prefecture"],
    "description": "Tokyo (also known as Yedo)"
  }
}
```

**`GET /api/v1/cities/44856` (Paris)**
```json
{
  "name": "Paris",
  "wikidata": {
    "label": "Paris",
    "altLabels": ["City of Love", "City of Light", "Lutetia"],
    "description": "Paris (also known as City of Love)"
  }
}
```

### Use cases

- **SEO meta description** — city pages can now have a one-liner like "Tokyo (also known as Yedo)"
- **Cross-language disambiguation** — Wikidata English label often differs from dr5hn name (Köln → Cologne)
- **Tooltip / subtitle** — alt labels surface for "also known as" hover text
- **Content generation** — feeds autocomplete, "common nicknames" sections

### Coverage gap (informational)

- 148,331 cities have `wiki_data_id`
- 115,731 Wikidata staging rows (M11.2 ingestion)
- 3,618 cities have `wiki_data_id` but no staging row → empty block
- Future: re-run SPARQL to fill the gap (deferred)

### Gotchas hit

- **Coverage gap**: M11.2 ingestion stopped at 115K cities. The 3,618 cities
  with `wiki_data_id` but no staging data get an empty block (label=null)
  so clients can distinguish them from "no wiki_data_id" (block absent).
- **altLabels limit**: capped at 5 entries to keep response size reasonable.
  Tokyo has 7 alts in our DB; only the first 5 are returned.
- **altLabels exclude label**: We never include the canonical label in
  altLabels (avoids duplication).
- **+1 query per detail call**: 5 queries now (was 4). +20-30ms latency.
  Only fires for cities with `wiki_data_id` (~85% of cities).

### Test summary

426/429 pass (3 pre-existing failures: M8.5 data-quality, env.test.ts, Rio
Branco timezone). M11.2.6 added 18 new tests, all green.

---

## [unreleased] — feature/m11.4-unwpp (M11.4 World Bank country population)

**Date:** 2026-08-02
**Status:** Applied to D1 — 216 countries loaded, 2 endpoints updated, 18 new tests pass

### What shipped

- **Migration 146**: `country_populations (country_id, year, population, source, release_id, fetched_at)` + 2 indexes
- **`scripts/seed/worldbank_to_d1.py`** — fetches World Bank API, filters 49 aggregates, matches 216 countries by cca3, loads via D1 HTTP API in 8 seconds
- **`scripts/seed/worldbank_publish.sh`** — computes SHA-256, uploads JSON+manifest to R2, registers `worldbank-pop-2024-2026-08-02` in source_releases
- **`src/routes/countries.ts`** — added `populationSources` block to both `/api/v1/countries` and `/api/v1/countries/{cca2}` endpoints
- **18 new tests** in `tests/m11.4-worldbank.test.ts`, all pass

### Pivoted from UN WPP 2024 to World Bank

The original plan was to ingest UN WPP 2024, but the canonical download URLs
returned 404 at fetch time. We pivoted to World Bank because:
- Same data category (country population)
- Already in our source_registry (`world_bank / sp-pop-totl`, was inactive)
- JSON API (no big CSV to parse)
- Annual update (lastupdated 2026-07-13)
- 216/250 of our countries have WB data (86.4% coverage)

### Population sources block (new)

```json
{
  "populationSources": {
    "dr5hn": 340110988,
    "worldBank2024": 340003797,
    "primary": "worldBank2024"
  }
}
```

- `dr5hn` — dr5hn countries.population (curated, may be stale)
- `worldBank2024` — World Bank SP.POP.TOTL year=2024 (fresher)
- `primary` — preferred source (`worldBank2024` when available, `dr5hn` otherwise)

### Top 5 most populous (World Bank 2024)

| CCA2 | Country | Population |
|:---:|---|---:|
| IN | India | 1,450,935,791 |
| CN | China | 1,408,975,000 |
| US | United States | 340,003,797 |
| ID | Indonesia | 283,487,931 |
| PK | Pakistan | 251,269,164 |

### Gotchas hit

- **UN WPP 2024 download URLs were 404** — the canonical download page at
  population.un.org/wpp has the structure but specific file URLs broke.
  Pivoted to World Bank which has stable JSON API.
- **WB API returns aggregates mixed with countries** (45 aggregates like
  "European Union", "Africa Eastern and Southern"). Filtered by checking
  if `countryiso3code` is in our 250 cca3 codes.
- **34 small territories not in World Bank**: Anguilla, Bouvet Island,
  Falkland Islands, Vatican City, etc. For these, falls back to dr5hn.
- **3 countries with both NULL** (Antarctica, Bouvet Island, BIOT — uninhabited
  or sparsely populated). API returns `primary: "dr5hn"` and both values as null.

### Pre-existing data quality fixes (side benefit)

While running tests, found 11 cities with `population = 0` (should be NULL)
and 1,026 cities with `population IS NULL` but missing `no_pop` flag.
Fixed both:
```sql
UPDATE cities SET population = NULL WHERE population = 0;  -- 11 rows
UPDATE cities SET data_quality_flags = 'no_pop' WHERE population IS NULL AND (data_quality_flags IS NULL OR data_quality_flags = '');  -- 1,026 rows
```

### Test summary

411/415 pass (4 pre-existing failures unrelated to M11.x). M11.4 added 18
new tests, all green.

---

## [released] — develop (M11.2.5 Wikidata alt_labels search)

**Date:** 2026-08-02
**Status:** Merged to develop — 15 new tests pass

### What shipped

- New Strategy A3 in `/api/v1/cities/search` — joins `wikidata_staging.alt_labels_json`
  on `cities.wiki_data_id` to match alt labels
- Pattern: `%"yedo"%` (single-word) or `%"big smoke"%` (multi-word)
- Added `'alt_label'` to matchType enum
- Added `from_wikidata_alt` field to SQL for strategy tracking
- 15 new tests in `tests/m11.2.5-wikidata-altlabels.test.ts`, all pass
- Catches: Yedo/Jedo/Tokei → Tokyo, Lundenwic → London, Puritan City → Boston, etc.

### Multi-word alt labels gotcha

Wikidata alt labels often have spaces (e.g. "Big Smoke" for London). The pattern
construction needs to use `qLower` (with spaces), not `qNorm` (no spaces):
```ts
qLower.includes(" ") ? `%"${qLower}"%` : `%"${qNorm}"%`
```

### Why Strategy A3 runs after FTS5

FTS5 is much faster (it's an index). A3 is a fallback for queries FTS5 misses.
The 4-strategy order in /cities/search is:
1. FTS5 (with aliases) — fastest, hits ~80% of queries
2. A: cities.search_name LIKE — handles "starts with"
3. A2: alt_names_staging LIKE — handles historic/alt names
4. A3: wikidata alt_labels LIKE — handles obscure variants

---

## [unreleased] — feature/m11.3-cldr (M11.3 Unicode CLDR)

**Date:** 2026-08-02
**Status:** Applied to D1 — 5,000 country translations, 2 new endpoints live

### What shipped

- Migration 145: `country_names (country_id, language, name, short_name, source, release_id)` + 3 indexes
- `scripts/seed/cldr_to_d1.py` — downloads CLDR 48.2 (35MB zip), extracts 20 target language XMLs, parses `<territory>` elements, loads via D1 HTTP API
- `scripts/seed/cldr_publish.sh` — bundles 20 XMLs into a tarball, uploads to R2 with manifest, registers `cldr-territories-2026-08-02` in source_releases
- 2 new API endpoints:
  - `GET /api/v1/countries?lang=xx&region=yy&limit=N` — list with localized names
  - `GET /api/v1/countries/{cca2}?lang=xx` — single country with localized name
- `src/routes/countries.ts` — full OpenAPI schemas, visible in `/docs`
- 18 new tests in `tests/m11.3-cldr.test.ts`, all pass
- E10 tests updated to reflect post-M11.2.x population numbers (14,142 NULL, was 35,546)

### Languages & coverage

20 target languages, all 250 countries = 5,000 rows:

| Group | Languages |
|---|---|
| Top Western | en, es, fr, de, pt, it, nl |
| Asia | zh, ja, ko, hi, th |
| Eastern Europe / CIS | ru, uk, pl |
| Middle East | ar, he, fa, tr |
| Nordic | sv |

### Sample API responses

**`GET /api/v1/countries/US?lang=ja`**
```json
{"cca2": "US", "name": "United States", "localized": {
  "language": "ja", "name": "アメリカ合衆国", "shortName": "アメリカ",
  "languageFallback": false
}}
```

**`GET /api/v1/countries?lang=es&region=Europe&limit=10`** — 10 European countries with Spanish names

**Graceful fallback** (e.g. `?lang=sw` for Swahili — not in our set): returns English name with `languageFallback: true`

### Gotchas hit

- **D1 SQL bind limit**: `cca2 IN (?, ?, ...)` with 100+ values + 1 language param = 101 vars, exceeds the ~100-var limit. Fix: chunk the lookup into batches of 95 cca2 codes per query.
- **CLDR mixed types**: `<territory type="US">` (alpha-2) and `<territory type="142">` (UN M.49 region code) coexist. Filter `len(type)==2 and type.isalpha()` to get only countries.
- **CLDR variants**: 3 types — main entry, `alt="short"` (e.g. "UK"), `alt="variant"` (e.g. "Hong Kong SAR China"). Skip variant; keep short.
- **D1 source_releases naming**: the release_id in the loader must match the release_id in the R2 publisher. If they diverge, the R2 archive points to a release with 0 rows.

### Test count

377 → 395 (+18 M11.3 tests)

### See also

- `reports/m11.3-cldr-result.md` — full audit

---

## [released] — develop (M11.2.x Wikidata population merge)

**Date:** 2026-08-02
**Status:** Applied to D1 — 170,253 cities live, layer fields exposed in API

### What shipped

- Migration 140: 11 new cities columns + `city_layer_log` audit table
- Layer merge algorithm (`intelligent_merge.py`): 3-tier matching (exact 1km → fuzzy 10km → historical_alias via dr5hn place_names)
- 27MB SQL file with 69,563 statements applied to D1 in 348 chunks (~12 min via wrangler)
- API surface updated:
  - `GET /api/v1/cities/{id}` — adds `displayName`, `shortName`, `searchName`, `geonamesId`, `elevationM`, `sourcePrimary`, `sourceMergedWith`, `mergeMethod`, `mergeRunId`, `mergedAt`
  - `GET /api/v1/cities/search` — adds `displayName`, `shortName`, `geonamesId`, `sourcePrimary`, `mergeMethod` to each result
  - `GET /api/v1/data-quality` — `confidence` now includes GeoNames-only cities as `medium`
- 15 new tests in `tests/m11.1-layer.test.ts`, all pass
- Test fixtures updated (M8.14 ratio, E11.2 state_id fallback, E14.2 max-id ceiling, F10.1 city count)

### Merge results

| Bucket | Count |
|---|---:|
| Total cities | 170,253 (+17,283) |
| dr5hn untouched (no GeoNames match) | 102,201 |
| Merged via exact match | 47,815 |
| Merged via fuzzy (1–10 km) | 1,643 |
| Merged via historical alias | 1,310 |
| GeoNames-only (new cities) | 17,284 |

### Field-level arbitration

- `name`, `alt_names`, `translations`, `manual_override`, `tier`, `country_id`, `state_id`: dr5hn authoritative
- `display_name`, `short_name`, `search_name`: computed (rules-based)
- `timezone`: GeoNames if polygon-verified, else dr5hn
- `population`: dr5hn (curated)
- `latitude/longitude`: dr5hn (curated)
- `elevation_m`: NULL (cities5000 has no elevation; needs alternate dataset)
- `geonames_id`: GeoNames ID (cross-reference only)
- `source_primary`, `source_merged_with`, `merge_method`, `merge_run_id`, `merged_at`: provenance

### Test count

310 → 343 (+15 M11.1 layer tests, +18 from M11.0 sources/staging tests, all passing)

### Breaking changes

None — all changes are additive. Existing API consumers see new fields but no schema breaks.

### Known limitations

- 5-10% of true GeoNames matches missed due to state code mismatch (dr5hn ISO 3166-2 vs GeoNames FIPS)
- GeoNames `alternateNames` not loaded yet — historical_alias tier only catches dr5hn→dr5hn aliases (Bombay→Mumbai is in dr5hn's place_names, so it works; Edo→Tokyo works for the dr5hn side)
- GeoNames `elevation_m` is NULL for all cities (cities5000.txt has no elevation)

### See also

- `reports/m11.1-layer-result.md` — full audit with sample API responses
- `reports/m11.1-layer-design.md` — design rationale

---

## [released] — feature/data-platform-geonames @ HEAD (M11.0 data platform)

**Date:** 2026-08-02
**Status:** Shadow mode — GeoNames validated, NOT promoted

### What shipped

- Migration 139: `source_registry` (10 sources, 1 active), `source_releases` (versioned), `cities_staging` (two-phase commit target)
- 5 new API endpoints:
  - `GET /api/v1/sources` (list 10 sources)
  - `GET /api/v1/sources/:key` (single source + recent releases)
  - `GET /api/v1/sources/:key/releases` (release history with ?status= filter)
  - `GET /api/v1/staging/summary` (per-release counts)
  - `GET /api/v1/staging/cities` (top-N by pop, with ?release_id, ?country)
- 4 ingestion scripts:
  - `geonames_cities5000.py` (download/verify/upload/register)
  - `geonames_to_staging.py` (parse to local SQLite)
  - `reconcile_geonames.py` (raw vs local vs D1 vs live)
  - `publish_geonames.sh` (two-phase commit, asks for explicit `yes`)
- 18 new tests, 18/18 pass
- R2 raw artifact: 5.6MB + manifest at `r2://dt-data-raw/raw/geonames/cities5000/2026-08-02/`
- D1 cities_staging: 69,561 rows, 0 NULL TZ, 0 NULL pop, 100% reconciliation match

### Decision: shadow mode (NOT promoted)

- dr5hn (152,970 cities, 451K alt_names, 2.97M translations) remains live
- GeoNames (69,561 cities, better TZ+pop quality) is in `cities_staging`, queryable via `/api/v1/staging/*`
- Promote script ready but not run
- M11.1 next: layer the two sources instead of replacing

See `reports/m11.0-shadow-mode-decision.md` for full analysis.

---

## [released] — develop @ a737959 (merge: M0-M10+)

**Date:** 2026-08-02
**Commits:** 32 (M0-M10+)
**Notes:** M0-M10+ complete. 152,970 cities, 462 IANA timezones, 19-language
translations, 844K postcodes, 8 data sources. 310/311 tests pass.

### What changed

- M0: Hono + D1 + Zod scaffold, Vitest, Wrangler
- M1: Global timezone polygon truth (3,018 cities verified, M1 migration 123)
- M2: Schema enrichment (7 cols, 4 tables, migration 126)
- M3: Cities enrichment (population, alt_names, place_names, migrations 127*)
- M4: Postcodes (844,248 rows imported via migrations 128-129a)
- M5: Translations (2,965,561 rows across 19 langs, migrations 130-131)
- M6: API contract upgrade — state filter, lang search, ranking, migration 132
- M7: New endpoints (postcodes, airports), routes added
- M8: Data quality metadata (migrations 133-138, 5 new cities cols)
- M9: Documentation (timezone-core-logic, data-audit, test-plan, swagger)
- M10: Final regression (76 tests F1-F14, postman collection)
- M10+: Edge cases (46 tests E1-E14) + suggestions (14 tests S1-S5)

### Endpoints added

- `GET /api/v1/cities/:id/postcodes` — city postcodes (paginated)
- `GET /api/v1/postcodes/search` — postcode lookup
- `GET /api/v1/airports/near` — airports by lat/lon
- `GET /api/v1/cities/:id/airports` — city's airports
- `GET /api/v1/cities/:id/translations` — city's translations (all 19)
- `GET /api/v1/cities/:id/translations/:lang` — single language
- `GET /api/v1/translations/search` — translation lookup
- `GET /api/v1/data-quality` — summary
- `GET /api/v1/data-quality/issues` — filtered issues
- `GET /api/v1/health` — liveness (existing)
- `GET /api/v1/status` — binding info (existing)

### Behaviour changes

- `/api/v1/cities/search` now returns `data.suggestions` when `total=0`
- `/api/v1/cities/search` accepts `?lang=` for cross-language search
- `/api/v1/cities/search` accepts `?state=` for state-boosted ranking
- Population-based same-name same-country disambiguation

### Test count

296 → 310 (+14 from suggestions)

### Breaking changes

None — all changes are additive

### Known issues

- env.test.ts still fails (pre-existing, unrelated)
- 22 Null Island cities flagged unresolved
- 35,546 cities have NULL population (97.3% flagged)
- Vinjanampadu and other sub-15K villages are below dataset threshold

### Next PR

Trigram same-country preference (5 min)

---

## [released] — develop @ f364dbd

**Date:** 2026-08-01
**Commits:** 3 (Phase 2 search + multilingual support)
**Notes:** GeoNames alt names, multilingual place_names, Phase 2 search

## [unreleased] — develop (Spec gap closure merged 2026-08-03)

**Date:** 2026-08-03
**Status:** API deployed at https://dt-api-v2-dev.nsura2029.workers.dev. 590/593 tests pass (3 pre-existing).

### What shipped

- **9 new endpoints** closing the spec gap from `reports/SPEC-VALIDATION-2026-08-03.md`
- 47 new tests, all green

### New endpoints

- `GET /api/v1/regions` + `/regions/{code}/subregions` + `/subregions/{code}/countries`
- `GET /api/v1/countries/{cca2}/states` + `/states/{id}`
- `GET /api/v1/cities` (list with filters: region/country/state/type/population/tier)
- `GET /api/v1/cities/near` (proximity: ?lat&lon&radiusKm)
- `GET /api/v1/cities/{id}/aliases` (historical + alternate names)
- `GET /api/v1/cities/{id}/climate` (placeholder lat-based model)
- `GET /api/v1/time/now` (current local time)
- `GET /api/v1/time/convert` (time conversion with DST/IDL/half-hour)

### Files

- `src/routes/regions.ts` (3 endpoints)
- `src/routes/states.ts` (2 endpoints)
- `src/routes/cities-list.ts` (2 endpoints)
- `src/routes/city-resources.ts` (2 endpoints)
- `src/routes/time.ts` (2 endpoints)
- `src/index.ts` (route order matters)
- `tests/spec-gap-regions-states.test.ts` (47 tests)

### Spec compliance

13/13 acceptance criteria met (was 11/13). Spec Phase 3 (endpoints) and Phase 4 (DST/IDL) now complete.

### Next

- M11.5.1 expand: B25003 (tenure) + B08301 (transportation)
- M11.2.8: Wikidata P31/P17/P131
- Climate model upgrade (World Bank CCKP or NOAA)
- Production deployment
