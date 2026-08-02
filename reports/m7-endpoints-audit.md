# M7: New Endpoints Audit

**Date:** 2026-08-02

## New API Endpoints

| Endpoint | Description | Status |
|---|---|---|
| GET /api/v1/cities/{id}/postcodes | Full paginated postcodes for a city | ✅ Live |
| GET /api/v1/postcodes/search | Find cities by postal code | ✅ Live |
| GET /api/v1/airports/near | Find airports near a point (lat/lon) | ✅ Live (no data) |
| GET /api/v1/cities/{id}/airports | Airports serving a city | ✅ Live (no data) |
| GET /api/v1/cities/{id}/translations | All 19 langs for a city (M5) | ✅ Live |
| GET /api/v1/cities/{id}/translations/{lang} | Single lang translation (M5) | ✅ Live |
| GET /api/v1/translations/search | Search by translated name (M5) | ✅ Live |

## Endpoint details

### /cities/{id}/postcodes
- Returns postcodes in the same state as the city (state-scoped)
- Pagination: ?page= (default 1), ?limit= (default 20, max 100)
- Includes: code, localityName, type, lat/lon, source
- Tested: 1013 postcodes for FL (state of East Pensacola Heights)

### /postcodes/search
- Query: ?code= (exact or prefix), ?country= (cca2)
- Returns: matching postcodes + associated cities (state-scoped)
- Cities sorted by is_state_capital DESC, population DESC
- Example: code=32501&country=US → Tallahassee (FL state capital) first

### /airports/near
- Query: ?lat=, ?lon=, ?radius= (default 100km, max 500km)
- Bounding box pre-filter + haversine post-filter
- Sorted by is_scheduled DESC, distance ASC
- Data pending: OurAirports.com import (cron task 426125193814084)

### /cities/{id}/airports
- Returns airports with city_id = {id}
- Sorted by is_scheduled DESC, name ASC
- Data pending (same as /airports/near)

## Test results

| Test | Result |
|---|---|
| M7.1 full postcodes list | ✅ Pass |
| M7.2 pagination | ✅ Pass |
| M7.3 404 for missing city | ✅ Pass |
| M7.4 limit max enforced | ✅ Pass |
| M7.5 exact postcode search | ✅ Pass |
| M7.6 prefix postcode search | ✅ Pass |
| M7.7 invalid country | ✅ Pass |
| M7.8 city sorted by state capital | ✅ Pass |
| M7.9 airports/near schema | ✅ Pass |
| M7.10 invalid lat | ✅ Pass |
| M7.11 invalid radius | ✅ Pass |
| M7.12 NYC airports (no data) | ✅ Pass |
| M7.13 city airports (no data) | ✅ Pass |
| M7.14 404 for missing city | ✅ Pass |

**14/14 pass**

## Total test count: 159/160 pass (1 pre-existing env.test.ts)

## Spec coverage progress

| Section | Before M7 | After M7 | New passing |
|---|---:|---:|---:|
| §16.3 Small island via postcode | 0 | 1 | +1 (postcode lookup) |
| §17.5 Full postcodes | 0 | 4 | +4 (list, page, count, source) |
| §33.7 Postcodes acceptance | 1 | 5 | +4 |
| §33.21 Airports schema | 0 | 4 | +4 (lat/lon, radius, type, scheduled) |

**Cumulative: 142/209 spec tests (67.9%)**

## Open work

- Airport data import (deferred to cron reminder task 426125193814084)
- After data load, re-run M7.12 + M7.13 to verify JFK and Tokyo airports appear
- Also re-test §16.3 with actual airport data

## Swagger UI coverage

12 paths total, all in /openapi.json and /docs:

- /
- /api/v1/health
- /api/v1/status
- /api/v1/cities/search
- /api/v1/cities/{id}
- /api/v1/cities/{id}/airports     (M7)
- /api/v1/cities/{id}/postcodes     (M7)
- /api/v1/cities/{id}/translations  (M5)
- /api/v1/cities/{id}/translations/{lang}  (M5)
- /api/v1/translations/search       (M5)
- /api/v1/postcodes/search          (M7)
- /api/v1/airports/near             (M7)
