# Master Specification: Data Architecture + API + Content

**Date:** 2026-08-01
**Status:** Captured from user message — to be implemented in phases
**Scope:** Database schema + API + search + Postman + user education content

This is the **complete spec** the user wants. It's been broken into phases for incremental implementation (see `docs/PLAN-phased-implementation.md`).

---

## Part 1: Database Schema (canonical entities)

### Main entities (10 tables)

| # | Table | Purpose | Rows (target) | Source |
|---|---|---|---|---|
| 1 | `countries` | 250 countries with full metadata | 250 | dr5hn, ISO 3166 |
| 2 | `administrative_regions` | States/provinces/counties/regions (hierarchical) | 5,308+ | dr5hn, ISO 3166-2 |
| 3 | `cities` | Canonical place records (one per real-world place) | 152,970 | dr5hn + GeoNames |
| 4 | `place_names` | All searchable names per place (any language/script) | 500K+ | dr5hn, GeoNames alternateNames |
| 5 | `time_zones` | IANA canonical + aliases (~450) | ~450 | IANA tzdb-2026c |
| 6 | `city_time_zones` | M2M: cities ↔ timezones (one city → many if multi-tz) | 153K+ | computed |
| 7 | `country_time_zones` | M2M: countries ↔ timezones (one country → many) | 400+ | IANA + zoneinfo |
| 8 | `data_sources` | Metadata about each import source | 10+ | internal |
| 9 | `import_history` | Every import run (timestamp, rows, errors) | growing | internal |
| 10 | `place_redirects` | Old ID → new ID (for historical/merged cities) | 30+ | internal |

### City schema (full requirements)

Each city must include:
- Internal **canonical place ID** (auto-increment INTEGER)
- **Official name** (e.g., "München")
- **ASCII name** (e.g., "Munich")
- **Local/native name** (e.g., "Мюнхен" in Russian)
- **Country code** (ISO 3166-1 alpha-2, e.g., "DE")
- **State or province** (e.g., "Bayern")
- **District or county** where available (e.g., "Oberbayern")
- **Latitude** (decimal degrees)
- **Longitude** (decimal degrees)
- **Population** (integer, may be NULL)
- **Capital type** (none / state_capital / country_capital / both)
- **Place type** (city / town / village / neighborhood / district)
- **GeoNames ID or source ID** (original ID from provider)
- **IANA time-zone ID** (e.g., "Europe/Berlin")
- **Active or historical status** (boolean)
- **Created and updated timestamps**
- **Source version** (e.g., "dr5hn-2026-07-29", "geonames-2026-06-15")

### Edge cases the schema MUST support

| # | Edge case | Solution |
|---|---|---|
| 1 | Same city name in multiple countries | `cities` row per country, distinct by `country_id` + `state_id` + `coordinates` |
| 2 | Same city name in multiple states | `cities` row per state, distinct by `state_id` |
| 3 | City and state sharing the same name | Two rows in `cities` (one with `place_type='city'`, one with `place_type='state'` or stored in `administrative_regions`) |
| 4 | Historical and renamed cities | `is_historical` flag, `place_redirects` table for old → new ID |
| 5 | Alternate spellings | `place_names` table (many per city) |
| 6 | Diacritics | Both "München" and "Munich" stored in `place_names` |
| 7 | Native-language scripts | `place_names.script` column (Cyrillic, Arabic, Han, etc.) |
| 8 | Transliteration | `place_names.name_type='transliteration'` |
| 9 | Abbreviations | `place_names.name_type='abbreviation'` ("NYC" → New York City) |
| 10 | Neighborhoods vs cities | `cities.place_type` enum (city / town / village / neighborhood / district) |
| 11 | Cities near administrative boundaries | `cities.coordinates` + radius check; flagged in `cities.boundary_disputed` |
| 12 | Multiple cities sharing one time zone | `city_time_zones` M2M table |
| 13 | Countries with multiple time zones | `country_time_zones` M2M table |
| 14 | Half-hour and quarter-hour offsets | Handled at query time via IANA; offset stored as minutes in `time_zones.current_offset` |
| 15 | DST changes | IANA is source of truth; offsets computed dynamically per timestamp |
| 16 | Deprecated IANA aliases | `time_zones.canonical_id` (e.g., "US/Alaska" → "America/Anchorage") |
| 17 | Duplicate records from multiple providers | Dedup by `source_id` + `country_id` + `coordinates` ± 0.01° + `name` |
| 18 | Merged or superseded cities | `place_redirects.from_id` → `to_id` |
| 19 | Missing population or admin data | Columns nullable; query handles NULL |
| 20 | Disputed or configurable geographic labels | `cities.disputed` flag + `cities.claimed_by` (country code array) |

