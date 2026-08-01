# Feature Plan: Region Search + Meeting Planner

Based on timeanddate.com research + user screenshots (2026-07-31).

User's data needs (from the "Current Time" info card screenshot):

```
Friday, 31 July 2026, 22:35:11 CDT
Time Zone    America/Chicago
GMT Offset   UTC/GMT -5.00 hours
DST          Yes
Country      United States 🇺🇸
City         (name)
Region       (region name)
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
│  ●  23:32:03.74                │   ← green dot = live
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
| **Country** | chips for each country in selected sub-region | `countries` table |
| **State/Province** | chips for each state in selected country | `states` table (NEW — not yet built) |
| **Search** | type-ahead: city name OR country name | `cities.name LIKE` or FTS5 |
| **Sort** | Popular / Alphabetical / Country | computed at query time |

### Data per city card

| Field | Source | Example |
|---|---|---|
| City name | `cities.name` | "New York City" |
| State code | `cities.state_code` | "NY" |
| Country flag | `countries.cca2` → flag emoji | 🇺🇸 |
| Live time (HH:MM:SS.ss) | computed from `cities.timezone` + current time | "23:32:03.74" |
| IANA timezone | `cities.timezone` | "America/New_York" |
| Relative day | computed: today / yesterday / tomorrow | "today" |
| Offset from selected | computed: city_offset - reference_offset | "same" or "-3 H" |
| Live indicator | always true (green dot) | ● |

### MVP scope (user said: "other than us cities we redirect to coming soon page")

- The entire filter UI is built and works (region/sub-region/country/state)
- The cities list is built
- **BUT:** clicking a non-US city redirects to `/coming-soon` page
- US cities work normally (go to city detail page)
- This is a US-first launch

### What we need to build

1. **`regions` table** (6 rows): `code, name`
2. **`subregions` table** (22 rows): `code, name, region_code`
3. **Add `region_code` + `subregion_code` FK columns to `countries`** (backfill from current `un_region` / `un_subregion`)
4. **`states` table** (~5,308 rows): `id, country_code, code, name, ascii_name, lat, lon, timezone`
5. **Add 8 missing countries** to bring count to 250 (from current 242)
6. **API endpoints** (all with full Swagger UI):
   - `GET /api/v1/regions` — list 6 regions
   - `GET /api/v1/regions/:code/subregions` — list sub-regions in a region
   - `GET /api/v1/subregions/:code/countries` — list countries in a sub-region
   - `GET /api/v1/countries/:cca2/states` — list states/provinces in a country
   - `GET /api/v1/cities?region=X&subregion=Y&country=Z&state=W` — filtered list
   - `GET /api/v1/cities/search?q=...` — full-text search (already planned)
   - `GET /api/v1/cities/:id` — single city with live time + offset + DST + flag
7. **UI component:** `<CityFilter>` with cascading dropdowns + grid of `<CityCard>` components

### Data fields for `GET /api/v1/cities/:id` (matches user's screenshot)

```json
{
  "id": 5128581,
  "name": "New York City",
  "state": { "code": "NY", "name": "New York" },
  "country": { "cca2": "US", "name": "United States", "flag": "🇺🇸" },
  "region": "Americas",
  "subregion": "Northern America",
  "timezone": "America/New_York",
  "live": {
    "local_time": "2026-07-31T23:32:03.740-04:00",
    "formatted": "Friday, 31 July 2026, 23:32:03.74 EDT",
    "abbreviation": "EDT",
    "gmt_offset": "UTC/GMT -4.00 hours",
    "is_dst": true,
    "day": "today"
  }
}
```

The `live` object is computed at query time from the IANA timezone. It includes EVERY field from the user's "Current Time" info card.

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

### Color legend

| Color | Meaning | Hours |
|---|---|---|
| 🟪 Purple | Work hours | 8am – 5pm (configurable in settings) |
| 🟪 Light purple | Sleep | 11pm – 6am |
| 🟪 Pink | Weekend | Saturday + Sunday |
| 🟦 (no fill) | Normal | Other hours |
| "Next day" badge | Hour rolls into next day (after midnight) | Right-edge cell |

### 7-day grid (per row = city, per column = hour)

```
        WED THU FRI SAT SUN MON TUE
        29  30  31  1   2   3   4

San    12  12  12  12  12  12  12
Ant.   am  am  am  am  am  am  am
       ... (24 hours per day, 7 days = 168 cells per row)
       ... with color coding per hour
       ... and a "10" cell highlighted (selected time)
