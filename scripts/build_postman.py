#!/usr/bin/env python3
"""
Generate the Postman collection for dateandtime-api-v2.

Outputs:
  docs/postman/dt-api-v2.postman_collection.json
  docs/postman/dt-api-v2.postman_environment.json
"""
import json
import os
from urllib.parse import quote

API_NAME = "dateandtime-api-v2"
API_VERSION = "2.0.0"
OUT_DIR = "docs/postman"
os.makedirs(OUT_DIR, exist_ok=True)

def make_request(name, method, path, description="", query=None, body=None):
    """Create a Postman request item."""
    req = {
        "name": name,
        "request": {
            "method": method,
            "header": [],
            "url": {
                "raw": "{{baseUrl}}" + path + (("?" + "&".join(f"{k}={{{{{k}}}}}" for k in (query or {}).keys())) if query else ""),
                "host": ["{{baseUrl}}"],
                "path": [p for p in path.split("/") if p],
            },
            "description": description,
        },
        "response": [],
    }
    if query:
        req["request"]["url"]["query"] = [
            {"key": k, "value": f"{{{{{k}}}}}", "disabled": False} for k in query.keys()
        ]
    if body:
        req["request"]["body"] = {
            "mode": "raw",
            "raw": json.dumps(body, indent=2),
            "options": {"raw": {"language": "json"}},
        }
    return req

def make_folder(name, description, items):
    return {
        "name": name,
        "description": description,
        "item": items,
    }

