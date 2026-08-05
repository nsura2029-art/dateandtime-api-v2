# Feature Plan: Region Search + Meeting Planner (FINAL)

**Status:** Decisions made 2026-07-31, ready to implement
**Source:** timeanddate.com research + user screenshots
**IANA data:** `tzdb-2026c` (attached)

---

## User decisions (2026-07-31)

| # | Question | Decision |
|---|---|---|
| 1 | Add 8 missing countries (250 total)? | **YES** |
| 2 | All 5,308 states (dr5hn) or US-only? | **ALL 5,308 states** (from dr5hn) |
| 3 | Keep 33,945 cities (cities15000) or switch to 152,970 (dr5hn)? | **FULL 152,970 cities** (dr5hn) |
| 4 | Saved meetings storage? | **localStorage for MVP, Clerk auth later** |
| 5 | "Coming soon" logic — include US territories? | **YES — include US territories (PR, GU, VI, AS, MP) in redirect** |
| 6 | Date display format? | **LONG** ("Friday, 31 July 2026") |
| 7 | Millisecond display (`.27`)? | **ALWAYS show with green dot** (live indicator) |

---

## "Coming soon" redirect logic (per decision 5)

ONLY the 50 US states + DC get full city pages. EVERYTHING ELSE redirects to `/coming-soon`:

```typescript
// In the city detail page handler
const US_STATES_AND_DC = new Set([
  'AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA',
  'HI', 'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD',
  'MA', 'MI', 'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ',
  'NM', 'NY', 'NC', 'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC',
  'SD', 'TN', 'TX', 'UT', 'VT', 'VA', 'WA', 'WV', 'WI', 'WY',
  'DC'
]);

if (!US_STATES_AND_DC.has(city.state_code) || city.country.cca2 !== 'US') {
  return redirect('/coming-soon?city=' + city.id);
}
```

This means:
- New York, NY (US) → ✅ full page
- San Juan (PR, US territory) → ❌ coming soon
- Mexico City, MX (foreign) → ❌ coming soon
- Tokyo, JP (foreign) → ❌ coming soon

---

## Data per city card (always shown, with green dot + `.27` millis)

| Field | Source | Example |
|---|---|---|
| City name | `cities.name` | "New York City" |
| State code | `cities.state_code` | "NY" |
| Country flag | `countries.cca2` → emoji | 🇺🇸 |
| Live time (HH:MM:SS.ss) | `Date.now()` formatted in `cities.timezone` | "23:32:03.74" |
| IANA timezone | `cities.timezone` | "America/New_York" |
| Abbreviation | computed | "EDT" |
| Offset | `tz.utcoffset(now).total_seconds()/3600` | "UTC/GMT -4.00 hours" |
| DST | `tz.dst(now) != null` | "Yes" |
| Day indicator | relative to "today" | "today" / "yesterday" / "tomorrow" |
| Green dot | always | ● |

### Time format (per decisions 6 + 7)

```
Friday, 31 July 2026, 22:35:11 CDT   ← long date format (info card)

23:32:03.74                          ← city card time, ALWAYS with .27 millis
                                      + green dot indicator (●)
```

Implementation:
```typescript
const now = new Date();
const localTime = now.toLocaleString('en-US', {
  weekday: 'long',      // Friday
  day: 'numeric',       // 31
  month: 'long',        // July
  year: 'numeric',      // 2026
  hour: '2-digit',      // 22
  minute: '2-digit',    // 35
  second: '2-digit',    // 11
  hour12: false,        // 24h for the info card; 12h for city cards per UI toggle
  timeZone: city.timezone,
  timeZoneName: 'short' // CDT
});
// → "Friday, 31 July 2026, 22:35:11 CDT"

// For city card with .27 millis:
const timeStr = now.toLocaleTimeString('en-US', {
  hour: '2-digit', minute: '2-digit', second: '2-digit', hour12: true,
  timeZone: city.timezone
});
const millis = String(now.getMilliseconds()).padStart(3, '0').slice(0, 2); // "27"
const cardTime = `${timeStr.slice(0, -3)}.${millis} ${timeStr.slice(-2)}`;
// → "10:30:29.27 PM"
```

