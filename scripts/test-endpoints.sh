#!/usr/bin/env bash
# test-endpoints.sh — Smoke test all implemented endpoints.
# Usage: BASE_URL=https://api.dateandtime.live ./scripts/test-endpoints.sh
#        (defaults to http://localhost:8787)

set -uo pipefail

BASE_URL="${BASE_URL:-http://localhost:8787}"
PASS=0
FAIL=0

# ANSI colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

check() {
  local name="$1"
  local method="$2"
  local path="$3"
  local expected="${4:-200}"
  local extra="${5:-}"

  local code
  code=$(curl -s -o /dev/null -w "%{http_code}" -X "$method" \
    "${BASE_URL}${path}${extra}" \
    -H "Accept: application/json" \
    --max-time 10 2>/dev/null || echo "000")

  if [ "$code" = "$expected" ]; then
    echo -e "  ${GREEN}✓${NC} ${method} ${path} ${GREEN}${code}${NC}"
    ((PASS++))
  else
    echo -e "  ${RED}✗${NC} ${method} ${path} expected=${expected} got=${code}"
    ((FAIL++))
  fi
}

echo "Testing ${BASE_URL}"
echo ""

echo "=== Health + version ==="
check "API root"        GET  "/"                          200
check "Health"          GET  "/api/v1/health"              200
check "Health HEAD"     HEAD "/api/v1/health"              200
check "Status"          GET  "/api/v1/status"              200
check "Status HEAD"     HEAD "/api/v1/status"              200
check "OpenAPI spec"    GET  "/openapi.json"               200
check "Swagger UI"      GET  "/docs"                       200

echo ""
echo "=== Cities (Phase 1) ==="
check "Cities list"     GET  "/api/v1/cities"              200 "?limit=1"
check "Cities HEAD"     HEAD "/api/v1/cities"              200
check "City by id"      GET  "/api/v1/cities/5128581"       200
check "City search"     GET  "/api/v1/cities/search"       200 "?q=York&limit=1"
check "City near"       GET  "/api/v1/cities/near"         200 "?lat=40.7&lon=-74&r=50"
check "City climate"    GET  "/api/v1/cities/5128581/climate" 200
check "City aliases"    GET  "/api/v1/cities/5128581/aliases"  200

echo ""
echo "=== Countries (Phase 1) ==="
check "Countries list"  GET  "/api/v1/countries"           200 "?limit=1"
check "Country US"      GET  "/api/v1/countries/US"        200
check "US cities"       GET  "/api/v1/countries/US/cities" 200 "?limit=1"
check "US work hours"   GET  "/api/v1/countries/US/working-hours" 200

echo ""
echo "=== Time ==="
check "Timezones"       GET  "/api/v1/timezones"           200 "?limit=1"
check "Timezone NYC"    GET  "/api/v1/timezones/America/New_York" 200
check "Time now"        GET  "/api/v1/time/now"             200 "?tz=UTC"
check "Time sun"        GET  "/api/v1/time/sun"             200 "?lat=40.7&lon=-74&date=2026-07-31"

echo ""
echo "=== Content (Phase 2-4) ==="
check "Holidays 2026"   GET  "/api/v1/holidays"            200 "?country=US&year=2026"
check "Holidays today"  GET  "/api/v1/holidays/today"      200 "?country=US"
check "Holidays upcom"  GET  "/api/v1/holidays/upcoming"   200 "?country=US&days=30"
check "Onthisday"       GET  "/api/v1/onthisday"           200 "?month=7&day=20"
check "DST upcoming"    GET  "/api/v1/dst/upcoming"        200 "?tz=America/New_York"
check "Popular"         GET  "/api/v1/popular/cities"      200 "?limit=1"
check "Defaults"        GET  "/api/v1/popular/defaults"     200
check "Search v2"       GET  "/api/v2/search"              200 "?q=Tokyo&limit=1"

echo ""
echo "=== Feedback (Phase 7) ==="
check "Feedback list"   GET  "/api/v1/feedback"            200 "?limit=1"
check "Feedback top"    GET  "/api/v1/feedback/top"        200 "?limit=1"
check "Data quality"    GET  "/api/v1/admin/data-quality"  200

echo ""
echo "=== Negative cases ==="
check "404 unknown"     GET  "/api/v1/does-not-exist"      404
check "Cities bad id"   GET  "/api/v1/cities/abc"          400
check "Sun no lat"      GET  "/api/v1/time/sun"            400

echo ""
echo "=========================================="
if [ $FAIL -eq 0 ]; then
  echo -e "${GREEN}All ${PASS} checks passed${NC}"
  exit 0
else
  echo -e "${RED}${FAIL} failed, ${PASS} passed${NC}"
  exit 1
fi
