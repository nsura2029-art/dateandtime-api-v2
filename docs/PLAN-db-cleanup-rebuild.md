# Plan: Full DB Cleanup & Rebuild

**User decision (2026-07-31):** Replace + cleanup complete DB. We don't need any of the existing data.

## What "full cleanup" means

Drop all current tables. Re-create schema from scratch using only:
- **dr5hn** (countries-states-cities-database) — single source for geography
- **IANA tzdb-2026c** — single source for timezones

### Decision points (need user input)

#### 1. Curated data: keep or drop?

| Data | Current | Source | Recommendation |
|---|---|---|---|
| `cities` | 33,945 | GeoNames cities15000 | **DROP** (replace with 152,970 from dr5hn) |
| `countries` | 242 | mledoze | **DROP** (replace with 250 from dr5hn) |
| `timezones` | 408 | Python zoneinfo | **DROP** (re-validate against IANA tzdb-2026c, ~450) |
| `onthisday` | 50 | Wikipedia curation | **DECIDE** — curated, but small effort to re-curate |
| `city_aliases` | 206 | Historical name redirects | **DECIDE** — curated, but easy to re-derive from dr5hn |

**My recommendation: DROP everything.** Re-derive aliases from dr5hn (it has `alt_name` per city). Skip onthisday for now (not in MVP scope, can re-add later).

#### 2. New schema (final)

```sql
-- 6 regions (Africa, Americas, Asia, Europe, Oceania, Antarctica)
CREATE TABLE regions (
  id INTEGER PRIMARY KEY,        -- 1..6
  code TEXT UNIQUE NOT NULL,     -- 'AF', 'AM', 'AS', 'EU', 'OC', 'AN'
  name TEXT NOT NULL             -- 'Africa', 'Americas', 'Asia', etc.
);

-- 22 sub-regions (Northern America, Western Europe, etc.)
CREATE TABLE subregions (
  id INTEGER PRIMARY KEY,        -- 1..22
  code TEXT UNIQUE NOT NULL,     -- e.g. '021' (UN M49 code)
  name TEXT NOT NULL,
  region_id INTEGER NOT NULL,    -- FK to regions
  FOREIGN KEY (region_id) REFERENCES regions(id)
);

-- 250 countries
CREATE TABLE countries (
  id INTEGER PRIMARY KEY,        -- dr5hn ID
  cca2 TEXT UNIQUE NOT NULL,     -- 'US', 'IN', 'JP'
  cca3 TEXT,                     -- 'USA', 'IND', 'JPN'
  ccn3 TEXT,                     -- '840', '356', '392'
  cioc TEXT,                     -- 'USA', 'IND', 'JPN'
  name TEXT NOT NULL,
  official_name TEXT,
  capital TEXT,
  region_id INTEGER NOT NULL,    -- FK to regions
  subregion_id INTEGER NOT NULL, -- FK to subregions
  currency_code TEXT,
  currency_name TEXT,
  currency_symbol TEXT,
  phone_code TEXT,
  languages TEXT,                -- comma-separated ISO 639-1 codes
  latitude REAL,
  longitude REAL,
  area_km2 REAL,
  population INTEGER,
  flag_emoji TEXT,               -- 🇺🇸 🇮🇳 🇯🇵
  tld TEXT,
  un_member INTEGER,             -- 0/1
  landlocked INTEGER,            -- 0/1
  independent INTEGER,           -- 0/1
  start_of_week TEXT,            -- 'monday' / 'sunday'
  borders TEXT,                  -- comma-separated cca2 of neighbors
  canonical_timezones TEXT,      -- comma-separated IANA names
  FOREIGN KEY (region_id) REFERENCES regions(id),
  FOREIGN KEY (subregion_id) REFERENCES subregions(id)
);

-- 5,308 states/provinces
CREATE TABLE states (
  id INTEGER PRIMARY KEY,        -- dr5hn ID
  country_id INTEGER NOT NULL,   -- FK to countries
  code TEXT,                     -- 'CA', 'NY' (ISO 3166-2)
  name TEXT NOT NULL,
  ascii_name TEXT,
  latitude REAL,
  longitude REAL,
  type TEXT,                     -- 'state', 'province', 'territory', etc.
  iso2 TEXT,                     -- ISO 3166-2 code
  population INTEGER,
  timezone TEXT,                 -- IANA timezone
  FOREIGN KEY (country_id) REFERENCES countries(id)
);

-- 152,970 cities
CREATE TABLE cities (
  id INTEGER PRIMARY KEY,        -- dr5hn ID
  name TEXT NOT NULL,
  ascii_name TEXT,
  country_id INTEGER NOT NULL,   -- FK to countries
  state_id INTEGER,              -- FK to states (NULL if no state)
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  timezone TEXT NOT NULL,        -- FK to timezones
  population INTEGER,
  is_capital INTEGER DEFAULT 0,
  is_state_capital INTEGER DEFAULT 0,
  is_country_capital INTEGER DEFAULT 0,
  elevation INTEGER,
  feature_code TEXT,             -- GeoNames feature code
  FOREIGN KEY (country_id) REFERENCES countries(id),
  FOREIGN KEY (state_id) REFERENCES states(id),
  FOREIGN KEY (timezone) REFERENCES timezones(id)
);

-- ~450 timezones (IANA canonical + aliases)
CREATE TABLE timezones (
  id TEXT PRIMARY KEY,           -- IANA name, e.g. 'America/New_York'
  canonical_id TEXT,             -- points to canonical IANA name (NULL if id is canonical)
  region TEXT,                   -- 'America', 'Europe', 'Asia', etc.
  subregion TEXT,                -- 'Northern America', 'Western Europe', etc.
  city TEXT,                     -- representative city (e.g. 'New York')
  country_codes TEXT,            -- comma-separated cca2
  latitude REAL,
  longitude REAL,
  current_offset INTEGER,        -- UTC offset in minutes
  current_abbreviation TEXT,     -- 'EST', 'EDT', 'GMT+5:30'
  is_dst INTEGER,                -- 0/1
  description TEXT
);

-- Curated historical events (re-added if user wants)
-- 50 onthisday rows
-- 206 city_aliases rows (or re-derive from dr5hn alt_name)
```