---

## Feature 1: Region/Sub-region/Country/State/City Hierarchical Search

**Source:** timeanddate.com "Time Zone List" page
**URL pattern:** https://www.timeanddate.com/time/current-number-time-zones.html

### User flow

```
┌─────────────────────────────────────────────────────────────┐
│ Search: [Tokyo, Lagos, Reykjavik...]              SORT: Popular ▼ │
└─────────────────────────────────────────────────────────────┘

REGION:    [ All ] [ Africa ] [ Asia ] [ Europe ] [ N. America*] [ Oceania ] [ S. America ]
           ALL time zones                                            UTC-10 to -4

SUB-REGION: [ Caribbean ] [ Central America ] [ Northern America* ]
            UTC-4 to -5    UTC-6               UTC-10 to -4

┌─ COUNTRY (3) ──────────────────┐  ┌─ STATE / PROVINCE (0) ─────────┐
│  (Canada) (Mexico) (US*)       │  │  No states in this country.   │
└────────────────────────────────┘  └────────────────────────────────┘

Showing 100 of 3,407 cities                                    Loading...

┌─ New York City [NY] 🇺🇸 ──────┐
│  ●  23:32:03.74                │   ← green dot = live, ALWAYS .27 millis
│  America/New_York              │
│  today   same                  │   ← offset from selected city
└────────────────────────────────┘
... (more cities in grid)
```

### Filters (cascading dropdowns)

| Filter | Options | Source |
|---|---|---|
| **Region** | All, Africa, Asia, Europe, N. America, Oceania, S. America, Antarctica | `regions` table (6 rows) |
| **Sub-region** | depends on region (e.g. N. America → Caribbean, Central America, Northern America) | `subregions` table (22 rows) |
| **Country** | chips for each country in selected sub-region | `countries` table (250 rows after fix) |
| **State/Province** | chips for each state in selected country | `states` table (5,308 rows) |
| **Search** | type-ahead: city name OR country name | `cities.name LIKE` or FTS5 |
| **Sort** | Popular / Alphabetical / Country | computed at query time |

### MVP scope (per decision 5)

- The entire filter UI is built and works (region/sub-region/country/state)
- The cities list is built
- **BUT:** clicking a non-US-state city redirects to `/coming-soon`
- US states (50 + DC) work normally
- This is a US-first launch

### What we need to build

1. **Add 8 missing countries** (250 total) — 1 hour
2. **`regions` table** (6 rows from dr5hn) — 30 min
3. **`subregions` table** (22 rows from dr5hn) — 30 min
4. **Add `region_code` + `subregion_code` FK columns to `countries`** — 1 hour
5. **`states` table** (5,308 rows from dr5hn) — 2 hours
6. **Cities table migration to dr5hn's 152,970 cities** (or keep current 33,945 + add dr5hn's 119,025) — 4-6 hours
   - Decision needed: REPLACE or MERGE?
7. **6 API endpoints** (all with full Swagger UI):
   - `GET /api/v1/regions` — list 6 regions
   - `GET /api/v1/regions/:code/subregions` — list sub-regions in a region
   - `GET /api/v1/subregions/:code/countries` — list countries in a sub-region
   - `GET /api/v1/countries/:cca2/states` — list states/provinces in a country
   - `GET /api/v1/cities?region=X&subregion=Y&country=Z&state=W` — filtered list
   - `GET /api/v1/cities/search?q=...` — full-text search (already planned)
   - `GET /api/v1/cities/:id` — single city with live time + offset + DST + flag
8. **UI component:** `<CityFilter>` with cascading dropdowns + grid of `<CityCard>` components

### IANA tzdb-2026c — what we got from the user

| File | Count | Use |
|---|---|---|
| `zone1970.tab` | 312 timezones | Canonical IANA timezone list |
| `iso3166.tab` | 249 countries | Country code → name |
| `backward` | 256 aliases | Alias → canonical mapping |
| `zonenow.tab` | 90 zones | "Currently used" only (subset) |