# ============================================================================
# Build collection
# ============================================================================
collection = {
    "info": {
        "name": f"{API_NAME} ({API_VERSION})",
        "_postman_id": "dt-api-v2-2026-08-02",
        "description": (
            "dateandtime.live API v2 — Hono + Cloudflare D1 + Zod.\n\n"
            "**Coverage:** 152,970 cities, 250 countries, 462 IANA timezones, "
            "844K postcodes, 2.97M translations (19 langs).\n\n"
            "See https://github.com/nsura2029-art/dateandtime-api-v2 for source. "
            "Read `/docs/timezone-core-logic.md` for how timezones are assigned."
        ),
        "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
    },
    "item": [
        # ----- META -----
        make_folder("Meta", "API health, status, and docs", [
            make_request(
                "API root",
                "GET", "/",
                description="Welcome page with links to docs and health.",
            ),
            make_request(
                "Health check",
                "GET", "/api/v1/health",
                description="Returns DB stats (city count, etc.) and latency. Use for monitoring.",
            ),
            make_request(
                "API status",
                "GET", "/api/v1/status",
                description="Comprehensive service info: build, runtime, DB, features, endpoints.",
            ),
            make_request(
                "OpenAPI spec",
                "GET", "/openapi.json",
                description="Machine-readable OpenAPI 3.1 spec. Auto-generated from Zod schemas.",
            ),
            make_request(
                "Swagger UI",
                "GET", "/docs",
                description="Interactive API documentation. Try endpoints from the browser.",
            ),
        ]),

        # ----- CITIES -----
        make_folder("Cities", "dr5hn cities (152,970 rows) with full timezone + dr5hn enrichment", [
            make_request(
                "Search cities",
                "GET", "/api/v1/cities/search",
                description=(
                    "FTS5 search over 152,970 cities. Returns ranked results with country, "
                    "admin region, timezone, and (if provided) distance from user. "
                    "Supports ?state=, ?lang=, ?country=, ?lat/lon, ?limit. "
                    "When ?lang= is provided and query is in that language, "
                    "searches the translations table as fallback."
                ),
                query={
                    "q": "Tokyo",
                    "country": "JP",
                    "limit": 5,
                },
            ),
            make_request(
                "Search cities with state filter (disambiguation)",
                "GET", "/api/v1/cities/search",
                description=(
                    "When multiple cities share a name (Phoenix, Monterrey, Perth), "
                    "?state= gives a strong +1000 boost to disambiguate."
                ),
                query={"q": "Phoenix", "country": "US", "state": "AZ", "limit": 3},
            ),
            make_request(
                "Cross-language search (ja)",
                "GET", "/api/v1/cities/search",
                description=(
                    "Search in a non-English language via ?lang= and ?q=."
                ),
                query={"q": "東京", "lang": "ja", "limit": 3},
            ),
            make_request(
                "Search near user (lat/lon)",
                "GET", "/api/v1/cities/search",
                description=(
                    "Use ?lat and ?lon to add proximity boost to ranking."
                ),
                query={"q": "Springfield", "lat": "37.18", "lon": "-93.3", "limit": 5},
            ),
            make_request(
                "Get city detail by ID",
                "GET", "/api/v1/cities/64500",
                description=(
                    "Returns full record for a city: name, country, admin region, "
                    "timezone, capital status, tier, dr5hn enrichment, place names, "
                    "postcodes, translations count, data quality."
                ),
            ),
            make_request(
                "Get city postcodes (paginated)",
                "GET", "/api/v1/cities/115731/postcodes",
                description=(
                    "Returns postcodes in the same state as the city, paginated. "
                    "State-scoped because dr5hn postcodes have NULL city_id."
                ),
                query={"page": 1, "limit": 5},
            ),
            make_request(
                "Get city translations (all 19 langs)",
                "GET", "/api/v1/cities/64500/translations",
                description=(
                    "Returns city name translated into all 19 supported languages "
                    "(ar, br, de, es, fa, fr, hi, hr, it, ja, ko, nl, pl, pt, pt-BR, "
                    "ru, tr, uk, zh-CN)."
                ),
            ),
            make_request(
                "Get city translation (single language)",
                "GET", "/api/v1/cities/64500/translations/ja",
                description="Returns the city name in a single language. Case-insensitive.",
            ),
            make_request(
                "Get city airports",
                "GET", "/api/v1/cities/64500/airports",
                description=(
                    "Returns airports with city_id matching the given city. "
                    "Data import pending (cron task 426125193814084)."
                ),
            ),
        ]),

        # ----- TRANSLATIONS -----
        make_folder("Translations", "19-language cross-language search (2.97M rows)", [
            make_request(
                "Search by translated name",
                "GET", "/api/v1/translations/search",
                description=(
                    "Find cities by their name in a non-English language. "
                    "Example: ?q=東京&lang=ja finds Tokyo. "
                    "?q=北京&lang=zh-CN finds Beijing."
                ),
                query={"q": "東京", "lang": "ja", "limit": 5},
            ),
            make_request(
                "Search Spanish name (Madrid)",
                "GET", "/api/v1/translations/search",
                description="Find cities with name in Spanish.",
                query={"q": "Madrid", "lang": "es", "limit": 5},
            ),
        ]),

        # ----- POSTCODES -----
        make_folder("Postcodes", "Postal/ZIP codes (844,248 rows, 14 countries)", [
            make_request(
                "Find cities by postcode",
                "GET", "/api/v1/postcodes/search",
                description=(
                    "Find cities by postal code. ?exact=true for exact match, "
                    "?exact=false for prefix. Returns postcode + associated cities "
                    "(state_capital first, then by population)."
                ),
                query={"code": "32501", "country": "US", "exact": "true"},
            ),
            make_request(
                "Find cities by postcode (prefix)",
                "GET", "/api/v1/postcodes/search",
                description="Prefix match. code=32 finds 32003, 32008, etc.",
                query={"code": "32", "country": "US", "exact": "false", "limit": 5},
            ),
        ]),

        # ----- AIRPORTS -----
        make_folder("Airports", "Airports near a point (data import pending)", [
            make_request(
                "Find airports near coordinates",
                "GET", "/api/v1/airports/near",
                description=(
                    "Returns airports within ?radius= (default 100 km, max 500 km) "
                    "of a lat/lon. Sorted by scheduled service then distance. "
                    "Data pending (OurAirports.com import via cron task)."
                ),
                query={"lat": "30.4282", "lon": "-87.2225", "radius": 100, "limit": 5},
            ),
            make_request(
                "Find airports in NYC (JFK area)",
                "GET", "/api/v1/airports/near",
                description="JFK is at 40.6413, -73.7781.",
                query={"lat": "40.6413", "lon": "-73.7781", "radius": 50},
            ),
        ]),

        # ----- DATA QUALITY -----
        make_folder("Data Quality", "Timezone confidence, sources, audit", [
            make_request(
                "Data quality summary",
                "GET", "/api/v1/data-quality",
                description=(
                    "Returns overall data quality metrics: timezone confidence "
                    "distribution, data sources, applied migrations."
                ),
            ),
            make_request(
                "List all data quality issues",
                "GET", "/api/v1/data-quality/issues",
                description=(
                    "List all cities with quality concerns (Null Island, missing "
                    "population, low confidence, etc.) Sorted by severity."
                ),
                query={"limit": 50},
            ),
            make_request(
                "List Null Island cities",
                "GET", "/api/v1/data-quality/issues",
                description=(
                    "22 cities have lat=0, lon=0 (bad data). Per spec §14.1, "
                    "they're flagged 'unresolved' rather than silently defaulted."
                ),
                query={"type": "null_island", "limit": 50},
            ),
            make_request(
                "List manual overrides",
                "GET", "/api/v1/data-quality/issues",
                description=(
                    "13 cities with manually-overridden timezones (spec §28). "
                    "Includes Atikokan ON, Creston BC, Lakshadweep, etc."
                ),
                query={"type": "manual_override", "limit": 50},
            ),
            make_request(
                "List low-confidence cities",
                "GET", "/api/v1/data-quality/issues",
                description="13 manual override + 22 unresolved = 35 total.",
                query={"type": "low_confidence", "limit": 50},
            ),
            make_request(
                "List cities using banned Etc/GMT* (spec §8.2)",
                "GET", "/api/v1/data-quality/issues",
                description="Should always return 0 — migration 125 banned all Etc/GMT*.",
                query={"type": "etc_gmt_deprecated"},
            ),
        ]),
    ],
}

