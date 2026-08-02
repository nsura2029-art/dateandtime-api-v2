# Timezone Core Logic

> How `dateandtime-api-v2` assigns timezones to cities.
> Per spec `3849c8b4__*.md` §1 (mandate), §8.2 (bans), §14.1 (Null Island),
> §25 (data quality), §28 (manual override documentation).

## TL;DR

Every city has a `timezone` (IANA ID) and a `timezone_confidence` (one of
`high`, `medium`, `low`, `unresolved`). Confidence reflects how sure we are
the timezone is correct, and is derived from the source of the assignment:

| Confidence | Source | Meaning |
|---|---|---|
| **high** | `polygon:timezonefinder` | Polygon-verified (lat/lon → IANA zone) |
| **medium** | `dr5hn:default` | dr5hn source, not polygon-verified |
| **low** | `manual:override` | Hand-corrected, documented per §28 |
| **unresolved** | `dr5hn:unverified` | Bad coordinates (Null Island) |

## Source of truth hierarchy

Per spec §1:

> "A city timezone must be assigned from the city's latitude and longitude
> using a trusted geographic timezone-boundary dataset. Country, state,
> province, county, UTC offset, or timezone abbreviation must not be used as
> the sole source of truth."

We use the following precedence:

1. **Polygon (timezone-boundary-builder)** — `tzfpy` 8.2.5
   - Source: https://github.com/evansiroky/timezone-boundary-builder
   - For 2,983 cities, polygon-derived TZ differed from dr5hn — polygon wins
2. **dr5hn (countries-states-cities-database)** — primary source
   - Source: https://github.com/dr5hn/countries-states-cities-database
   - 149,952 cities match polygon-derived TZ (medium confidence)
3. **Manual override** — 13 cities
   - Atikokan, Creston, Lakshadweep, Persian Gulf, Galapagos, Aegean Sea,
     Tuamotu, Marquesas, Society Islands (×3), Reunion
   - Each override documented per spec §28 (see migration 125)
4. **Null Island (0,0)** — 22 cities
   - Bad data, kept current TZ, marked `unresolved`
   - Per spec §14.1, no silent default

## How the polygon fix works (M1)

```python
# scripts/seed/tz_polygon.py
from timezonefinder import TimezoneFinder
tf = TimezoneFinder()

for city in cities:
    polygon_tz = tf.timezone_at(lat=city.lat, lng=city.lon)
    if polygon_tz and polygon_tz != city.timezone:
        # Polygon differs from dr5hn → polygon wins
        city.timezone = polygon_tz
        city.timezone_source = 'polygon:timezonefinder'
        city.timezone_confidence = 'high'
```

Results:
- 2,983 cities fixed globally
- Top patterns: 441 America/Fortaleza (BR), 251 Asia/Bangkok (VN),
  178 America/Argentina/Cordoba, 160 America/Monterrey (MX),
  126 America/Araguaina (BR), 122 Asia/Urumqi (CN), 111 Asia/Yekaterinburg (RU),
  108 Asia/Makassar (ID), 88 Asia/Jerusalem (PS), 81 America/Mexico_City (MX)

## Banned timezones (spec §8.2)

`Etc/GMT*` and `Etc/UTC*` are **banned** for cities — they're abstractions
that don't represent a real political timezone. All 33 `Etc/GMT*` references
in the source data were manually overridden in migration 125.

## Manual overrides (spec §28)

Every manual override has a documented reason in `migrations/125_tz_polygon_overrides.sql`:

| City ID | Name | TZ | Reason |
|---|---|---|---|
| 16179 | Atikokan | America/Atikokan | EST no DST |
| 16347 | Creston | America/Creston | MST no DST |
| 132750 | Lakshadweep | Asia/Kolkata | Oceanic city off India coast |
| 134786 | Persian Gulf | Asia/Tehran | Canonical Persian Gulf |
| 148461 | Galápagos | America/Guayaquil | Pacific, closest to Galápagos |
| 154255, 154256 | Aegean Sea | Europe/Athens | Aegean Sea |
| 154881 | Tuamotu | Pacific/Tahiti | Tuamotu Archipelago |
| 154890 | Marquesas | Pacific/Marquesas | Marquesas Islands |
| 154895, 154902, 154906 | Society Islands | Pacific/Tahiti | Society Islands |
| 162138 | Indian Ocean | Indian/Reunion | Indian Ocean near Reunion |

## Null Island handling (spec §14.1)

22 cities have lat=0, lon=0 (likely bad data — no real city is at (0,0)).
Per §14.1, we do not silently default these. We:

1. Keep the dr5hn timezone (we don't know the right one)
2. Mark `timezone_confidence = 'unresolved'`
3. Add `data_quality_flags = 'null_island,no_pop,no_wiki'`
4. Surface via `/api/v1/data-quality/issues?type=null_island`

## Data flow diagram

```
┌──────────────┐         ┌──────────────┐
│   dr5hn      │         │  GeoNames    │
│  (cities)    │         │ (alt names)  │
└──────┬───────┘         └──────┬───────┘
       │                        │
       ▼                        ▼
┌──────────────────────────────────────┐
│            cities table              │
│  (152,970 rows, all canonical IANA)  │
└──────────────┬───────────────────────┘
               │
       ┌───────┴────────┐
       ▼                ▼
   ┌────────┐     ┌──────────────┐
   │ tzfpy  │     │  M1 audit    │
   │(polygon│     │  (migration  │
   │  fix)  │     │  123-125)    │
   └────┬───┘     └──────┬───────┘
        │                │
        ▼                ▼
┌──────────────────────────────────────┐
│   timezone_confidence (M8)          │
│   timezone_source   (M8)            │
│   data_quality_flags (M8)           │
└──────────────────────────────────────┘
```

## API exposure

All four fields are exposed via:

- `GET /api/v1/cities/{id}` — per-city (response includes `dataQuality`)
- `GET /api/v1/data-quality` — aggregate (counts per confidence level)
- `GET /api/v1/data-quality/issues?type=...` — filterable list

## Edge cases

| Case | Behavior |
|---|---|
| Lat/lon exactly (0, 0) | `unresolved` + `null_island` flag |
| Polygon returns `Etc/GMT*` | Manual override per §8.2 |
| dr5hn TZ differs from polygon | Polygon wins (high confidence) |
| City at ocean | Manual override per §28 (13 cities) |
| Missing coordinates | Doesn't occur (all 152,970 have valid lat/lon) |

## Validation

`/api/v1/data-quality` returns:
- `cities.confidence.{high, medium, low, unresolved, total}` — should sum to 152,970
- `timezoneZones.deprecatedEtcGmt` — should always be 0 (§8.2)
- `cities.flags` — distribution of `null_island`, `no_pop`, etc.

## Versioning

| Migration | Description |
|---|---|
| 123 | Global polygon fix (2,983 cities) |
| 124 | Add missing IANA TZs (Atikokan, Creston) |
| 125 | Manual overrides (13 cities) |
| 133-138 | Data quality metadata schema + population (M8) |

See `migrations/` for the exact SQL.