For our `timezones` table: use `zone1970.tab` (312 canonical) + `backward` aliases (256) → ~400-450 total timezones.

Our current 408 is close. We may need to re-validate against the latest IANA 2026c release.

---

## Feature 2: Timezone Converter / Meeting Planner

**Source:** timeanddate.com "Meeting Planner" page
**URL pattern:** https://www.timeanddate.com/worldclock/meeting.html

### User flow

```
┌─────────────────────────────────────────────────────────────┐
│ [● Work hours (8am-5pm)] [● Sleep (11pm-6am)] [● Weekend] [● Next day] │
└─────────────────────────────────────────────────────────────┘

[+ Place or timezone — type a city]   [Settings]  [🔗 COPY LINK]

[SAT] [SAN ANTONIO  ●10:30:29.27 PM ✕] [Miami  ●11:30:29.27 PM ✕] [Hyderabad ●9:00:29.27 AM ✕]
```

### Data per chip (always with .27 millis + green dot)

| Field | Source | Example |
|---|---|---|
| City name | typed by user / autocomplete | "San Antonio" |
| Abbreviation | `now.tzname()` in `cities.timezone` | "CDT" |
| Live time (HH:MM:SS.ss) | `Date.now()` in `cities.timezone` | "10:30:29.27 PM" |
| Green dot | always | ● |
| ✕ to remove | UI only | (remove from list) |

### 7-day grid (CLIENT-SIDE)

The grid is **fully computed in the browser** from the city's IANA timezone:

```
        WED THU FRI SAT SUN MON TUE
        29  30  31  1   2   3   4

San    12  12  12  12  12  12  12
Ant.   am  am  am  am  am  am  am
       ... (24 hours per day, 7 days = 168 cells per row)
       ... with color coding per hour
       ... and a "10" cell highlighted (selected time)
```

No additional API calls needed — the browser has all the data after fetching each city.

### Settings (localStorage, per decision 4)

```typescript
interface MeetingSettings {
  workHours: { start: 8, end: 17 },     // 8am-5pm
  sleepHours: { start: 23, end: 6 },    // 11pm-6am
  hour12: true,
  weekendDays: [0, 6],                  // Sun + Sat
  showWorkHours: true,
  showSleep: true,
  showWeekend: true,
  showNextDay: true,
  defaultDuration: 60,                  // minutes
}
```

Saved meetings:
```typescript
interface SavedMeeting {
  id: string;
  name: string;
  cities: Array<{ id: number; name: string; timezone: string; }>;
  createdAt: string;
  lastUsedAt: string;
}
// Stored in localStorage under key 'tdp.savedMeetings'
// Migrate to Clerk user accounts in Phase 4
```

### API for the meeting planner (no new endpoints needed)

```typescript
// We just reuse GET /api/v1/cities/:id
// Browser does the rest

GET /api/v1/cities/5128581  // New York City → { timezone: "America/New_York", ... }
GET /api/v1/cities/4726206  // San Antonio → { timezone: "America/Chicago", ... }
GET /api/v1/cities/1275004  // Hyderabad → { timezone: "Asia/Kolkata", ... }
```

---

## Combined MVP scope (final, with decisions applied)

### Data layer (DB migrations)

1. **Migration 011:** Add 8 missing countries (250 total)
2. **Migration 012:** Create `regions` table (6 rows)
3. **Migration 013:** Create `subregions` table (22 rows, FK to regions)
4. **Migration 014:** Add `region_code` + `subregion_code` to countries
5. **Migration 015:** Create `states` table (5,308 rows, FK to countries)
6. **Migration 016:** Cities table — decide: REPLACE 33,945 → 152,970, or MERGE? **(need decision)**
7. **Migration 017:** Re-validate `timezones` table against IANA tzdb-2026c (312 + 256 aliases = ~400-450)

### API layer (one endpoint per commit, full Swagger UI)