### place_names table (search-friendly)

```sql
CREATE TABLE place_names (
  id INTEGER PRIMARY KEY,
  canonical_place_id INTEGER NOT NULL,   -- FK to cities.id
  name TEXT NOT NULL,                    -- "München" / "Munich" / "Мюнхен" / "NYC"
  normalized_name TEXT NOT NULL,         -- for search: lowercase, diacritics removed
  language_code TEXT,                    -- ISO 639-1: "de", "en", "ru"
  script TEXT,                           -- "Latn", "Cyrl", "Arab", "Hans"
  name_type TEXT NOT NULL,               -- 'official' | 'ascii' | 'local' | 'transliteration' | 'abbreviation' | 'alternate' | 'historical' | 'colloquial'
  is_preferred INTEGER DEFAULT 0,        -- 1 = use for display when multiple exist
  is_historical INTEGER DEFAULT 0,       -- 1 = historical name, no longer in use
  source TEXT,                           -- "dr5hn" | "geonames" | "wikipedia" | "manual"
  FOREIGN KEY (canonical_place_id) REFERENCES cities(id)
);

CREATE INDEX idx_place_names_norm ON place_names(normalized_name);
CREATE INDEX idx_place_names_canonical ON place_names(canonical_place_id);
CREATE INDEX idx_place_names_lang ON place_names(language_code, script);
```

### Search normalization

| Step | What | Why |
|---|---|---|
| 1 | Lowercase | case-insensitive |
| 2 | Unicode normalize (NFKD) | decompose accented chars |
| 3 | Remove diacritics | "München" → "Munchen" matches "Munich" |
| 4 | Remove extra whitespace | "New  York" → "new york" |
| 5 | Optional: romanize non-Latin | "Мюнхен" → "München" (via transliteration table) |
| 6 | Optional: trim suffixes | "New York City" → "new york" (fuzzy) |

### Search matching types (supported)

| Type | Use case | Example |
|---|---|---|
| **Exact** | User knows exact name | "Tokyo" → Tokyo, JP |
| **Prefix** | Typeahead | "San " → San Francisco, San Diego, San Antonio, … |
| **Alternate-name** | User uses colloquial name | "NYC" → New York City, US |
| **Fuzzy** | User misspells | "Munic" → Munich (via edit distance) |
| **Diacritic-insensitive** | User types without accents | "Munich" → München (both work) |
| **Native script** | User types in own language | "東京" → Tokyo (Japanese) |
| **Transliteration** | User romanizes | "Токио" → Tokyo (Russian romanization) |
| **Administrative filter** | User specifies country/state | "Hyderabad" in Pakistan vs India |

### Search result context (per the spec)

For "Hyderabad", return SEPARATE results with full disambiguation:

```json
[
  {
    "city": "Hyderabad",
    "state": "Telangana",
    "country": "India",
    "country_code": "IN",
    "coordinates": { "lat": 17.385, "lon": 78.4867 },
    "population": 10534000,
    "place_type": "city",
    "iana_timezone": "Asia/Kolkata",
    "current_utc_offset": "UTC+05:30",
    "is_dst": false
  },
  {
    "city": "Hyderabad",
    "state": "Sindh",
    "country": "Pakistan",
    "country_code": "PK",
    "coordinates": { "lat": 25.396, "lon": 68.3778 },
    "population": 1731000,
    "place_type": "city",
    "iana_timezone": "Asia/Karachi",
    "current_utc_offset": "UTC+05:00",
    "is_dst": false
  }
]
```

### UTC offset calculation

- **Store IANA time-zone identifiers** (not fixed UTC offsets)
- **Calculate offsets dynamically** for the requested timestamp (because DST rules can change)
- Example: `Asia/Kolkata` is UTC+05:30 always; `America/New_York` is UTC-05:00 (EST) or UTC-04:00 (EDT)
- Implementation: `Intl.DateTimeFormat` with `timeZone` option, or `Temporal` API, or Python `zoneinfo`

---

## Part 2: Deliverables Checklist

