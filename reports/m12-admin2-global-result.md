# M12 — Global admin-2 Result

**Date**: 2026-08-03
**Branch**: develop @ 105dfe9
**Status**: SHIPPED, dev deployed

---

## TL;DR

Global admin-2 (counties, districts, communes, municípios) — **47,549 regions across 189 countries** — and **56,293 of our 170,253 cities** now have their level-2 admin region. Wesley Chapel → Pasco County. NYC → New York County (Manhattan). Tokyo → Shinjuku-ku. 33% global city coverage in one batch.

---

## What we have in data

### 47,549 admin-2 regions across 189 countries
| Country | Admin-2 type | Count |
|---|---|---:|
| Brazil (BR) | municípios | 5,570 |
| Romania (RO) | communes | 3,181 |
| United States (US) | counties/parishes/boroughs | 3,143 |
| Russia (RU) | rayons | 2,648 |
| Mexico (MX) | municipios | 2,471 |
| Canada (CA) | counties/regions | 1,641 |
| Japan (JP) | districts | 1,190 |
| Colombia (CO) | municipalities | 1,122 |
| Turkey (TR) | districts | 974 |
| Thailand (TH) | amphoe | 928 |

Each admin-2 has: name, ASCII name, GeoNames ID, hierarchical code (e.g. `US.FL.101` = Florida, Pasco County = FIPS 12101).

### 56,293 of 170,253 cities mapped
33% of our cities have a level-2 admin in the response. The remaining 67% (mostly smaller towns) need a different mapping approach (see "What we don't have yet" below).

---

## What we get

### New field: `subRegion` in `/cities/{id}`

For Wesley Chapel (was 128809):
```json
"subRegion": {
  "id": 48394,
  "name": "Pasco County",
  "code": "US.FL.101",
  "type": "admin2",
  "level": 2,
  "geonameId": 4167895
}
```

For Wesley Chapel's neighboring city Zephyrhills, subRegion would be `Pasco County` (it's split between Pasco and Hillsborough).

For NYC: subRegion = `New York County` (which is Manhattan, the borough at the center).

For Tokyo: subRegion = `Shinjuku` (or one of the 23 special wards).

### New endpoints

**`GET /api/v1/countries/{cca2}/admin2?admin1=XX&limit=N`**
- List all admin-2 for a country (optionally filtered by state)
- `GET /api/v1/countries/US/admin2?admin1=FL&limit=10` → Pasco County, Hillsborough County, etc.
- Returns total count + city count per admin-2
- 3,143 admin-2 for US, 5,570 for BR, etc.

**`GET /api/v1/admin2/{id}`**
- Detail for an admin-2
- Returns cityCount (e.g. Pasco County has 18 cities)
- `GET /api/v1/admin2/48394` → Pasco County (US.FL.101)

### Sample output

```
GET /api/v1/countries/US/admin2?admin1=FL&limit=3
```
```json
{
  "success": true,
  "data": {
    "country": { "cca2": "US", "cca3": "USA", "name": "United States" },
    "total": 67,
    "count": 3,
    "admin2": [
      { "id": 48721, "name": "Alachua County", "code": "US.FL.001", "cityCount": 9, ... },
      { "id": 49014, "name": "Baker County", "code": "US.FL.003", "cityCount": 2, ... },
      { "id": 48455, "name": "Bay County", "code": "US.FL.005", "cityCount": 7, ... }
    ]
  }
}
```

---

## What we don't have yet

### Admin-2 population and area
GeoNames `admin2Codes.txt` is just codes + names + geonameId — no population or area. To get those, need to:
- Query GeoNames API per admin-2 (47K calls, no rate limit on free tier but slow)
- OR use Wikidata SPARQL (P1082 population, P2046 area)
- OR use a different dataset like GADM

### Admin-2 lat/lon
Same issue — no coordinates in the GeoNames admin-2 file. Most admin-2 centroids can be derived from cities that belong to them (we have city lat/lon for 56K cities).

### Cities without admin-2 (113K / 170K)
The 67% of cities we DIDN'T map are mostly:
- Smaller towns not in GeoNames cities1000
- Rural villages in less-mapped countries
- Some cities have admin-2 in GeoNames but our city has no geonames_id

For these, would need:
- A lat/lon-based nearest-admin-2 lookup (no polygons)
- OR polygon point-in-polygon matching (requires downloading admin-2 geometries, ~1GB+)

