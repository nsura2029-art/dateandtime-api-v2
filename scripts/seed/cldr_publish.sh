#!/usr/bin/env bash
# scripts/seed/cldr_publish.sh
#
# M11.3: Publish CLDR data to R2 and register source_releases row.
#
# Steps:
#   1. Compress the 20 XML files into a tarball + manifest
#   2. Upload to R2 at raw/cldr/cldr-48.2/2026-08-02/
#   3. Insert source_releases row (status=raw-stored)
#
# Pre-conditions: cldr_to_d1.py has already been run.

set -euo pipefail
WORKSPACE="$(cd "$(dirname "$0")/../.." && pwd)"
SOURCE_KEY="cldr"
DATASET="territories"
CLDR_VERSION="48.2"
TODAY=$(date -u +%Y-%m-%d)
# Use a consistent release_id with cldr_to_d1.py
RELEASE_ID="${SOURCE_KEY}-${DATASET}-${TODAY}"
R2_KEY_DATASET="${SOURCE_KEY}/territories-${CLDR_VERSION}"
TMP_DIR="$WORKSPACE/tmp/cldr-extract"
R2_BUCKET_RAW="dt-data-raw"

cd "$WORKSPACE"

echo "=== M11.3: Publish CLDR data to R2 ==="
echo
echo "Release: $RELEASE_ID"
echo "Source:  Unicode CLDR 48.2 (https://cldr.unicode.org/)"
echo

# Step 1: Bundle the 20 target language XML files into a single tarball
echo "Step 1: Bundle 20 target language XMLs into tarball ..."
BUNDLE_DIR="$WORKSPACE/tmp/cldr-bundle"
rm -rf "$BUNDLE_DIR"
mkdir -p "$BUNDLE_DIR/xmls"
LANGS=(en es fr de zh ja ko ru ar hi pt it tr nl pl sv uk he fa th)
for lang in "${LANGS[@]}"; do
    if [ -f "$TMP_DIR/common/main/${lang}.xml" ]; then
        cp "$TMP_DIR/common/main/${lang}.xml" "$BUNDLE_DIR/xmls/"
    else
        echo "  WARNING: ${lang}.xml not found, skipping"
    fi
done

# Create tarball
TARBALL="$BUNDLE_DIR/cldr-territories-20langs.tar.gz"
tar -czf "$TARBALL" -C "$BUNDLE_DIR/xmls" .
TARBALL_SIZE=$(stat -c%s "$TARBALL")
TARBALL_SHA=$(sha256sum "$TARBALL" | awk '{print $1}')
echo "  Created: $TARBALL (${TARBALL_SIZE} bytes, sha256=${TARBALL_SHA:0:16}...)"

