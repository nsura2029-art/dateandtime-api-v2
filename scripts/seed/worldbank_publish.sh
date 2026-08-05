#!/usr/bin/env bash
# scripts/seed/worldbank_publish.sh
#
# M11.4: Publish World Bank country population data to R2 and register
# source_releases row.
#
# Pre-conditions: worldbank_to_d1.py has already been run (D1 has the rows).
#
# Steps:
#   1. Compute SHA-256 of the raw JSON dump (tmp/worldbank_pop_2024.json)
#   2. Generate manifest.json with per-country stats
#   3. Upload raw JSON + manifest to R2 at raw/world_bank/pop-totl/2026-08-02/
#   4. Insert source_releases row (status=raw-stored, row_count=216)

set -euo pipefail
WORKSPACE="$(cd "$(dirname "$0")/../.." && pwd)"
TODAY=$(date -u +%Y-%m-%d)
RELEASE_ID="worldbank-pop-2024-${TODAY}"
SOURCE_KEY="world_bank"
DATASET="pop-totl"
YEAR="2024"
RAW_FILE="$WORKSPACE/tmp/worldbank_pop_2024.json"
R2_BUCKET_RAW="dt-data-raw"

cd "$WORKSPACE"

echo "=== M11.4: Publish World Bank data to R2 ==="
echo
echo "Release: $RELEASE_ID"
echo

# Step 1: Compute SHA-256 and size
echo "Step 1: Compute SHA-256 of raw JSON ..."
RAW_SHA=$(sha256sum "$RAW_FILE" | awk '{print $1}')
RAW_SIZE=$(stat -c%s "$RAW_FILE")
echo "  SHA-256: $RAW_SHA"
echo "  Size: $RAW_SIZE bytes"

# Step 2: Generate manifest.json
echo
echo "Step 2: Generate manifest.json ..."
MANIFEST_FILE="$WORKSPACE/tmp/worldbank_manifest.json"
NOW_MS=$(date -u +%s)000

# Get row count from D1
ROW_COUNT=$(curl -s "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID:-f0de6c4b68becd81e60507ecf9410199}/d1/database/ab54b1d7-6791-4d29-a94c-c95e6a560b7e/query" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN:-cfat_UyDDIlvZHHGSTdPKhvOLyCjlfWVMjLeielerTwDYe64c8626}" \
  -H "Content-Type: application/json" \
  --data "{\"sql\":\"SELECT COUNT(*) as n FROM country_populations WHERE release_id = '${RELEASE_ID}'\"}" | python3 -c "import json, sys; r = json.load(sys.stdin); print(r['result'][0]['results'][0]['n'])")
echo "  Rows in D1: $ROW_COUNT"

cat > "$MANIFEST_FILE" <<EOF
{
  "release_id": "${RELEASE_ID}",
  "source_key": "${SOURCE_KEY}",
  "dataset": "${DATASET}",
  "indicator": "SP.POP.TOTL",
  "year": ${YEAR},
  "release_date": "${TODAY}",
  "api_url": "https://api.worldbank.org/v2/country/all/indicator/SP.POP.TOTL?format=json&date=2024&per_page=400",
  "row_count_loaded": ${ROW_COUNT},
  "raw": {
    "filename": "worldbank_pop_2024.json",
    "size_bytes": ${RAW_SIZE},
    "sha256": "${RAW_SHA}"
  }
}
EOF
echo "  Created: $MANIFEST_FILE"

# Step 3: Upload to R2
echo
echo "Step 3: Upload to R2 ..."
python3 << PYEOF
import os
import boto3
from pathlib import Path

bucket = "${R2_BUCKET_RAW}"
key_prefix = f"raw/${SOURCE_KEY}/${DATASET}/${TODAY}"
files = ["worldbank_pop_2024.json", "worldbank_manifest.json"]
files += [f"worldbank_manifest.json"]

s3 = boto3.client(
    "s3",
    endpoint_url=f"https://{os.environ['CF_ACCOUNT_ID']}.r2.cloudflarestorage.com",
    aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
    aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"],
)

workspace = Path("${WORKSPACE}")
for fname in files:
    src = workspace / "tmp" / fname
    if not src.exists():
        print(f"  SKIP: {fname} not found")
        continue
    key = f"{key_prefix}/{fname}"
    print(f"  Uploading {fname} ({src.stat().st_size:,} bytes) → r2://{bucket}/{key}")
    s3.upload_file(str(src), bucket, key)

print("  ✓ R2 upload complete")
PYEOF

# Step 4: Register source_releases row
echo
echo "Step 4: Register source_releases row ..."
RAW_KEY="raw/${SOURCE_KEY}/${DATASET}/${TODAY}/worldbank_pop_2024.json"
MANIFEST_KEY="raw/${SOURCE_KEY}/${DATASET}/${TODAY}/worldbank_manifest.json"

npx wrangler d1 execute timeandtimepro-full-v2 --remote --command "INSERT OR REPLACE INTO source_releases
  (release_id, source_key, release_date, discovered_at, status,
   raw_sha256, raw_size_bytes, raw_r2_key, manifest_r2_key, row_count_accepted, started_at, finished_at)
VALUES
  ('${RELEASE_ID}', '${SOURCE_KEY}', '${TODAY}', ${NOW_MS}, 'raw-stored',
   '${RAW_SHA}', ${RAW_SIZE}, '${RAW_KEY}', '${MANIFEST_KEY}', ${ROW_COUNT}, ${NOW_MS}, ${NOW_MS});" 2>&1 | tail -3

echo
echo "=== Done ==="
echo "Release: $RELEASE_ID (raw-stored, $ROW_COUNT countries)"
echo "R2 location: r2://${R2_BUCKET_RAW}/raw/${SOURCE_KEY}/${DATASET}/${TODAY}/"
