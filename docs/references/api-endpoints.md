# API Endpoints Reference

> Every endpoint, what it does, what params it takes, what it returns. Use this to find the right endpoint for your use case.

**Source of truth:** `docs/api/openapi.json` (auto-generated) — this is a curated summary.

**Live API:** https://dt-api-v2-dev.nsura2029.workers.dev
**Swagger UI:** https://dt-api-v2-dev.nsura2029.workers.dev/docs
**Postman collection:** `docs/api/timeanddatepro-api.postman_collection.json`

## Total: 41 endpoints across 9 domains

- **Cities:** 7 endpoints
- **Countries:** 4 endpoints
- **Regions & Sub-regions:** 3 endpoints (M12)
- **Time:** 5 endpoints
- **Holidays:** 10 endpoints (M13+M14)
- **Translations:** 2 endpoints
- **Postcodes:** 1 endpoint
- **Airports:** 1 endpoint
- **Data Quality + Sources + Health:** 8 endpoints

## Cities (7)

### `GET /api/v1/cities`
- **Params:** `q` (search query), `country`, `state`, `lat`, `lon`, `radius`, `language`, `limit`, `offset`
- **Returns:** City list with search ranking, alt names, distance (if lat/lon)
- **Example:** `/api/v1/cities?q=tokyo&limit=5`

### `GET /api/v1/cities/{id}`
- **Params:** `id` (integer city ID)
- **Returns:** Full city detail — all 39 fields including Wikidata, admin-2 (subRegion), demographics
- **Example:** `/api/v1/cities/1850147` (Tokyo)

### `GET /api/v1/cities/{id}/resources`
- **Returns:** All attributes for a city (Wikidata, US Census, ACS, climate, etc.)
- **Example:** `/api/v1/cities/1850147/resources`

### `GET /api/v1/cities/{id}/postcodes`
- **Returns:** All postcodes in the city

### `GET /api/v1/cities/{id}/airports`
- **Returns:** Nearby airports (within city bounds)

### `GET /api/v1/cities/cities`
- **List endpoint** with full filter set (alternative to /cities for clients that prefer it)

### `GET /api/v1/cities/states`
- **Params:** `country`
- **Returns:** All admin-1 states/provinces for a country

## Countries (4)

### `GET /api/v1/countries`
- **Params:** `language`, `limit`, `offset`
- **Returns:** All 250 countries with localized names

### `GET /api/v1/countries/{cca2}`
- **Returns:** Country detail (population, languages, etc.)

### `GET /api/v1/countries/{cca2}/holidays`
- **Shortcut** for `/api/v1/holidays?country=XX`
- *(Note: currently returns 404 due to Hono routing — use /api/v1/holidays?country=XX instead)*

### `GET /api/v1/countries/{cca2}/admin2`
- **Params:** `admin1` (optional)
- **Returns:** All admin-2 regions (counties, districts) for a country (M12)

## Regions & Sub-regions (3 — M12)

### `GET /api/v1/admin2/{id}`
- **Returns:** Admin-2 region detail with cityCount

### `GET /api/v1/regions`
- **Params:** `country`
- **Returns:** All admin-1 regions

### (admin-2 is included in `/cities/{id}` response as `subRegion` field)

## Time (5)

### `GET /api/v1/time/now`
- **Params:** `tz` (IANA timezone)
- **Returns:** Current time in the timezone

### `GET /api/v1/time/sun`
- **Params:** `lat`, `lon`, `date`
- **Returns:** Sunrise, sunset, daylight hours

### `GET /api/v1/time/convert`
- **Params:** `from`, `to`, `datetime`
- **Returns:** Converted datetime

### `GET /api/v1/timezones`
- **Returns:** All 462 IANA timezones

### `GET /api/v1/timezones/{id}`
- **Returns:** Single timezone with current offset

## Holidays (10 — M13+M14)

### `GET /api/v1/filters`
- **Returns:** Global filter catalog (36 codes)

### `GET /api/v1/countries/{cca2}/filters`
- **Params:** `year`, `mode`, `from`, `to`
- **Returns:** **The variance endpoint** — per-country filter list with live counts
- **Example:** `/api/v1/countries/US/filters?year=2026` returns 22 filters

### `GET /api/v1/holidays`
- **Params:** `country`, `mode` (country|international|combined), `year`, `from`, `to`, `filters`
- **Returns:** Main list with worldwide + per-country + state details
- **Example:** `/api/v1/holidays?country=US&year=2026&filters=PUBLIC_NATIONAL`

### `GET /api/v1/holidays/{id}`
- **Returns:** Single occurrence detail with all 30 fields (now includes worldwide, category, origin, scope_level)

### `GET /api/v1/holidays/today`
- **Params:** `country`
- **Returns:** Today's holidays (widget-friendly)

### `GET /api/v1/holidays/upcoming`
- **Params:** `country`, `days`
- **Returns:** Next N days of holidays

### `GET /api/v1/long-weekends`
- **Params:** `country`, `year`
- **Returns:** Long weekends (3+ day breaks)

### `GET /api/v1/calendars/holidays.ics`
- **Params:** `country`, `year`
- **Returns:** RFC 5545 ICS calendar feed

### `POST /api/v1/feedback`
- **Body:** occurrence_id, report_type, severity, description
- **Returns:** Confirmation (severity P0-P3)

## Translations (2)

### `GET /api/v1/translations/cities`
- **Params:** `q`, `lang`, `country`
- **Returns:** City name translations

### `GET /api/v1/translations/countries`
- **Params:** `lang`
- **Returns:** Country name translations

## Postcodes (1)

### `GET /api/v1/postcodes`
- **Params:** `country`, `q` (postcode), `lat`, `lon`, `radius`
- **Returns:** Postcode search

## Airports (1)

### `GET /api/v1/airports`
- **Params:** `country`, `lat`, `lon`, `radius`
- **Returns:** Airport search

## Data Quality + Sources + Health (8)

### `GET /api/v1/data-quality`
- **Returns:** All data quality check results

### `GET /api/v1/sources`
- **Returns:** All registered sources

### `GET /api/v1/sources/{source_key}`
- **Returns:** Single source detail

### `GET /api/v1/staging/cities`
- **Returns:** Staging rows (pre-merge)

### `GET /api/v1/staging/cities/{id}`
- **Returns:** Single staging row

### `GET /health`
- **Returns:** Health check

### `GET /version`
- **Returns:** API version

### `GET /`
- **Returns:** API root with all endpoint links

## Response formats

All endpoints return JSON in the format:
```json
{
  "success": true,
  "data": { /* endpoint-specific */ }
}
```

Errors:
```json
{
  "success": false,
  "error": {
    "code": "COUNTRY_NOT_FOUND",
    "message": "Country XX not found"
  }
}
```

## Adding a new endpoint (checklist)

1. **Define schema** in Zod (`z.object({...})`)
2. **Create route** with `createRoute` and `app.openapi`
3. **Add to OpenAPI** in `docs/api/openapi.json` (or regen)
4. **Add tests** in `tests/<feature>.test.ts`
5. **Add to Postman** via `npm run sync:readme`
6. **Update this doc** with the new endpoint
