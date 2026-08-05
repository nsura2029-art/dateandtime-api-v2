#!/usr/bin/env bash
# scripts/seed/census_india_publish.sh
#
# M11.7: Publish Census of India 2011 PCA-UA source files to R2 + register
# source_releases.
#
# Uploads:
#   1. PCA11-UA-0000.xlsx → r2://dt-data-raw/raw/in_census/pca-ua/2024/...
#
# Then registers in source_registry + source_releases.
#
# Usage:
#   ./scripts/seed/census_india_publish.sh

set -euo pipefail

ACCOUNT="f0de6c4b68becd81e60507ecf9410199"
DB_ID="ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN env var}"
R2_BUCKET="dt-data-raw"
R2_KEY_ID="9a8901b42630218c855a9ea26a7d0255"
R2_SECRET="a0f1c0010a51405299ec2ad6b0c2d5d1e2876f7d51335a3992589e12f6c0c9c9"
R2_ENDPOINT="https://f0de6c4b68becd81e60507ecf9410199.r2.cloudflarestorage.com"

echo "=== M11.7: Publish Census of India PCA-UA to R2 + source_releases ==="

# 1. Upload PCA-UA XLSX to R2
echo ""
echo "Step 1: Upload PCA11-UA-0000.xlsx to R2 ..."
mkdir -p tmp
if [ ! -f tmp/pca_ua_2011.xlsx ]; then
  echo "  Downloading PCA-UA XLSX first ..."
  curl -k -s -L -o tmp/pca_ua_2011.xlsx \
    "https://censusindia.gov.in/nada/index.php/catalog/45261/download/48987/PCA11-UA-0000.xlsx"
fi
FILE_SIZE=$(stat -c%s tmp/pca_ua_2011.xlsx)
echo "  Local file: tmp/pca_ua_2011.xlsx ($FILE_SIZE bytes)"

python3 -c "
import boto3
s3 = boto3.client('s3',
  endpoint_url='$R2_ENDPOINT',
  aws_access_key_id='$R2_KEY_ID',
  aws_secret_access_key='$R2_SECRET')
s3.upload_file('tmp/pca_ua_2011.xlsx', '$R2_BUCKET', 'raw/in_census/pca-ua/2024/PCA11-UA-0000.xlsx',
    ExtraArgs={'CacheControl': 'public, max-age=31536000'})
print('  Uploaded via boto3')
"
echo "  ✓ PCA-UA uploaded to R2"

# 2. Register in source_registry
echo ""
echo "Step 2: Register in source_registry ..."
export TOKEN
python3 <<'PYEOF'
import urllib.request, json, os, time
TOKEN = os.environ["CLOUDFLARE_API_TOKEN"]
ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"

def q(sql, params=None):
    body = {"sql": sql}
    if params:
        body["params"] = params
    req = urllib.request.Request(
        f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT}/d1/database/{DB_ID}/query",
        data=json.dumps(body).encode(), method="POST",
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())

now_ms = int(time.time() * 1000)
today = "2026-08-03"

q("""
  INSERT INTO source_registry
  (source_key, publisher, dataset, coverage, access_method, endpoint_url,
   license, license_url, attribution, refresh_policy, known_limitations,
   is_active, created_at, updated_at)
  VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?)
  ON CONFLICT(source_key) DO UPDATE SET
    is_active=1,
    updated_at=excluded.updated_at
""", [
    "census_india",
    "Office of the Registrar General & Census Commissioner, India",
    "PCA11-UA (Primary Census Abstract - Urban Agglomeration) 2011",
    "IN (7 states/UTs, ~7,933 towns total, 422 matched to our DB so far)",
    "https-xlsx",
    "https://censusindia.gov.in/nada/index.php/catalog/45261/download/48987/PCA11-UA-0000.xlsx",
    "Open Government Data (India)",
    "https://censusindia.gov.in/nada/index.php/catalog",
    "© Office of the Registrar General & Census Commissioner, India",
    "decennial",
    "2011 is the latest official Census of India (2021 delayed by COVID). 3,762 of our IN cities have no state assigned and need additional data. Coverage is currently 422/7,467 = 5.7%; expect higher after re-runs.",
    now_ms, now_ms,
])
print("  ✓ source_registry: census_india registered (is_active=1)")
PYEOF

# 3. Register in source_releases
echo ""
echo "Step 3: Register in source_releases ..."
export TOKEN
python3 <<'PYEOF'
import urllib.request, json, os, time
TOKEN = os.environ["CLOUDFLARE_API_TOKEN"]
ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"

def q(sql, params=None):
    body = {"sql": sql}
    if params:
        body["params"] = params
    req = urllib.request.Request(
        f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT}/d1/database/{DB_ID}/query",
        data=json.dumps(body).encode(), method="POST",
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        return json.loads(r.read().decode())

now_ms = int(time.time() * 1000)
today = "2026-08-03"

q("""
  INSERT INTO source_releases
  (release_id, source_key, release_date, discovered_at, status,
   raw_size_bytes, raw_r2_key, row_count_accepted, started_at, finished_at, published_at)
  VALUES (?, ?, ?, ?, 'raw-stored', ?, ?, ?, ?, ?, ?)
  ON CONFLICT(release_id) DO UPDATE SET
    raw_size_bytes=excluded.raw_size_bytes,
    raw_r2_key=excluded.raw_r2_key,
    row_count_accepted=excluded.row_count_accepted,
    finished_at=excluded.finished_at,
    published_at=excluded.published_at
""", [
    "in-census-2011-2026-08-03",
    "census_india",
    today,
    now_ms,
    2031740,
    "raw/in_census/pca-ua/2024/PCA11-UA-0000.xlsx",
    422,
    now_ms, now_ms, now_ms,
])
print("  ✓ source_releases: in-census-2011-2026-08-03 registered (422 cities)")
PYEOF

echo ""
echo "=== M11.7 publish DONE ==="
echo "  R2: raw/in_census/pca-ua/2024/PCA11-UA-0000.xlsx (1.98 MB)"
echo "  source_registry: census_india (is_active=1)"
echo "  source_releases: in-census-2011-2026-08-03 (422 cities)"
