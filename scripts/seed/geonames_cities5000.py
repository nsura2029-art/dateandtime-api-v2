#!/usr/bin/env python3
"""
scripts/seed/geonames_cities5000.py

Download GeoNames cities5000.zip, verify SHA-256, upload to R2, register release.
This is the first concrete data source ingestion for the data platform.

GeoNames cities5000 has ~200K cities with population >= 5000, alternate names,
country/state, lat/lon, IANA timezone. License: CC-BY-4.0 (attribution required).

Usage:
  python3 scripts/seed/geonames_cities5000.py download
  python3 scripts/seed/geonames_cities5000.py verify
  python3 scripts/seed/geonames_cities5000.py upload   # requires R2 credentials
  python3 scripts/seed/geonames_cities5000.py register # creates source_releases row

The four steps are intentionally separate so each can be retried
independently and the manifest in R2 is auditable.
"""
import argparse
import hashlib
import json
import os
import sys
import urllib.request
import zipfile
from datetime import datetime, timezone
from pathlib import Path

SOURCE_KEY = "geonames"
DATASET = "cities5000"
DOWNLOAD_URL = "https://download.geonames.org/export/dump/cities5000.zip"
LOCAL_DIR = Path("/tmp/geonames")
WORKSPACE = Path("/workspace/dateandtime-api-v2")
R2_BUCKET_RAW = "dt-data-raw"


def download() -> Path:
    """Download cities5000.zip to /tmp/geonames/"""
    LOCAL_DIR.mkdir(parents=True, exist_ok=True)
    out_path = LOCAL_DIR / "cities5000.zip"
    if out_path.exists():
        print(f"Already downloaded: {out_path} ({out_path.stat().st_size:,} bytes)")
        return out_path

    print(f"Downloading {DOWNLOAD_URL} ...")
    urllib.request.urlretrieve(DOWNLOAD_URL, out_path)
    size = out_path.stat().st_size
    print(f"Downloaded: {out_path} ({size:,} bytes)")
    return out_path


def verify() -> dict:
    """Compute SHA-256 and unzip to count rows."""
    zip_path = LOCAL_DIR / "cities5000.zip"
    if not zip_path.exists():
        print("ERROR: zip not found, run 'download' first")
        sys.exit(1)

    print("Computing SHA-256 ...")
    sha = hashlib.sha256()
    with open(zip_path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            sha.update(chunk)
    sha256 = sha.hexdigest()
    print(f"SHA-256: {sha256}")

    print("Unzipping ...")
    with zipfile.ZipFile(zip_path) as z:
        z.extractall(LOCAL_DIR)
    txt_path = LOCAL_DIR / "cities5000.txt"
    line_count = sum(1 for _ in open(txt_path, encoding="utf-8"))
    print(f"Rows in cities5000.txt: {line_count:,}")

    # GeoNames columns: geonameid, name, asciiname, alternatenames, latitude,
    # longitude, feature_class, feature_code, country_code, cc2, admin1_code,
    # admin2_code, admin3_code, admin4_code, population, elevation, dem, timezone, modified_date
    return {
        "sha256": sha256,
        "size_bytes": zip_path.stat().st_size,
        "row_count": line_count,
        "txt_path": str(txt_path),
    }


def upload() -> dict:
    """
    Upload the raw zip and a manifest to R2.

    Requires the following env vars:
      CF_ACCOUNT_ID
      R2_ACCESS_KEY_ID
      R2_SECRET_ACCESS_KEY

    Uses boto3 (S3-compatible API).
    """
    try:
        import boto3
    except ImportError:
        print("ERROR: boto3 not installed. pip install boto3")
        sys.exit(1)

    zip_path = LOCAL_DIR / "cities5000.zip"
    sha = hashlib.sha256(open(zip_path, "rb").read()).hexdigest()
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    key = f"raw/{SOURCE_KEY}/{DATASET}/{today}/cities5000.zip"
    manifest_key = f"raw/{SOURCE_KEY}/{DATASET}/{today}/manifest.json"

    s3 = boto3.client(
        "s3",
        endpoint_url=f"https://{os.environ['CF_ACCOUNT_ID']}.r2.cloudflarestorage.com",
        aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"],
    )

    print(f"Uploading to r2://{R2_BUCKET_RAW}/{key} ...")
    s3.upload_file(str(zip_path), R2_BUCKET_RAW, key)

    manifest = {
        "source_key": SOURCE_KEY,
        "dataset": DATASET,
        "release_date": today,
        "raw_sha256": sha,
        "raw_size_bytes": zip_path.stat().st_size,
        "raw_r2_key": key,
        "downloaded_at": datetime.now(timezone.utc).isoformat(),
        "license": "CC-BY-4.0",
        "publisher": "GeoNames",
        "publisher_url": "https://www.geonames.org/",
        "download_url": DOWNLOAD_URL,
    }
    print(f"Uploading manifest to r2://{R2_BUCKET_RAW}/{manifest_key} ...")
    s3.put_object(
        Bucket=R2_BUCKET_RAW,
        Key=manifest_key,
        Body=json.dumps(manifest, indent=2).encode(),
        ContentType="application/json",
    )

    print(f"Manifest written. SHA-256: {sha}")
    return manifest


def register() -> None:
    """
    Register the release in D1 source_releases table.

    Run via wrangler d1 execute with a SQL file we generate here.
    """
    import subprocess
    zip_path = LOCAL_DIR / "cities5000.zip"
    if not zip_path.exists():
        print("ERROR: zip not found, run 'download' first")
        sys.exit(1)

    sha = hashlib.sha256(open(zip_path, "rb").read()).hexdigest()
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    release_id = f"{SOURCE_KEY}-{DATASET}-{today}"
    raw_key = f"raw/{SOURCE_KEY}/{DATASET}/{today}/cities5000.zip"
    manifest_key = f"raw/{SOURCE_KEY}/{DATASET}/{today}/manifest.json"
    size = zip_path.stat().st_size

    sql = f"""INSERT OR REPLACE INTO source_releases
  (release_id, source_key, release_date, discovered_at, status,
   raw_sha256, raw_size_bytes, raw_r2_key, manifest_r2_key, started_at)
VALUES
  ('{release_id}', '{SOURCE_KEY}', '{today}',
   {int(datetime.now(timezone.utc).timestamp() * 1000)}, 'raw-stored',
   '{sha}', {size}, '{raw_key}', '{manifest_key}',
   {int(datetime.now(timezone.utc).timestamp() * 1000)});
"""
    sql_path = WORKSPACE / "tmp" / "register_geonames_release.sql"
    sql_path.parent.mkdir(parents=True, exist_ok=True)
    sql_path.write_text(sql)

    print(f"Release: {release_id}")
    print(f"SHA-256: {sha}")
    print(f"Size: {size:,} bytes")
    print(f"SQL written to: {sql_path}")
    print()
    print("Run: npx wrangler d1 execute timeandtimepro-full-v2 --env dev --remote --file " + str(sql_path))


def main() -> int:
    parser = argparse.ArgumentParser(description="GeoNames cities5000 ingestion")
    parser.add_argument("step", choices=["download", "verify", "upload", "register"],
                        help="Pipeline step to run")
    args = parser.parse_args()

    if args.step == "download":
        download()
    elif args.step == "verify":
        meta = verify()
        print(json.dumps(meta, indent=2))
    elif args.step == "upload":
        manifest = upload()
        print(json.dumps(manifest, indent=2))
    elif args.step == "register":
        register()

    return 0


if __name__ == "__main__":
    sys.exit(main())
