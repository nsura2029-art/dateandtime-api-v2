# Timezone Architecture

> How timezones, DST, and city lookup work in dateandtime-api-v2.

## Core principle

**IANA timezones are the source of truth** (e.g., `America/New_York`, `Asia/Tokyo`, `Europe/London`).
Cities have a `tz_id` column that maps to a row in the `timezones` table. The IANA zoneinfo
data drives DST rules — we don't reinvent them.

## Tables

### `timezones` (462 rows)

| Column | Type | Description |
|---|---|---|
| `id` | TEXT PK | IANA name (e.g., 'America/New_York') |
| `name` | TEXT | Display name |
| `country_code` | TEXT | ISO 3166-1 alpha-2 |
| `utc_offset` | INTEGER | Standard offset in minutes |
| `dst_offset` | INTEGER | DST offset in minutes (0 if no DST) |
| `abbreviation` | TEXT | Standard abbreviation (EST, JST, etc.) |

### `cities.tz_id` (FK to `timezones.id`)

Each city has exactly one IANA timezone. We do **not** use multiple timezones per city
because:
1. Most cities are entirely within one IANA zone
2. Multi-zone cities add API complexity without much SEO value
3. When a city spans multiple zones, we pick the dominant one by population

## DST handling

### Data source: Python `zoneinfo` (M11.6.1)

```python
from zoneinfo import ZoneInfo
from datetime import datetime

tz = ZoneInfo("America/New_York")
# Get current UTC offset for a specific date
now = datetime(2026, 7, 1, 12, 0, tzinfo=tz)
print(now.utcoffset())  # -4 hours (EDT)
```

### `dst_transitions` table (1,560 rows)

| Column | Description |
|---|---|
| `tz_id` | IANA timezone |
| `transition_at` | When DST changes |
| `offset_before` | UTC offset before |
| `offset_after` | UTC offset after |
| `is_dst` | 1 if entering DST, 0 if leaving |
| `year` | Year of transition |

Computed for 312 timezones × 5 years.

### API behavior

`/api/v1/time/now?tz=America/New_York` returns:
```json
{
  "success": true,
  "data": {
    "timezone": "America/New_York",
    "datetime": "2026-07-01T12:00:00-04:00",
    "utc_offset": -240,
    "is_dst": true,
    "abbreviation": "EDT"
  }
}
```

## Polygons (M1)

### `timezone_polygons` table

For cities that span multiple IANA zones (rare but real), we store the polygon of the
IANA zone boundary. Used for high-accuracy lookup when lat/lon is near a boundary.

3,018 cities have polygons verified against IANA boundaries.

## Edge cases

### Cities that span timezones

Some US cities straddle state-timezone lines (e.g., **Tennessee** is partly Central,
partly Eastern). We pick the dominant timezone by population, but flag with
`tz_confidence` (0.0-1.0).

### Cities with DST in southern hemisphere

Australia, NZ, Brazil, Chile: their DST is opposite of northern hemisphere.
`zoneinfo` handles this correctly via the IANA database.

### Cities with half-hour / 15-min offsets

India (UTC+5:30), Iran (UTC+3:30/+4:30), Nepal (UTC+5:45), Australian Central
(UTC+9:30/+10:30), Chatham Islands (UTC+12:45/+13:45).

Our `utc_offset` column is in **minutes**, so all of these work.

### Cities that observe DST but parent country doesn't

Arizona (US) does not observe DST, but the IANA zone `America/Phoenix` correctly
reflects this. We don't override at the city level.

## Best practices

1. **Always store tz_id, not the offset** — the offset can change due to DST or
   political decisions (e.g., Samoa skipped a day in 2011).
2. **Use IANA names, not abbreviations** — `EST` is ambiguous (US Eastern Standard vs
   Australian Eastern Standard). `America/New_York` is unambiguous.
3. **Cache zoneinfo objects** — they're expensive to construct. Reuse across requests.
4. **Handle historical timezones** — some cities have changed their tz over time
   (e.g., Samoa, Korea). For these, we pick the current tz and don't track history.

## API endpoints

- `GET /api/v1/timezones` — list all 462
- `GET /api/v1/timezones/{id}` — single timezone
- `GET /api/v1/time/now?tz=America/New_York` — current time
- `GET /api/v1/time/sun?lat=35.7&lon=139.7` — sunrise/sunset
- `GET /api/v1/time/convert?from=UTC&to=America/New_York&datetime=...` — convert

## See also

- `migrations/013_dst_transitions.sql` — DST schema
- `scripts/seed/dst_transitions.py` — DST loader
- `tests/timezone-fixtures.test.ts` — 84 timezone tests
- [IANA tz database](https://www.iana.org/time-zones)