# ============================================================================
# Environment
# ============================================================================
environment = {
    "id": "dt-api-v2-env",
    "name": "dateandtime-api-v2 (dev)",
    "values": [
        {"key": "baseUrl", "value": "https://dt-api-v2-dev.nsura2029.workers.dev", "enabled": True},
        {"key": "cityId", "value": "64500", "enabled": True, "description": "Tokyo"},
        {"key": "cityId_us", "value": "115731", "enabled": True, "description": "East Pensacola Heights, FL"},
        {"key": "cityId_phoenix_az", "value": "124148", "enabled": True},
        {"key": "cityId_phoenix_or", "value": "124149", "enabled": True},
    ],
    "_postman_variable_scope": "environment",
    "_postman_exported_at": "2026-08-02T00:00:00Z",
    "_postman_exported_using": "Postman/10.0.0",
}

# ============================================================================
# Write
# ============================================================================
with open(os.path.join(OUT_DIR, "dt-api-v2.postman_collection.json"), "w") as f:
    json.dump(collection, f, indent=2)
with open(os.path.join(OUT_DIR, "dt-api-v2.postman_environment.json"), "w") as f:
    json.dump(environment, f, indent=2)

print(f"Wrote {OUT_DIR}/dt-api-v2.postman_collection.json")
print(f"  Total folders: {len(collection['item'])}")
total_requests = 0
for folder in collection['item']:
    print(f"  {folder['name']}: {len(folder['item'])} requests")
    total_requests += len(folder['item'])
print(f"  Total requests: {total_requests}")
print()
print(f"Wrote {OUT_DIR}/dt-api-v2.postman_environment.json")
