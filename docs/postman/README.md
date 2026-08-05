# Postman Collection: dt-api-v2

API testing for the `dateandtime-api-v2` Worker.

## Files

- `dt-api-v2.postman_collection.json` — 30 requests across 4 folders
- `dt-api-v2.postman_environment.json` — dev environment (baseUrl)

## Import

1. Open Postman → **File → Import**
2. Drag both JSON files
3. Select **dt-api-v2 (dev)** environment
4. Click **Runner** to run all requests with the test scripts

## Folders

### Meta (6 requests)
- `GET /` — API root
- `GET /api/v1/health` — DB stats + latency
- `HEAD /api/v1/health` — probe
- `GET /api/v1/status` — full status
- `GET /openapi.json` — OpenAPI 3.1 spec
- `GET /docs` — Swagger UI

### Cities — Search (16 requests)
- **Happy paths** (5): Mumbai, prefix `mum`, Berlin (tier1), Hyderabad disambiguation, multilingual
- **Multilingual** (3): München (German), मुम्बई (Hindi), 北京 (Chinese)
- **Proximity** (1): Mumbai with user lat/lon
- **Edge cases** (7): empty result, 1-char, max-length, limit max, limit invalid, country code 3-letters, SQL injection, lat out of range

### Cities — Detail (6 requests)
- **Happy paths** (2): Mumbai, Berlin (capital, both)
- **Edge cases** (4): 404, negative id, string id, id=0

### Docs (2 requests)
- OpenAPI spec, Swagger UI

## Test scripts

Each request has a `test` script that runs on response. Tests verify:
- HTTP status code
- Response shape (success flag, data fields)
- Specific values (e.g. Mumbai is in IN)
- Edge case rejections (400 for invalid input, 404 for missing)

Run with Newman (CLI):
```bash
npm install -g newman
newman run docs/postman/dt-api-v2.postman_collection.json \
       -e docs/postman/dt-api-v2.postman_environment.json
```

## Test data summary

| ID | Name | Country | Notes |
|---|---|---|---|
| 133024 | Mumbai | IN | Test for state capital Maharashtra |
| 24053 | Berlin | DE | country_capital + state_capital (both) |
| 1 | Andorra la Vella | AD | smallest country capital |
| 5128581 | New York | US | sample non-capital city |

## Edge cases covered

| Category | Cases |
|---|---|
| **Validation** | Empty q, 1-char q, 100-char q, 101-char q |
| **Limit** | Default 10, max 50, invalid 999 |
| **Coords** | lat=0/0, lat=95 (out of range), lon=-181 (out of range) |
| **Country code** | 2-letter (valid), 3-letter (invalid) |
| **ID** | 0, negative, string, non-existent |
| **Security** | SQL injection, XSS |
| **Unicode** | Hindi, Chinese, German umlauts |
| **Caching** | (Postman tests don't cover; see `wrangler.toml`) |
