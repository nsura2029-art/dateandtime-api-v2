#!/usr/bin/env bash
# scripts/apply-all.sh
#
# One-shot script: clean cities, re-apply, verify count.
# After this, run npm run deploy:dev to push code.
#
# Usage:
#   bash scripts/apply-all.sh
#
# Requires:
#   - CLOUDFLARE_API_TOKEN exported in this shell
#   - CLOUDFLARE_ACCOUNT_ID exported in this shell
#   - wrangler available (via npx or globally)
#
# Expected output: "Cities: 152970"

set -euo pipefail

DB_NAME="timeandtimepro-full-v2"
APPLY_LOG="cities-apply.log"

# Colors (for nicer output)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "================================================="
echo " dateandtime-api-v2 — apply-all.sh"
echo "================================================="
echo ""

# 1. Sanity check: token present?
if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
  echo -e "${RED}✗ CLOUDFLARE_API_TOKEN not set in this shell.${NC}"
  echo "  Run: export CLOUDFLARE_API_TOKEN=\"...\""
  exit 1
fi
if [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
  echo -e "${RED}✗ CLOUDFLARE_ACCOUNT_ID not set in this shell.${NC}"
  echo "  Run: export CLOUDFLARE_ACCOUNT_ID=\"f0de6c4b68becd81e60507ecf9410199\""
  exit 1
fi

# 2. Sanity check: wrangler available?
if ! npx wrangler --version >/dev/null 2>&1; then
  echo -e "${RED}✗ wrangler not found.${NC}"
  echo "  Run: npm ci (installs wrangler as a dev dep)"
  exit 1
fi

# 3. Sanity check: cities/*.sql files present?
CITY_FILES=$(ls migrations/cities/*.sql 2>/dev/null | wc -l)
if [ "$CITY_FILES" -lt 200 ]; then
  echo -e "${RED}✗ Only $CITY_FILES city files found.${NC}"
  echo "  Run: py scripts/seed/107_generate_cities.py"
  exit 1
fi
echo -e "${GREEN}✓ Found $CITY_FILES city files${NC}"

# 4. Confirm before destructive action
echo ""
echo -e "${YELLOW}This will:${NC}"
echo "  1. DELETE all rows from cities in $DB_NAME"
echo "  2. Re-apply all $CITY_FILES country files (~5-15 min)"
echo "  3. Verify final count"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

# 5. DELETE
echo ""
echo -e "${GREEN}[1/3]${NC} Deleting existing cities..."
DELETED=$(npx wrangler d1 execute "$DB_NAME" --env dev --remote --json --command="DELETE FROM cities;" 2>&1)
echo "$DELETED" | head -5

# 6. Verify empty
echo ""
echo -e "${GREEN}[2/3]${NC} Verifying cities is empty..."
COUNT=$(npx wrangler d1 execute "$DB_NAME" --env dev --remote --json --command="SELECT COUNT(*) AS n FROM cities;" 2>&1 | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['results'][0]['n'])" 2>/dev/null || echo "PARSE_ERROR")
if [ "$COUNT" != "0" ]; then
  echo -e "${RED}✗ Cities count is $COUNT, not 0. Aborting.${NC}"
  exit 1
fi
echo -e "${GREEN}✓ Cities is empty (0 rows)${NC}"

# 7. Apply all cities
echo ""
echo -e "${GREEN}[3/3]${NC} Applying all $CITY_FILES country files..."
echo "  This takes 5-15 minutes. Log: $APPLY_LOG"
DB_NAME="$DB_NAME" REMOTE=1 bash migrations/cities/run-all.sh > "$APPLY_LOG" 2>&1
APPLY_EXIT=$?

if [ $APPLY_EXIT -ne 0 ]; then
  echo -e "${RED}✗ run-all.sh exited with $APPLY_EXIT${NC}"
  echo "  See $APPLY_LOG for details"
  exit 1
fi

# 8. Count errors
FK_ERRORS=$(grep -c 'FOREIGN KEY' "$APPLY_LOG" 2>/dev/null || echo 0)
PK_ERRORS=$(grep -c 'PRIMARYKEY' "$APPLY_LOG" 2>/dev/null || echo 0)
echo ""
echo "  Errors in log:"
echo "    FK constraint failures:    $FK_ERRORS"
echo "    PRIMARY KEY duplicates:    $PK_ERRORS"

if [ "$FK_ERRORS" -gt 0 ] || [ "$PK_ERRORS" -gt 0 ]; then
  echo -e "${YELLOW}⚠ Some errors — see $APPLY_LOG for which files failed${NC}"
fi

# 9. Final count
echo ""
echo -e "${GREEN}[Final]${NC} Counting cities..."
FINAL=$(npx wrangler d1 execute "$DB_NAME" --env dev --remote --json --command="SELECT COUNT(*) AS n FROM cities;" 2>&1 | python3 -c "import json,sys; d=json.load(sys.stdin); print(d[0]['results'][0]['n'])" 2>/dev/null || echo "PARSE_ERROR")

EXPECTED=152970
echo ""
echo "================================================="
if [ "$FINAL" = "$EXPECTED" ]; then
  echo -e "${GREEN}✓ Cities: $FINAL / $EXPECTED — perfect!${NC}"
elif [ "$FINAL" -gt "$((EXPECTED - 1000))" ] 2>/dev/null; then
  echo -e "${YELLOW}⚠ Cities: $FINAL / $EXPECTED — close, but some failed${NC}"
  echo "  Run: grep 'WARNING:' $APPLY_LOG | awk '{print \$2}' | sort -u"
  echo "  to find which countries failed"
else
  echo -e "${RED}✗ Cities: $FINAL / $EXPECTED — many failed${NC}"
  echo "  See $APPLY_LOG for details"
fi
echo "================================================="
echo ""
echo "Next: run 'npm run deploy:dev' to push the code."
echo "Then: curl https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/health"