#### 3. Coming-soon logic (per user decision 5)

Only the 50 US states + DC get full data. The middleware:

```typescript
const US_STATES_AND_DC = new Set([
  'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
  'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
  'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
  'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
  'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
  'DC'
]);

// In /cities/:id handler:
if (city.state_code && !US_STATES_AND_DC.has(city.state_code)) {
  return c.redirect('/coming-soon?city=' + city.id);
}
```

**Note:** This requires the `state_code` column on cities. dr5hn has it (e.g., for US cities it's the 2-letter code like 'NY'). For non-US it varies (ISO 3166-2 codes).

---

## Implementation order (5-7 days of work)

### Day 1: Schema + data layer

1. **Migration 100 (full cleanup):**
   - DROP all current tables
   - CREATE new tables: regions, subregions, countries, states, cities, timezones
   - This is a DESTRUCTIVE migration — no rollback

2. **Seed script 1: regions + subregions**
   - From dr5hn `regions.json` + `subregions.json` (6 + 22 rows)
   - 30 min

3. **Seed script 2: countries**
   - From dr5hn `countries.json` (250 rows)
   - Includes region + subregion FK
   - 1 hour

4. **Seed script 3: states**
   - From dr5hn `countries+states+cities.json` — extract states (5,308 rows)
   - 2 hours (parse the 46MB JSON carefully)

5. **Seed script 4: timezones**
   - From IANA tzdb-2026c `zone1970.tab` + `backward` aliases
   - ~450 rows total
   - 2 hours

6. **Seed script 5: cities**
   - From dr5hn `countries+states+cities.json` — extract cities (152,970 rows)
   - 4-6 hours (big file, FK resolution)

### Day 2: API code

7. **New route: `GET /api/v1/regions` + `GET /api/v1/regions/:code/subregions`**
   - With full Swagger UI
   - Tests

8. **New route: `GET /api/v1/subregions/:code/countries`**
   - With full Swagger UI
   - Tests

9. **Update `GET /api/v1/countries/:cca2` + add `/states`**
   - Returns full country info + list of states
   - With full Swagger UI
   - Tests

10. **Update `GET /api/v1/cities/:id` with live data**
    - Returns: name, state, country, region, subregion, timezone, live time, offset, DST, flag
    - All "Current Time" info card fields per the user's screenshot
    - With full Swagger UI
    - Tests

11. **Update `GET /api/v1/cities` with full filter support**
    - Filters: region, subregion, country, state, search
    - Pagination + sort
    - With full Swagger UI
    - Tests

### Day 3: Coming-soon + polish

12. **Middleware: US-state gate**
    - Redirect non-US-state cities to /coming-soon
    - Test that PR, GU, VI, AS, MP all redirect
    - Test that all 50 states + DC pass through

13. **Re-deploy dev Worker**
    - Apply all migrations
    - Re-seed data
    - Deploy

### Day 4-5: Meeting planner UI (in UI repo, separate)

14. **`<MeetingPlanner>` component**
    - City chips with live time
    - 7-day grid with color coding
    - localStorage for saved meetings

15. **`<CityFilter>` + `<CityCard>` components**
    - Cascading dropdowns
    - Card grid

---

## Risk analysis

### High risk
- **D1 DESTRUCTIVE migration** — once 100 runs, no rollback. The data is gone.
  - **Mitigation:** Save D1 export to a file BEFORE running migration 100. We can restore from this if needed.
- **152,970 cities insert** — 46MB JSON parse, FK resolution, batch inserts. Could take 30-60 min.
  - **Mitigation:** Use BATCH_SIZE that respects the 100-var per-statement D1 limit. Test on dev first.
- **dr5hn schema has fields we don't have** — we need to map dr5hn's schema to ours
  - **Mitigation:** Write a clear schema mapping table in the seed script

### Medium risk
- **dr5hn doesn't have alt names for all cities** — we lose the 206 city_aliases
  - **Mitigation:** Re-derive from dr5hn's `alternate_names` field (if present)
- **Some IANA timezones are aliases** — our 408 might have been a mix of canonical + aliases. After re-validation, count might differ.
  - **Mitigation:** Document the change. We have ~450 expected.

### Low risk
- **The 5 endpoint spec entries that aren't implemented yet** (countries, timezones, popular, holidays, etc.) will all need to be implemented for the new schema
  - **Mitigation:** Sequence work so each endpoint is built and tested before moving on

---

## What I need from you (3 questions)

1. **Confirm: drop everything?** Including onthisday + city_aliases (50 + 206 curated rows)?
2. **Migration 100 is DESTRUCTIVE** — should I save a D1 backup first, or just go for it?
3. **Order of operations** — should I:
   a) Do schema first (Day 1), then API code (Day 2), then deploy (Day 3)?
   b) Or do it all on one feature branch and deploy at the end?

My recommendation: **(1) drop everything, (2) save backup, (3) do it all on one branch with deploy at the end.**

If yes, I'll create `feature/db-cleanup-and-rebuild` and start with migration 100 + seed scripts.
