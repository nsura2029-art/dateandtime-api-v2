#!/usr/bin/env bash
# scripts/seed/us_census_publish.sh
#
# M11.5: Publish US Census Bureau data to R2 and register source_releases
# rows for the Gazetteer and SUB-EST2025 datasets.
#
# Pre-conditions: us_gazetteer_to_d1.py and us_census_population_to_d1.py
# have already been run (D1 has the rows).
#
# Steps:
#   1. Compute SHA-256 of the raw data files
#   2. Generate manifest.json for each
#   3. Upload raw + manifest to R2
#   4. Insert/upsert source_releases rows

set -euo pipefail
WORKSPACE="$(cd "$(dirname "$0")/../.." && pwd)"
TODAY=$(date -u +%Y-%m-%d)
CF_ACCOUNT_ID="${CF_ACCOUNT_ID:-f0de6c4b68becd81e60507ecf9410199}"
CF_TOKEN="${CLOUDFLARE_API_TOKEN:-cfat_UyDDIlvZHHGSTdPKhvOLyCjlfWVMjLeielerTwDYe64c8626}"
R2_ACCESS_KEY_ID="${R2_ACCESS_KEY_ID:-9a8901b42630218c855a9ea26a7d0255}"
R2_SECRET_ACCESS_KEY="${R2_SECRET_ACCESS_KEY:-a0f1c0010a51405299ec2ad6b0c2d5d1e2876f7d51335a3992589e12f6c0c9c9}"
R2_BUCKET_RAW="dt-data-raw"

cd "$WORKSPACE"
mkdir -p tmp

echo "=== M11.5: Publish US Census data to R2 ==="
echo

# Get the actual release_ids from D1
GAZ_RELEASE_ID=$(curl -s "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/d1/database/ab54b1d7-6791-4d29-a94c-c95e6a560b7e/query" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"sql":"SELECT DISTINCT gaz_release_id FROM us_census_attributes WHERE gaz_release_id IS NOT NULL LIMIT 1"}' | python3 -c "import json, sys; print(json.load(sys.stdin)['result'][0]['results'][0]['gaz_release_id'])")
EST_RELEASE_ID=$(curl -s "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/d1/database/ab54b1d7-6791-4d29-a94c-c95e6a560b7e/query" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  --data '{"sql":"SELECT DISTINCT release_id FROM us_census_attributes WHERE release_id IS NOT NULL AND release_id LIKE \u0027us-census-sub-est%\u0027 LIMIT 1"}' | python3 -c "import json, sys; print(json.load(sys.stdin)['result'][0]['results'][0]['release_id'])")

echo "  Gazetteer release: $GAZ_RELEASE_ID"
echo "  SUB-EST release: $EST_RELEASE_ID"
echo

# Publish Gazetteer 2024
echo "--- Gazetteer 2024 ---"
GAZ_FILE="$WORKSPACE/tmp/gaz_2024.zip"
GAZ_SHA=$(sha256sum "$GAZ_FILE" | awk '{print $1}')
GAZ_SIZE=$(stat -c%s "$GAZ_FILE")
GAZ_R2_KEY="raw/us_census/gazetteer/2024/${TODAY}/2024_Gaz_place_national.zip"

# Count rows in D1 for verification
GAZ_D1_COUNT=$(curl -s "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/d1/database/ab54b1d7-6791-4d29-a94c-c95e6a560b7e/query" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"sql\":\"SELECT COUNT(*) as n FROM us_census_attributes WHERE gaz_release_id = '${GAZ_RELEASE_ID}'\"}" | python3 -c "import json, sys; print(json.load(sys.stdin)['result'][0]['results'][0]['n'])")
echo "  D1 rows: $GAZ_D1_COUNT, raw size: $GAZ_SIZE bytes"

# Manifest
GAZ_MANIFEST="$WORKSPACE/tmp/gaz_2024_manifest.json"
cat > "$GAZ_MANIFEST" <<EOF
{
  "release_id": "${GAZ_RELEASE_ID}",
  "source_key": "us_census",
  "dataset": "gazetteer-2024",
  "release_date": "${TODAY}",
  "api_url": "https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2024_Gazetteer/2024_Gaz_place_national.zip",
  "row_count_loaded": ${GAZ_D1_COUNT},
  "raw": {
    "filename": "2024_Gaz_place_national.zip",
    "size_bytes": ${GAZ_SIZE},
    "sha256": "${GAZ_SHA}"
  }
}
EOF

# Upload to R2
python3 << PYEOF
import os
import boto3
from pathlib import Path