1. `GET /api/v1/regions` — list 6 regions
2. `GET /api/v1/regions/:code/subregions` — sub-regions
3. `GET /api/v1/subregions/:code/countries` — countries
4. `GET /api/v1/countries/:cca2/states` — states
5. `GET /api/v1/cities?region=X&subregion=Y&country=Z&state=W` — filtered list
6. `GET /api/v1/cities/:id` — single city with FULL live data (date, timezone, offset, DST, country, flag, region, state)
7. `GET /api/v1/cities/search?q=...` — full-text search

### UI layer

1. `<CityFilter>` — cascading dropdowns (region → sub-region → country → state)
2. `<CityCard>` — name, state code, flag, green dot, `.27` time, IANA timezone, offset
3. `<MeetingPlanner>` — city chips + 7-day grid with color coding
4. `<ComingSoon>` — redirect target with "We're working on [country/territory]" message
5. localStorage helpers: `getSettings()`, `saveSettings()`, `getSavedMeetings()`, `saveMeeting()`

### Estimated effort (with decisions applied)

- DB work: 2-3 days (incl. decide REPLACE vs MERGE for cities)
- API endpoints: 1-2 days
- UI components: 2-3 days
- Meeting planner UI: 1-2 days
- IANA re-validation: 4 hours (just regenerate timezones table)

**Total: ~7-10 days for both features in MVP form.**

---

## ONE remaining open question for the user

### Cities: REPLACE (33,945 → 152,970) or MERGE (add 119,025 to existing)?

**Option A — REPLACE:**
- Drop current 33,945 cities (GeoNames cities15000)
- Insert 152,970 cities (dr5hn)
- Cleaner, single source of truth
- Risk: GeoNames has better data quality (population, lat/lon precision, alternate names)
- Time: 4-6 hours to migrate

**Option B — MERGE:**
- Keep 33,945 GeoNames cities
- Add 119,025 dr5hn cities (those not already in GeoNames)
- 152,970 total, but with mixed source quality
- Time: 6-8 hours (dedup logic)

**My recommendation: Option A (REPLACE).** dr5hn is actively maintained (last update July 29, 2026), GeoNames cities15000 is older. Single source = simpler queries, cleaner data. We lose some GeoNames population data but dr5hn has it too.

**Your call?**

---

## File inventory for this feature

| File | Purpose |
|---|---|
| `migrations/011_add_8_countries.sql` | 8 missing territories |
| `migrations/012_create_regions.sql` | 6 regions |
| `migrations/013_create_subregions.sql` | 22 sub-regions |
| `migrations/014_country_region_fks.sql` | FK columns on countries |
| `migrations/015_create_states.sql` | 5,308 states |
| `migrations/016_cities_full_or_merge.sql` | 152,970 cities (TBD: REPLACE or MERGE) |
| `migrations/017_iana_2026c_timezones.sql` | Re-validated timezones |
| `src/routes/regions.ts` | `GET /api/v1/regions[/:code/subregions]` |
| `src/routes/subregions.ts` | `GET /api/v1/subregions/:code/countries` |
| `src/routes/countries.ts` | `GET /api/v1/countries/:cca2/states` (already planned) |
| `src/routes/cities.ts` | filtered list + by-id (already planned) |
| `src/lib/cities.ts` | Cities DAO with new columns |
| `src/lib/regions.ts` | Regions + subregions DAO |
| `src/lib/states.ts` | States DAO |
| `scripts/seed/011_add_8_countries.py` | seed for countries |
| `scripts/seed/012_regions_subregions.py` | seed for regions + subregions |
| `scripts/seed/015_states.py` | seed for states from dr5hn |
| `scripts/seed/016_cities_full.py` | seed for cities (REPLACE or MERGE) |
| `scripts/seed/017_iana_2026c_timezones.py` | re-validate timezones from IANA |
| `src/middleware/us-state-gate.ts` | redirect non-US-states to /coming-soon |
| `tests/regions.test.ts` | tests for new endpoints |
| `tests/cities-live-fields.test.ts` | test that /cities/:id returns the full Current Time fields |
