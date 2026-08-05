# Regions, Countries, and Cities — Geographic Data Model

> The geographic hierarchy: World → Continent → Country → Admin-1 (state) → Admin-2 (county) → City.

## Hierarchy

```
World
├── Continent (7)
│   ├── Country (250)
│   │   ├── Admin-1 (state/province) (5,308)
│   │   │   ├── Admin-2 (county/district/commune) (47,549)
│   │   │   │   └── City (170,253)
```

## Tables

### `countries` (250 rows)

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Internal ID |
| `cca2` | TEXT | ISO 3166-1 alpha-2 (e.g., 'US') |
| `cca3` | TEXT | ISO 3166-1 alpha-3 (e.g., 'USA') |
| `cioc` | TEXT | IOC code (e.g., 'USA') |
| `name` | TEXT | English name |
| `name_local` | TEXT | Native name |
| `continent` | TEXT | Continent code (AF, AN, AS, EU, NA, OC, SA) |
| `region` | TEXT | UN region (Africa, Americas, Asia, Europe, Oceania) |
| `subregion` | TEXT | UN subregion |
| `capital` | TEXT | Capital city name |
| `languages` | TEXT | Comma-separated ISO 639 codes |
| `population` | INTEGER | World Bank 2024 |
| `area_km2` | INTEGER | Total area |

### `subregions` (4,750 rows)

ISO 3166-2 codes (e.g., `US-FL` for Florida). Used in the older `cities.state_code` field.

### `administrative_regions` (52,857 rows)

Two-level model:
- `level = 1` → admin-1 (state, province, region) — 5,308 rows
- `level = 2` → admin-2 (county, district, commune, municipality) — 47,549 rows

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Internal ID |
| `parent_id` | INTEGER FK | Parent admin-1 region |
| `name` | TEXT | Region name |
| `code` | TEXT | ISO 3166-2 code (admin-1) or GeoNames code (admin-2) |
| `level` | INTEGER | 1 = admin-1, 2 = admin-2 |
| `type` | TEXT | 'state', 'province', 'county', 'district', 'municipality' |
| `country_code` | TEXT | ISO 3166-1 alpha-2 |
| `geoname_id` | INTEGER | GeoNames geonameId (M12) |
| `country_id` | INTEGER FK | countries.id |

### `cities` (170,253 rows)

| Column | Type | Description |
|---|---|---|
| `id` | INTEGER PK | Internal city ID |
| `name` | TEXT | City name |
| `ascii_name` | TEXT | ASCII-folded name (for search) |
| `country_code` | TEXT | ISO 3166-1 alpha-2 |
| `state_code` | TEXT | ISO 3166-2 admin-1 code (dr5hn) |
| `admin1_id` | INTEGER FK | administrative_regions.id (M11.0) |
| `admin2_id` | INTEGER FK | administrative_regions.id (M12) |
| `tz_id` | TEXT FK | timezones.id (IANA) |
| `latitude` | REAL | Decimal degrees |
| `longitude` | REAL | Decimal degrees |
| `population` | INTEGER | Best-available population |
| `wikidata_qid` | TEXT | Wikidata Q-id (M11.2) |
| `wiki_url` | TEXT | Wikipedia URL (M11.2) |
| `subRegion` | (derived) | Admin-2 detail in API response |

## Layer model (M11.1)

Cities come from **two layers**:

1. **dr5hn layer** (152,970 cities) — US-focused, high quality, has timezone polygons
2. **GeoNames layer** (17,283 cities only in GeoNames, 0 overlap with dr5hn) — global coverage

The two layers are **merged, not replaced**. Each city has `source_primary` (which layer
is the canonical source) and `source_merged_with` (the other layer's row, if any).

`source_merge_method` records how the merge was done:
- `exact_1km` — same coordinates, dr5hn is canonical
- `fuzzy_10km` — within 10km, GeoNames added as alt name
- `historical_alias` — old name → new name (Bombay→Mumbai, Edo→Tokyo)
- `none` — single-source

## City count by country (top 10)

| Country | Cities |
|---|---:|
| US | 14,459 |
| DE | 12,000+ |
| FR | 10,000+ |
| GB | 8,000+ |
| IT | 7,000+ |
| ES | 6,000+ |
| BR | 5,000+ |
| IN | 4,000+ |
| MX | 3,000+ |
| CA | 3,000+ |

## Admin-2 coverage (M12)

47,549 admin-2 regions across 189 countries. Top:
- **BR (Brazil):** 5,570 municípios
- **RO (Romania):** 3,181
- **US:** 3,143 counties
- **RU (Russia):** 2,648
- **MX (Mexico):** 2,471

## Edge cases

### Disputed territories

- Taiwan, Kosovo, Western Sahara: included with the UN-recognized parent
- Crimea: listed under both Ukraine and Russia in some sources. We follow UN: Ukraine.

### City-country mismatches

- **Vatican City** is in `countries` but has no cities. We exclude it from city search.
- **Antarctica** has research stations, not cities. We have a few but they show as "research_station" type.

### Historical renamings

- Bombay → Mumbai (M11.1.5 altNames)
- Edo → Tokyo
- Peking → Beijing
- Constantinople → Istanbul
- Leningrad → St Petersburg

The original name is stored in `alt_names` so searches for "Bombay" still find Mumbai.

## API endpoints

- `GET /api/v1/countries` — list countries
- `GET /api/v1/countries/{cca2}` — single country
- `GET /api/v1/countries/{cca2}/admin2` — admin-2 list (M12)
- `GET /api/v1/admin2/{id}` — single admin-2 (M12)
- `GET /api/v1/regions?country=US` — admin-1 list
- `GET /api/v1/cities?q=...&country=...&state=...` — city search
- `GET /api/v1/cities/{id}` — city detail (includes subRegion)

## See also

- `migrations/105_admin_regions.sql` — admin regions schema (M11.0)
- `migrations/155_admin2_global.sql` — M12 admin-2
- `scripts/seed/admin2_global_to_d1.py` — M12 loader
- `scripts/seed/admin2_map_cities.py` — M12 city-to-admin-2 mapping
- `docs/PLAN-source-data-alignment.md` — why we use dr5hn + GeoNames
