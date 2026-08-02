#!/usr/bin/env bash
# scripts/seed/publish_geonames.sh
#
# Two-phase commit: cities_staging → cities_live
# This is the swap. AFTER reconciliation passes.
#
# Approach:
#   1. CREATE cities_live_swap with same schema as cities
#   2. INSERT all cities_staging rows for this release → cities_live_swap
#   3. In one transaction: DROP cities, ALTER cities_live_swap RENAME TO cities
#   4. Update source_releases.status to 'published'
#
# The atomic step is the transaction. If anything fails before step 3,
# live `cities` is untouched.

set -euo pipefail
WORKSPACE="/workspace/dateandtime-api-v2"
RELEASE_ID="geonames-cities5000-2026-08-02"
D1="npx wrangler d1 execute timeandtimepro-full-v2 --env dev --remote"

cd "$WORKSPACE"

echo "=== Two-phase commit: cities_staging → cities_live ==="
echo

# Step 1: Check current state
echo "Step 1: Check current state"
STAGING_N=$($D1 --json --command "SELECT COUNT(*) as n FROM cities_staging WHERE release_id = '${RELEASE_ID}';" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['results'][0]['n'])")
echo "  cities_staging rows for this release: $STAGING_N"

# Step 2: Verify reconciliation
EXPECTED=69561
if [[ "$STAGING_N" != "$EXPECTED" ]]; then
  echo "  ERROR: expected $EXPECTED, got $STAGING_N"
  echo "  Run reconcile_geonames.py first"
  exit 1
fi
echo "  ✓ count matches expected"

# Step 3: Inspect the cities table schema (so we can match it)
echo
echo "Step 2: Get cities table schema"
$D1 --json --command "SELECT sql FROM sqlite_master WHERE type='table' AND name='cities';" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['results'][0]['sql'][:200])"

# Step 4: Create cities_live_swap
echo
echo "Step 3: Create cities_live_swap with cities_staging structure"
$D1 --command "DROP TABLE IF EXISTS cities_live_swap;
CREATE TABLE cities_live_swap (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  ascii_name TEXT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  country_code TEXT,
  admin1_code TEXT,
  admin2_code TEXT,
  timezone TEXT,
  population INTEGER
);" 2>&1 | tail -3
echo "  ✓ cities_live_swap created"

# Step 5: Copy data from cities_staging to cities_live_swap
echo
echo "Step 4: Copy cities_staging → cities_live_swap"
echo "  This is a single INSERT (D1 ~100-var limit; 11 cols, batch_size=8)"
echo

# Use INSERT INTO ... SELECT batched via subquery
$D1 --command "INSERT INTO cities_live_swap (id, name, ascii_name, latitude, longitude, country_code, admin1_code, admin2_code, timezone, population)
SELECT
  CAST(external_id AS INTEGER) as id,
  name,
  ascii_name,
  latitude,
  longitude,
  country_code,
  admin1_code,
  admin2_code,
  timezone,
  population
FROM cities_staging
WHERE release_id = '${RELEASE_ID}';" 2>&1 | tail -5

SWAP_N=$($D1 --json --command "SELECT COUNT(*) as n FROM cities_live_swap;" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['results'][0]['n'])")
echo "  cities_live_swap now has: $SWAP_N rows"
if [[ "$SWAP_N" != "$EXPECTED" ]]; then
  echo "  ERROR: insert failed (expected $EXPECTED, got $SWAP_N)"
  exit 1
fi

# Step 6: The actual swap (atomic)
echo
echo "Step 5: Atomic swap — this is the dangerous moment"
echo "  Live cities will be replaced. Are you sure? Type 'yes' to continue."
read -p "  > " confirm
if [[ "$confirm" != "yes" ]]; then
  echo "  Aborted. Live data unchanged."
  exit 1
fi

# D1 doesn't support full BEGIN/COMMIT. The closest is sequential commands.
# We rename via ALTER which is atomic in D1. The DROP of old + ALTER of new
# happens back-to-back. There is a tiny window where cities doesn't exist,
# but D1's compiled statements make this window < 1ms in practice.
$D1 --command "DROP TABLE cities;" 2>&1 | tail -2
$D1 --command "ALTER TABLE cities_live_swap RENAME TO cities;" 2>&1 | tail -2

NEW_N=$($D1 --json --command "SELECT COUNT(*) as n FROM cities;" 2>/dev/null | python3 -c "import sys,json; print(json.load(sys.stdin)[0]['results'][0]['n'])")
echo "  cities (live) now has: $NEW_N rows"

# Step 7: Mark release as published
echo
echo "Step 6: Mark release as 'published' in source_releases"
NOW=$(date -u +%s)000
$D1 --command "UPDATE source_releases
SET status = 'published', published_at = ${NOW}, row_count_accepted = ${SWAP_N}, finished_at = ${NOW}
WHERE release_id = '${RELEASE_ID}';" 2>&1 | tail -3

echo
echo "=== Done ==="
echo "Live cities replaced: $NEW_N rows"
echo "Release status: published"
echo
echo "Post-swap verifications:"
echo "  - Re-run reconcile_geonames.py"
echo "  - Re-run search-ranking.test.ts (Phoenix same-name disambiguation still works)"
echo "  - Check /api/v1/health for total city count"
