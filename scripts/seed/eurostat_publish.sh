#!/usr/bin/env bash
# scripts/seed/eurostat_publish.sh
#
# M11.6: Publish Eurostat source files to R2 + register in source_releases
#
# Uploads:
#   1. LAU_RG_01M_2024_3035.csv → r2://dt-data-raw/raw/eurostat/lau/2024/...
#   2. URAU_AT_2024.csv → r2://dt-data-raw/raw/eurostat/urau/2024/...
#
# Then registers both in source_releases + flips source_registry is_active.
#
# Usage:
#   ./scripts/seed/eurostat_publish.sh

set -euo pipefail

ACCOUNT="f0de6c4b68becd81e60507ecf9410199"
DB_ID="ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN="${CLOUDFLARE_API_TOKEN:?Set CLOUDFLARE_API_TOKEN env var}"
R2_BUCKET="dt-data-raw"
R2_KEY_ID="9a8901b42630218c855a9ea26a7d0255"
R2_SECRET="a0f1c0010a51405299ec2ad6b0c2d5d1e2876f7d51335a3992589e12f6c0c9c9"
R2_ENDPOINT="https://f0de6c4b68becd81e60507ecf9410199.r2.cloudflarestorage.com"

echo "=== M11.6: Publish Eurostat source files to R2 + source_releases ==="

# 1. Upload LAU CSV to R2
echo ""
echo "Step 1: Upload LAU_RG_01M_2024_3035.csv to R2 ..."
mkdir -p tmp
if [ ! -f tmp/lau_2024.csv ]; then
  echo "  Downloading LAU CSV first ..."
  curl -s "https://gisco-services.ec.europa.eu/distribution/v2/lau/csv/LAU_RG_01M_2024_3035.csv" \
    -o tmp/lau_2024.csv
fi
LAU_SIZE=$(stat -c%s tmp/lau_2024.csv)
echo "  Local file: tmp/lau_2024.csv ($LAU_SIZE bytes)"

python3 -c "
import boto3
s3 = boto3.client('s3',
  endpoint_url='$R2_ENDPOINT',
  aws_access_key_id='$R2_KEY_ID',
  aws_secret_access_key='$R2_SECRET')
s3.upload_file('tmp/lau_2024.csv', '$R2_BUCKET', 'raw/eurostat/lau/2024/LAU_RG_01M_2024_3035.csv',
    ExtraArgs={'CacheControl': 'public, max-age=31536000'})
print('  Uploaded via boto3')
"
echo "  ✓ LAU uploaded to R2"

# 2. Upload URAU CSV to R2
echo ""
echo "Step 2: Upload URAU_AT_2024.csv to R2 ..."
if [ ! -f tmp/urau_at.csv ]; then
  echo "  Downloading URAU CSV first ..."
  curl -s "https://gisco-services.ec.europa.eu/distribution/v2/urau/csv/URAU_AT_2024.csv" \
    -o tmp/urau_at.csv
fi
URAU_SIZE=$(stat -c%s tmp/urau_at.csv)
echo "  Local file: tmp/urau_at.csv ($URAU_SIZE bytes)"

python3 -c "
import boto3
s3 = boto3.client('s3',
  endpoint_url='$R2_ENDPOINT',
  aws_access_key_id='$R2_KEY_ID',
  aws_secret_access_key='$R2_SECRET')
s3.upload_file('tmp/urau_at.csv', '$R2_BUCKET', 'raw/eurostat/urau/2024/URAU_AT_2024.csv',
    ExtraArgs={'CacheControl': 'public, max-age=31536000'})
print('  Uploaded via boto3')
"
echo "  ✓ URAU uploaded to R2"

# 3. Register in source_registry
echo ""
echo "Step 3: Register eurostat source in source_registry ..."
export TOKEN
python3 <<'PYEOF'
import urllib.request, json, os
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

# Upsert source_registry (correct schema: source_key, publisher, dataset, coverage, ...)
now_ms = int(__import__('time').time() * 1000)
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
    "eurostat_lau",
    "Eurostat",
    "LAU 2024",
    "EU30 (30 countries)",
    "https-zip",
    "https://gisco-services.ec.europa.eu/distribution/v2/lau/csv/LAU_RG_01M_2024_3035.csv",
    "CC-BY 4.0",
    "https://ec.europa.eu/eurostat/web/gisco/geodata/administrative-units/local-administrative-units",
    "© Eurostat, 2024",
    "annual",
    "FR/ES/AL/IS/RS have pop_2024=0 (national privacy laws)",
    now_ms, now_ms,
])

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
    "eurostat_urau",
    "Eurostat",
    "URAU 2024 (City vs FUA)",
    "EU30 (Cities + FUAs, ~1,332 records)",
    "https-csv",
    "https://gisco-services.ec.europa.eu/distribution/v2/urau/csv/URAU_AT_2024.csv",
    "CC-BY 4.0",
    "https://ec.europa.eu/eurostat/web/gisco/geodata/administrative-units/urban-audit",
    "© Eurostat, 2024",
    "annual",
    "Filename says _AT but file is pan-EU",
    now_ms, now_ms,
])
print("  ✓ source_registry: eurostat_lau + eurostat_urau registered (is_active=1)")
PYEOF

# 4. Register in source_releases
echo ""
echo "Step 4: Register in source_releases ..."
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
    "eurostat-lau-2024-2026-08-03",
    "eurostat_lau",
    today,
    now_ms,
    5673800,
    "raw/eurostat/lau/2024/LAU_RG_01M_2024_3035.csv",
    97987,
    now_ms, now_ms, now_ms,
])

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
    "eurostat-urau-2024-2026-08-03",
    "eurostat_urau",
    today,
    now_ms,
    63500,
    "raw/eurostat/urau/2024/URAU_AT_2024.csv",
    1332,
    now_ms, now_ms, now_ms,
])
print("  ✓ source_releases: 2 new entries")
PYEOF

echo ""
echo "=== M11.6 publish DONE ==="
echo "  R2: raw/eurostat/lau/2024/ + raw/eurostat/urau/2024/"
echo "  source_registry: eurostat_lau + eurostat_urau (is_active=1)"
echo "  source_releases: eurostat-lau-2024-2026-08-03 + eurostat-urau-2024-2026-08-03"