# Create manifest.json
MANIFEST="$BUNDLE_DIR/manifest.json"
cat > "$MANIFEST" <<EOF
{
  "release_id": "${RELEASE_ID}",
  "source_key": "${SOURCE_KEY}",
  "dataset": "${DATASET}",
  "cldr_version": "${CLDR_VERSION}",
  "release_date": "${TODAY}",
  "cldr_version": "${CLDR_VERSION}",
  "languages": [$(printf '"%s",' "${LANGS[@]}" | sed 's/,$//')],
  "language_count": ${#LANGS[@]},
  "tarball": {
    "filename": "cldr-territories-20langs.tar.gz",
    "size_bytes": ${TARBALL_SIZE},
    "sha256": "${TARBALL_SHA}"
  },
  "per_language": {
EOF
for lang in "${LANGS[@]}"; do
    if [ -f "$BUNDLE_DIR/xmls/${lang}.xml" ]; then
        SIZE=$(stat -c%s "$BUNDLE_DIR/xmls/${lang}.xml")
        SHA=$(sha256sum "$BUNDLE_DIR/xmls/${lang}.xml" | awk '{print $1}')
        LAST=$([ "$lang" = "${LANGS[-1]}" ] && echo "true" || echo "false")
        if [ "$LAST" = "true" ]; then
            cat >> "$MANIFEST" <<EOF
    "${lang}": {"size_bytes": ${SIZE}, "sha256": "${SHA}"}
  }
}
EOF
        else
            cat >> "$MANIFEST" <<EOF
    "${lang}": {"size_bytes": ${SIZE}, "sha256": "${SHA}"},
EOF
        fi
    fi
done
echo "  Created: $MANIFEST"

# Step 2: Upload to R2
echo
echo "Step 2: Upload to R2 ..."
python3 << PYEOF
import os
import boto3
from pathlib import Path

bucket = "${R2_BUCKET_RAW}"
key_prefix = f"raw/${SOURCE_KEY}/territories-${CLDR_VERSION}/${TODAY}"

s3 = boto3.client(
    "s3",
    endpoint_url=f"https://{os.environ['CF_ACCOUNT_ID']}.r2.cloudflarestorage.com",
    aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
    aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"],
)

bundle_dir = Path("${BUNDLE_DIR}")
files = ["cldr-territories-20langs.tar.gz", "manifest.json"]
langs = ["en", "es", "fr", "de", "zh", "ja", "ko", "ru", "ar", "hi", "pt", "it", "tr", "nl", "pl", "sv", "uk", "he", "fa", "th"]
files += [f"xmls/{l}.xml" for l in langs]

for fname in files:
    src = bundle_dir / fname
    if not src.exists():
        print(f"  SKIP: {fname} not found")
        continue
    key = f"{key_prefix}/{fname}"
    print(f"  Uploading {fname} ({src.stat().st_size:,} bytes) → r2://{bucket}/{key}")
    s3.upload_file(str(src), bucket, key)

print("  ✓ R2 upload complete")
PYEOF

# Step 3: Register source_releases row
echo
echo "Step 3: Register source_releases row ..."
NOW_MS=$(date -u +%s)000
RAW_KEY="raw/${SOURCE_KEY}/territories-${CLDR_VERSION}/${TODAY}/cldr-territories-20langs.tar.gz"
MANIFEST_KEY="raw/${SOURCE_KEY}/territories-${CLDR_VERSION}/${TODAY}/manifest.json"
ROW_COUNT=$(curl -s "https://api.cloudflare.com/client/v4/accounts/${CF_ACCOUNT_ID:-f0de6c4b68becd81e60507ecf9410199}/d1/database/ab54b1d7-6791-4d29-a94c-c95e6a560b7e/query" \
  -H "Authorization: Bearer ${CLOUDFLARE_API_TOKEN:-cfat_UyDDIlvZHHGSTdPKhvOLyCjlfWVMjLeielerTwDYe64c8626}" \
  -H "Content-Type: application/json" \
  --data "{\"sql\":\"SELECT COUNT(*) as n FROM country_names WHERE release_id = '${RELEASE_ID}'\"}" | python3 -c "import json, sys; r = json.load(sys.stdin); print(r['result'][0]['results'][0]['n'])")
echo "  country_names rows for this release: $ROW_COUNT"

# Insert or replace source_releases
npx wrangler d1 execute timeandtimepro-full-v2 --remote --command "INSERT OR REPLACE INTO source_releases
  (release_id, source_key, release_date, discovered_at, status,
   raw_sha256, raw_size_bytes, raw_r2_key, manifest_r2_key, row_count_accepted, started_at, finished_at)
VALUES
  ('${RELEASE_ID}', '${SOURCE_KEY}', '${TODAY}', ${NOW_MS}, 'raw-stored',
   '${TARBALL_SHA}', ${TARBALL_SIZE}, '${RAW_KEY}', '${MANIFEST_KEY}', ${ROW_COUNT}, ${NOW_MS}, ${NOW_MS});" 2>&1 | tail -3

echo
echo "=== Done ==="
echo "Release: $RELEASE_ID (raw-stored)"
echo "country_names rows: $ROW_COUNT (across 20 languages × 250 countries)"
echo "R2 location: r2://${R2_BUCKET_RAW}/raw/${SOURCE_KEY}/territories-${CLDR_VERSION}/${TODAY}/"