| # | Deliverable | Status | Phase |
|---|---|---|---|
| 1 | SQL schema (all 10 tables) | TODO | 1 |
| 2 | Indexes | TODO | 1 |
| 3 | Foreign keys | TODO | 1 |
| 4 | Import scripts (dr5hn, GeoNames, IANA) | TODO | 1 |
| 5 | Data-cleaning rules | TODO | 1 |
| 6 | Deduplication logic | TODO | 2 |
| 7 | Search API design | TODO | 2 |
| 8 | Seed-data examples | TODO | 1 |
| 9 | Automated tests | TODO | 2, 3 |
| 10 | Data-refresh strategy | TODO | 4 |
| 11 | Source-version tracking | TODO | 1 |
| 12 | Migration scripts | TODO | 1 |
| 13 | Postman collection | TODO | 1 |
| 14 | User education content | TODO | 5 |

---

## Part 3: Test Cases (to be generated)

Per the spec, the test suite must cover:

### Functional tests

| # | Category | Examples |
|---|---|---|
| 1 | Duplicate city names | "Springfield" → 30+ results across US states |
| 2 | Multiple scripts | "東京" / "Tokyo" / "Токио" all match Tokyo |
| 3 | Diacritics | "München" / "Munich" both match |
| 4 | Historical names | "Bombay" → Mumbai, "Peking" → Beijing |
| 5 | Misspellings | "Munic" → Munich (fuzzy) |
| 6 | Country filter | "Hyderabad" + ?country=IN → only India result |
| 7 | State filter | "Hyderabad" + ?state=Telangana → only Telangana result |
| 8 | Invalid input | SQL injection, empty string, single char, 1MB string |
| 9 | Pagination | limit=10, offset=20, hasMore flag |
| 10 | Rate limits | 100 req/min per IP, 429 after |
| 11 | Duplicate source records | Same city from dr5hn + GeoNames → 1 row (dedup) |
| 12 | DST transitions | Spring forward / fall back handled correctly |
| 13 | Nonexistent local times | 2:30 AM on spring-forward day (doesn't exist) |
| 14 | Repeated local times | 1:30 AM on fall-back day (occurs twice) |
| 15 | International Date Line | UTC-12 and UTC+14 — same date, different day |
| 16 | Half-hour zones | "Asia/Kolkata" UTC+05:30, "Asia/Kathmandu" UTC+05:45 |
| 17 | Quarter-hour zones | "Pacific/Chatham" UTC+12:45 |

### Non-functional tests

| # | Category | Target |
|---|---|---|
| 18 | API latency p50 | < 50ms |
| 19 | API latency p95 | < 200ms |
| 20 | API latency p99 | < 500ms |
| 21 | Throughput | 1000 req/s sustained |
| 22 | DB query time | < 10ms p95 |
| 23 | Cold start | < 100ms (Workers) |
| 24 | Memory | < 128MB per request |

---

## Part 4: Postman Collection

We need a Postman collection that exercises the API:

- **Generate from OpenAPI spec** (auto-synced)
- **Include all endpoints** with example requests
- **Include test scripts** (Postman test runner)
- **Include environment variables** (BASE_URL, API_KEY, etc.)
- **Include pre-request scripts** for auth (when added)
- **Document in README** how to import + use

Location: `docs/api/dateandtime-api-v2.postman_collection.json`
Generator: `scripts/extract-postman.ts` (reads openapi.json → Postman v2.1.0)

---

## Part 5: User Education Content (Time Zone Articles)

Examples the user pointed to:
- https://www.remitly.com/blog/lifestyle-culture/time-zones/
- https://www.timeanddate.com/time/current-number-time-zones.html
- https://www.timeanddate.com/time/time-zones.html

### Content topics (initial 10-15 articles)

| # | Title | URL slug | Target keyword | Search vol (est.) |
|---|---|---|---|---|
| 1 | "What is a time zone? A complete guide" | /learn/what-is-a-time-zone | what is a time zone | 50K/mo |
| 2 | "How many time zones are there in the world?" | /learn/how-many-time-zones | how many time zones | 30K/mo |
| 3 | "UTC vs GMT: what's the difference?" | /learn/utc-vs-gmt | utc vs gmt | 25K/mo |
| 4 | "Daylight Saving Time 2026: when does it start?" | /learn/daylight-saving-time-2026 | dst 2026 | 100K/mo |
| 5 | "Why do we have time zones?" (history) | /learn/why-time-zones | why time zones | 10K/mo |
| 6 | "The International Date Line: where is it?" | /learn/international-date-line | international date line | 15K/mo |
| 7 | "Time zones by country: full list" | /learn/time-zones-by-country | time zones by country | 40K/mo |
| 8 | "Half-hour and quarter-hour time zones" | /learn/half-hour-time-zones | half hour time zones | 5K/mo |
| 9 | "How to schedule meetings across time zones" | /learn/schedule-meetings-across-time-zones | schedule meetings across time zones | 8K/mo |
| 10 | "Jet lag: how to recover faster" | /learn/jet-lag-recovery | jet lag recovery | 20K/mo |
| 11 | "The weirdest time zones in the world" | /learn/weirdest-time-zones | weird time zones | 12K/mo |
| 12 | "How time zones affect global business" | /learn/time-zones-business | time zones business | 6K/mo |
| 13 | "Time zone abbreviations: A to Z" | /learn/time-zone-abbreviations | time zone abbreviations | 18K/mo |
| 14 | "Countries that don't observe DST" | /learn/countries-without-dst | countries without dst | 22K/mo |
| 15 | "What is Unix time / epoch time?" | /learn/unix-time-epoch | unix time | 35K/mo |

### Content format

- 1,500-3,000 words per article
- Schema.org `Article` markup for SEO
- Internal links to API endpoints (e.g., "Find the current time in [city]" → links to `/api/v1/cities/:id`)
- Embedded city cards with live data
- Images (Time zone maps, world clock, etc.)
- Target: 50 articles in first 6 months (long-tail SEO play)

### Implementation

- Static site (Next.js / Astro) in the UI repo (dateandtime-live, separate)
- MDX for content
- Auto-generate city/timezone cards from API data
- Sitemap.xml with all articles
- hreflang tags for internationalization
- **Separate from API repo** — content lives in UI repo

---

## Part 6: Source version tracking

Track which version of each data source we used:

```sql
CREATE TABLE data_sources (
  id INTEGER PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,          -- "dr5hn" | "geonames" | "iana_tzdb" | "cldr" | "natural_earth"
  url TEXT,                            -- source homepage
  version TEXT NOT NULL,               -- "2026-07-29"
  license TEXT,                        -- "MIT" | "CC-BY-4.0" | "public-domain"
  last_fetched_at TIMESTAMP,
  last_fetched_rows INTEGER,
  notes TEXT
);

CREATE TABLE import_history (
  id INTEGER PRIMARY KEY,
  data_source_id INTEGER,              -- FK to data_sources
  started_at TIMESTAMP,
  completed_at TIMESTAMP,
  rows_imported INTEGER,
  rows_skipped INTEGER,
  rows_errored INTEGER,
  error_message TEXT,
  FOREIGN KEY (data_source_id) REFERENCES data_sources(id)
);
```

---

## Part 7: Data refresh strategy

| Source | Frequency | Method |
|---|---|---|
| dr5hn | monthly | curl + git pull + re-import |
| GeoNames | monthly | download + re-import |
| IANA tzdb | on release (every 3-6 months) | download tarball + re-import |
| CLDR | quarterly | download + re-import |

Implementation: `scripts/refresh.sh` that runs all imports + posts to `import_history` table.

---

## Part 8: Open source licenses

| Source | License | Attribution required |
|---|---|---|
| dr5hn/countries-states-cities-database | ODbL | Yes |
| GeoNames | CC-BY-4.0 | Yes |
| IANA tzdb | public-domain | No (but appreciated) |
| Unicode CLDR | Unicode License | Yes |
| Natural Earth | public-domain | No |
| ISO 3166 | paid | No (just codes) |

We need an `/attribution` page in the UI repo that lists all sources + links.

---

## Part 9: Acceptance criteria

This spec is "done" when:
1. ✅ All 10 tables exist with the schema above
2. ✅ 250 countries loaded
3. ✅ 5,308 administrative_regions loaded
4. ✅ 152,970 cities loaded
5. ✅ ~450 timezones loaded (IANA canonical + aliases)
6. ✅ `place_names` populated for at least 3 languages per major city
7. ✅ Search returns correct results for all 17 functional test cases
8. ✅ Postman collection exercises all endpoints
9. ✅ DST transitions handled correctly in time calculations
10. ✅ International Date Line handled (UTC-12 vs UTC+14 same date)
11. ✅ Half-hour and quarter-hour zones return correct offsets
12. ✅ User education content: 10+ articles live
13. ✅ Data sources + import_history tables tracking every import

---

## Reference: Related docs

- `docs/PLAN-phased-implementation.md` — phased breakdown of this spec
- `docs/PLAN-db-cleanup-rebuild.md` — Phase 1 (DB rebuild)
- `docs/PLAN-features-region-search-and-meeting-planner.md` — feature plan
- `docs/PLAN-source-data-alignment.md` — data source alignment