bucket = "${R2_BUCKET_RAW}"
key_prefix = f"raw/us_census/gazetteer/2024/${TODAY}"
files = ["gaz_2024.zip", "gaz_2024_manifest.json"]

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
    print(f"  Uploading {fname} → r2://{bucket}/{key}")
    s3.upload_file(str(src), bucket, key)
print("  ✓ R2 upload complete")
PYEOF

# Register source_release
NOW_MS=$(date -u +%s)000
npx wrangler d1 execute timeandtimepro-full-v2 --remote --command "INSERT OR REPLACE INTO source_releases
  (release_id, source_key, release_date, discovered_at, status,
   raw_sha256, raw_size_bytes, raw_r2_key, manifest_r2_key, row_count_accepted, started_at, finished_at)
VALUES
  ('${GAZ_RELEASE_ID}', 'us_census', '${TODAY}', ${NOW_MS}, 'raw-stored',
   '${GAZ_SHA}', ${GAZ_SIZE}, '${GAZ_R2_KEY}', '${GAZ_R2_KEY%.zip}manifest.json', ${GAZ_D1_COUNT}, ${NOW_MS}, ${NOW_MS});" 2>&1 | tail -3

# Publish SUB-EST2025
echo
echo "--- SUB-EST2025 ---"
EST_FILE="$WORKSPACE/tmp/sub-est2025.csv"
EST_SHA=$(sha256sum "$EST_FILE" | awk '{print $1}')
EST_SIZE=$(stat -c%s "$EST_FILE")
EST_R2_KEY="raw/us_census/sub-est/2025/${TODAY}/sub-est2025.csv"

EST_D1_COUNT=$(curl -s "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID}/d1/database/ab54b1d7-6791-4d29-a94c-c95e6a560b7e/query" \
  -H "Authorization: Bearer ${CF_TOKEN}" \
  -H "Content-Type: application/json" \
  --data "{\"sql\":\"SELECT COUNT(*) as n FROM us_census_attributes WHERE release_id = '${EST_RELEASE_ID}'\"}" | python3 -c "import json, sys; print(json.load(sys.stdin)['result'][0]['results'][0]['n'])")
echo "  D1 rows: $EST_D1_COUNT, raw size: $EST_SIZE bytes"

EST_MANIFEST="$WORKSPACE/tmp/sub-est_2025_manifest.json"
cat > "$EST_MANIFEST" <<EOF
{
  "release_id": "${EST_RELEASE_ID}",
  "source_key": "us_census",
  "dataset": "sub-est-2025",
  "release_date": "${TODAY}",
  "api_url": "https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv",
  "row_count_loaded": ${EST_D1_COUNT},
  "raw": {
    "filename": "sub-est2025.csv",
    "size_bytes": ${EST_SIZE},
    "sha256": "${EST_SHA}"
  }
}
EOF

python3 << PYEOF
import os
import boto3
from pathlib import Path

bucket = "${R2_BUCKET_RAW}"
key_prefix = f"raw/us_census/sub-est/2025/${TODAY}"
files = ["sub-est2025.csv", "sub-est_2025_manifest.json"]

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
    print(f"  Uploading {fname} → r2://{bucket}/{key}")
    s3.upload_file(str(src), bucket, key)
print("  ✓ R2 upload complete")
PYEOF

npx wrangler d1 execute timeandtimepro-full-v2 --remote --command "INSERT OR REPLACE INTO source_releases
  (release_id, source_key, release_date, discovered_at, status,
   raw_sha256, raw_size_bytes, raw_r2_key, manifest_r2_key, row_count_accepted, started_at, finished_at)
VALUES
  ('${EST_RELEASE_ID}', 'us_census', '${TODAY}', ${NOW_MS}, 'raw-stored',
   '${EST_SHA}', ${EST_SIZE}, '${EST_R2_KEY}', '${EST_R2_KEY%.csv}manifest.json', ${EST_D1_COUNT}, ${NOW_MS}, ${NOW_MS});" 2>&1 | tail -3

# Update source_registry to make us_census active
echo
echo "--- Update source_registry ---"
npx wrangler d1 execute timeandtimepro-full-v2 --remote --command "UPDATE source_registry SET is_active = 1, updated_at = ${NOW_MS} WHERE source_key = 'us_census';" 2>&1 | tail -3

echo
echo "=== Done ==="
echo "Gazetteer: $GAZ_RELEASE_ID ($GAZ_D1_COUNT cities)"
echo "SUB-EST: $EST_RELEASE_ID ($EST_D1_COUNT cities)"
echo "R2: r2://${R2_BUCKET_RAW}/raw/us_census/..."