```

### Click any hour for details

Click a cell → "Meeting details" page shows:
- Local time in each selected city for that hour
- UTC equivalent
- Notes like "3 of 3 cities are in work hours" or "1 city is asleep"

### Date picker + 12h/24h toggle

- Date selector (default: today)
- 12h / 24h toggle (button on right)
- Day navigation arrows (← →)
- "Previous day / Today / Next day" quick nav

### Data per city in the chips

| Field | Source | Example |
|---|---|---|
| City name | typed by user / autocomplete | "San Antonio" |
| Abbreviation | computed from timezone | "CDT" |
| Current time (HH:MM:SS.ss) | computed from timezone | "10:30:29.27 PM" |
| Green dot | always live | ● |
| ✕ to remove | UI only | (remove from list) |

### The "Current Time" info card (screenshot 3) — fields needed for each city

| Field | Source | Computed how |
|---|---|---|
| **Date/time string** | `new Date().toLocaleString('en-US', {...})` | "Friday, 31 July 2026, 22:35:11 CDT" |
| **Time Zone** | IANA name from `cities.timezone` | "America/Chicago" |
| **GMT Offset** | `tz.utcoffset(now).total_seconds() / 3600` | "UTC/GMT -5.00 hours" |
| **DST** | `tz.dst(now) is not None` | "Yes" / "No" |
| **Country** | join `cities → countries` | "United States" |
| **Flag** | emoji from `countries.cca2` | 🇺🇸 |
| **City** | `cities.name` | (city name) |
| **Region** | join `cities → countries → regions` | (region name) |

### The 7-day grid is CLIENT-SIDE computed

The API returns: city + timezone + offset + is_dst
The browser computes: for each hour of each of the 7 days, what is the local time in this city?
The browser colors the cell based on: is it work/sleep/weekend/next-day?

**No additional API calls needed** for the grid — the client has all the data it needs after fetching the city.

### API for the meeting planner

```typescript
// Add multiple cities to a meeting
// (We don't need a new endpoint — just reuse GET /api/v1/cities/:id)
GET /api/v1/cities/5128581   // New York City → returns { timezone: "America/New_York", ... }
GET /api/v1/cities/4726206   // San Antonio → { timezone: "America/Chicago", ... }
GET /api/v1/cities/1275004   // Hyderabad → { timezone: "Asia/Kolkata", ... }

// Client computes the grid locally.
// No "meeting" entity needed for MVP.
```

The "Settings" panel (work hours, sleep hours, etc.) is also client-side only.

### "Coming soon" redirect logic (per user MVP)

```typescript
// In the city detail page handler:
if (city.country.cca2 !== 'US') {
  return redirect('/coming-soon?country=' + city.country.cca2);
}
// US cities → render the city page
```

---

## Combined MVP scope

### What we build now (Phase 2-3, post-cities-API)

1. Add 8 missing countries (250 total)
2. Add `regions` + `subregions` tables (6 + 22 rows)
3. Add `states` table (5,308 rows from dr5hn)
4. Add 6 API endpoints for hierarchical search
5. Update city schema to include region/subregion
6. Build `<CityFilter>` + `<CityCard>` UI components
7. Build the meeting planner (client-side grid, no new API)

### What we skip for MVP

- City detail pages for non-US cities → "coming soon"
- User accounts / saved meetings (use localStorage instead)
- Calendar export (can add later)
- Time zone map visualization (defer to Phase 4)

### Estimated effort

- DB work (countries + regions + subregions + states): 2-3 days
- API endpoints: 1-2 days (parallel with DB)
- UI components: 2-3 days
- Meeting planner UI: 1-2 days

**Total: ~7-10 days** for both features in MVP form.

---

## Open questions for the user

1. **Country data:** Add all 8 missing territories now? (yes/no)
2. **States data:** Use dr5hn's 5,308 states, or just the US states (~51) for MVP?
3. **Cities scope:** Keep cities15000 (33,945) or switch to dr5hn (152,970)?
4. **Meeting planner:** localStorage for saved meetings, or build user accounts?
5. **Coming soon:** how to detect non-US — by `country.cca2 !== 'US'` or by region? (US includes territories like Puerto Rico, Guam — should they redirect too?)
6. **Date display:** "Friday, 31 July 2026" or "Jul 31, 2026" or both? (user's locale vs system locale)
7. **Milliseconds:** always show ".27" or only when zoomed in? (2 digits is the user request)