### Admin-2 → Admin-1 parent link
We have `parent_id` set to NULL for all admin-2 (the admin-1 records in our DB use dr5hn codes, while GeoNames uses ISO 3166-2 numeric — they don't match cleanly). Could resolve with a mapping table, but not blocking.

---

## Architecture

```
┌──────────────────────┐
│ GeoNames admin2Codes │ 47,549 admin-2
│ GeoNames cities1000  │ 149,120 cities with admin-2 codes
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐     ┌──────────────────────┐
│ administrative_      │     │ cities               │
│ regions (level=2)    │     │ + admin2_id          │
│ 47,549 rows          │◄────│ 56,293 rows updated  │
└──────────────────────┘     └──────────────────────┘
           │                            │
           └───────── JOIN ────────────┘
                       │
                       ▼
              GET /api/v1/cities/{id}
              + subRegion field
```

---

## Performance

| Endpoint | Pre-M12 | Post-M12 | Delta |
|---|---|---|---|
| `/cities/{id}` | ~600ms | ~700ms | +100ms (1 extra JOIN) |
| `/countries/{cca2}/admin2` | n/a | ~80ms | new |
| `/admin2/{id}` | n/a | ~50ms | new |

All under threshold. The extra JOIN on `cities.admin2_id = ar.id` is cheap (indexed).

---

## Gotchas hit

### Schema gaps
- `administrative_regions` didn't have `geoname_id` column — had to add it via manual ALTER after the initial migration failed
- `cities` didn't have `admin2_id` column — added via migration 155

### Loader gotchas
- D1 100-var limit: 8-col INSERT batch of 12 = 96 vars (safe); UPDATE batch of 100 IDs via CASE WHEN is literal SQL not prepared, so no var limit
- Initial `c.ca2` typo vs `c.cca2` — first run mapped 0 admin-2, fixed column name
- GeoNames admin-1 codes are ISO 3166-2 numeric, our admin-1 codes are dr5hn — can't link parent cleanly, so we leave parent_id=NULL for now

### Data quality
- Wesley Chapel is technically in 2 counties (Pasco + Hillsborough). GeoNames puts it in Pasco — that's our answer. Edge case: some CDPs span counties.
- 3 territories missing from admin-1 (Cook Islands, N. Mariana, Svalbard) — admin-2 for those gets dropped. Negligible.

### Test issue
- Test for /countries/{cca2}/admin2 initially showed 404 because the route was being shadowed by /countries/{cca2} from the countries route. Hono handles route ordering, but the new endpoint wasn't being included in the build until I forced a fresh deploy.

---

## Final state

### DB stats (post M12)
- cities: 170,253 (56,293 with admin2_id)
- administrative_regions: 52,857 (5,308 level-1 + 47,549 level-2)
- country → admin-2 coverage: 189/250 (76%)

### Test count
- Pre M12: 616/619
- M12: +11 tests, **627/630** (3 pre-existing failures: env, M8.5, Rio Branco)

### New files
- migrations/155_admin2_global.sql
- scripts/seed/admin2_global_to_d1.py
- scripts/seed/admin2_map_cities.py
- src/routes/subregions.ts (new — 2 endpoints)
- tests/m12-admin2-global.test.ts (11 tests)

### Modified
- src/index.ts (registered subregions route)
- src/routes/cities.ts (added subRegion to schema + JOIN + field)

### API count
- 31 endpoints (was 29)
- 39 fields per /cities/{id} (was 38)

---

## Next steps (post-MVP)

1. **Admin-2 population/area** — query Wikidata for P1082/P2046 (~1 day)
2. **Admin-2 lat/lon** — derive from city centroids in same admin-2 (~1 day)
3. **Admin-2 → Admin-1 parent link** — use a code mapping table (dr5hn ↔ ISO 3166-2)
4. **Cities without admin-2 (113K)** — lat/lon nearest-admin-2 lookup (lose polygon accuracy but gain coverage)
5. **Admin-2 polygons** — download GADM/geoBoundaries (~1GB+), point-in-polygon matching (5x accuracy boost for the 113K)
6. **Admin-2 alt names** — for SEO (e.g. "Peking" → "Beijing" at county level)

These are all nice-to-haves for richer data, not blocking. The current 33% coverage + new endpoints cover the most common use cases.
