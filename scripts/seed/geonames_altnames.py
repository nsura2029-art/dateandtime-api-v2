#!/usr/bin/env python3
"""
scripts/seed/geonames_altnames.py

Download GeoNames alternateNamesV2.zip, filter to cities5000 geonameids,
upload to R2, load into D1 alt_names_staging.

This is the M11.1.5 work — load GeoNames alt names so the historical_alias
tier of intelligent_merge.py can catch city renames on the GeoNames side
(Bombay→Mumbai, Edo→Tokyo, Peking→Beijing, Constantinople→Istanbul).

Why filter to cities5000 geonameids?
  The full alternateNamesV2 is 40M+ rows, 6GB uncompressed. Most of it is
  for countries, admin regions, and sub-5K cities we don't care about.
  By filtering to the 69,561 geonameids we have in cities_staging, we
  reduce to ~1.5M rows (~300MB uncompressed) — 25x smaller, much faster
  to load, and the only data we need for the layer merge.

Usage:
  python3 scripts/seed/geonames_altnames.py download
  python3 scripts/seed/geonames_altnames.py filter  # extract city alt names only
  python3 scripts/seed/geonames_altnames.py upload  # R2 upload
  python3 scripts/seed/geonames_altnames.py load    # D1 alt_names_staging
  python3 scripts/seed/geonames_altnames.py register # source_releases row

License: CC-BY-4.0 (attribution required)
"""
import argparse
import csv
import hashlib
import json
import os
import subprocess
import sys
import urllib.request
import zipfile
from datetime import datetime, timezone
from pathlib import Path

SOURCE_KEY = "geonames"
DATASET = "alternateNamesV2"
DOWNLOAD_URL = "https://download.geonames.org/export/dump/alternateNamesV2.zip"
LOCAL_DIR = Path("/tmp/geonames")
WORKSPACE = Path("/workspace/dateandtime-api-v2")
R2_BUCKET_RAW = "dt-data-raw"


def download() -> Path:
    """Download alternateNamesV2.zip to /tmp/geonames/"""
    LOCAL_DIR.mkdir(parents=True, exist_ok=True)
    out_path = LOCAL_DIR / "alternateNamesV2.zip"
    if out_path.exists():
        print(f"Already downloaded: {out_path} ({out_path.stat().st_size:,} bytes)")
        return out_path

    print(f"Downloading {DOWNLOAD_URL} ...")
    print("(This file is ~300MB compressed — may take a few minutes)")
    urllib.request.urlretrieve(DOWNLOAD_URL, out_path)
    size = out_path.stat().st_size
    print(f"Downloaded: {out_path} ({size:,} bytes)")
    return out_path


def verify() -> dict:
    """Compute SHA-256 and count rows in the unzipped file."""
    zip_path = LOCAL_DIR / "alternateNamesV2.zip"
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
    txt_path = LOCAL_DIR / "alternateNamesV2.txt"
    line_count = sum(1 for _ in open(txt_path, encoding="utf-8"))
    print(f"Rows in alternateNamesV2.txt: {line_count:,}")

    return {
        "sha256": sha256,
        "size_bytes": zip_path.stat().st_size,
        "row_count": line_count,
        "txt_path": str(txt_path),
    }


def filter_to_cities() -> dict:
    """
    Filter alternateNamesV2.txt to only the geonameids that appear in our
    cities_staging table. This is the key step — instead of loading 40M rows
    we only load ~1.5M (the alt names for our 69K cities).

    Output: alternateNamesV2_cities5000.txt — only rows we care about
    """
    src = LOCAL_DIR / "alternateNamesV2.txt"
    if not src.exists():
        print("ERROR: alternateNamesV2.txt not found, run 'verify' first")
        sys.exit(1)

    # Read the cities_staging geonameids from D1
    print("Reading cities_staging geonameids from D1 ...")
    result = subprocess.run(
        [
            "npx", "wrangler", "d1", "execute", "timeandtimepro-full-v2",
            "--env", "dev", "--remote", "--json",
            "--command", "SELECT DISTINCT external_id FROM cities_staging",
        ],
        cwd=str(WORKSPACE),
        capture_output=True,
        text=True,
        timeout=120,
    )
    if result.returncode != 0:
        print(f"ERROR reading cities_staging: {result.stderr[:500]}")
        sys.exit(1)
    out = json.loads(result.stdout)
    geonameids = set()
    for row in out[0]["results"]:
        # external_id is the GeoNames id as TEXT
        try:
            geonameids.add(int(row["external_id"]))
        except (ValueError, TypeError):
            pass
    print(f"Loaded {len(geonameids):,} geonameids from cities_staging")

    # Filter alternateNamesV2 to those geonameids
    print(f"Filtering alternateNamesV2.txt to those geonameids ...")
    out_path = LOCAL_DIR / "alternateNamesV2_cities5000.txt"
    kept = 0
    skipped = 0
    with open(src, encoding="utf-8") as fin, open(out_path, "w", encoding="utf-8") as fout:
        for line in fin:
            # GeoNames alternateNamesV2 columns (0-indexed):
            #   0: alternateNameId
            #   1: geonameid
            #   2: isolanguage (or 'post', 'iata', 'icao', 'faac', 'link', 'wkdt', 'abbr')
            #   3: alternate name
            #   4: isPreferredName ('1' or '')
            #   5: isShortName
            #   6: isColloquial
            #   7: isHistoric
            #   8: from period (may be missing)
            #   9: to period (may be missing)
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 8:
                skipped += 1
                continue
            try:
                gid = int(parts[1])
            except (ValueError, IndexError):
                skipped += 1
                continue
            if gid in geonameids:
                fout.write(line)
                kept += 1
            else:
                skipped += 1
    print(f"Kept: {kept:,} rows")
    print(f"Skipped: {skipped:,} rows (not in cities_staging)")
    print(f"Output: {out_path} ({out_path.stat().st_size:,} bytes)")

    return {
        "input_path": str(src),
        "output_path": str(out_path),
        "input_rows": kept + skipped,
        "kept_rows": kept,
        "skipped_rows": skipped,
        "geonameids_matched": len(geonameids),
    }


def upload() -> dict:
    """
    Upload the filtered alt names to R2.
    """
    try:
        import boto3
    except ImportError:
        print("ERROR: boto3 not installed. pip install boto3")
        sys.exit(1)

    src = LOCAL_DIR / "alternateNamesV2_cities5000.txt"
    if not src.exists():
        print("ERROR: filtered file not found, run 'filter' first")
        sys.exit(1)

    sha = hashlib.sha256(open(src, "rb").read()).hexdigest()
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    key = f"raw/{SOURCE_KEY}/{DATASET}/{today}/alternateNamesV2_cities5000.txt"
    manifest_key = f"raw/{SOURCE_KEY}/{DATASET}/{today}/manifest.json"

    s3 = boto3.client(
        "s3",
        endpoint_url=f"https://{os.environ['CF_ACCOUNT_ID']}.r2.cloudflarestorage.com",
        aws_access_key_id=os.environ["R2_ACCESS_KEY_ID"],
        aws_secret_access_key=os.environ["R2_SECRET_ACCESS_KEY"],
    )

    print(f"Uploading to r2://{R2_BUCKET_RAW}/{key} ...")
    s3.upload_file(str(src), R2_BUCKET_RAW, key)

    manifest = {
        "source_key": SOURCE_KEY,
        "dataset": DATASET,
        "release_date": today,
        "filter": "cities5000 geonameids only",
        "raw_sha256": sha,
        "raw_size_bytes": src.stat().st_size,
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


def load() -> dict:
    """
    Load the filtered alt names into D1 alt_names_staging.
    Uses wrangler to execute SQL in batches (D1 has a ~100 var/statement limit).

    Columns: alternateNameId, geonameid, isolanguage, alternate_name,
             is_preferred, is_short, is_colloquial, is_historic
    """
    src = LOCAL_DIR / "alternateNamesV2_cities5000.txt"
    if not src.exists():
        print("ERROR: filtered file not found, run 'filter' first")
        sys.exit(1)

    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    release_id = f"{SOURCE_KEY}-altnames-{today}"

    print(f"Loading {src} into alt_names_staging as release_id={release_id}")
    print("(BATCH_SIZE=99 due to D1 100-var limit with 9 columns)")

    BATCH = 99  # 9 cols × 99 rows = ~99 vars/statement (under D1 100 limit)
    TIMEOUT_S = 120
    tmp_dir = WORKSPACE / "tmp" / "altnames_batches"
    tmp_dir.mkdir(parents=True, exist_ok=True)

    # Read and batch
    rows = []
    with open(src, encoding="utf-8") as f:
        for line in f:
            # See filter() for column layout
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 8:
                continue
            try:
                int(parts[0])  # alternateNameId
                int(parts[1])  # geonameid
            except ValueError:
                continue
            # Only need first 8 columns: alt_id, gid, lang, name, pref, short, col, hist
            rows.append(parts[:8])

    print(f"Total rows: {len(rows):,}")

    # Write batches as SQL
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    batches = []
    for i in range(0, len(rows), BATCH):
        chunk = rows[i:i + BATCH]
        values_list = []
        for p in chunk:
            alt_id, gid, lang, name, pref, short, col, hist = p
            # Escape single quotes
            name_esc = name.replace("'", "''")
            lang_esc = lang.replace("'", "''") if lang else ""
            values_list.append(
                f"({alt_id},'{release_id}',{gid},'{lang_esc}','{name_esc}',{pref or 0},{short or 0},{col or 0},{hist or 0},{now_ms})"
            )
        sql = f"INSERT OR REPLACE INTO alt_names_staging (alternateNameId, release_id, geonameid, isolanguage, alternate_name, is_preferred, is_short, is_colloquial, is_historic, loaded_at) VALUES\n  "
        sql += ",\n  ".join(values_list) + ";\n"
        batch_path = tmp_dir / f"batch_{i:06d}.sql"
        batch_path.write_text(sql)
        batches.append(batch_path)

    print(f"Wrote {len(batches):,} batches")

    # Run each batch
    success = 0
    failed = 0
    for i, batch in enumerate(batches):
        try:
            result = subprocess.run(
                [
                    "npx", "wrangler", "d1", "execute", "timeandtimepro-full-v2",
                    "--env", "dev", "--remote", "--file", str(batch),
                ],
                cwd=str(WORKSPACE),
                capture_output=True,
                text=True,
                timeout=TIMEOUT_S,
            )
            if result.returncode == 0:
                success += 1
            else:
                failed += 1
                if failed <= 3:
                    print(f"  FAILED batch {i}: {result.stderr[:200]}")
        except subprocess.TimeoutExpired:
            failed += 1
            print(f"  TIMEOUT batch {i}")
        if (i + 1) % 50 == 0:
            print(f"  Progress: {i+1}/{len(batches)} batches ({success} ok, {failed} failed)")

    print(f"Done. {success}/{len(batches)} batches succeeded, {failed} failed")

    # Cleanup
    for b in batches:
        b.unlink()
    tmp_dir.rmdir()

    return {
        "release_id": release_id,
        "total_rows": len(rows),
        "batches_attempted": len(batches),
        "batches_succeeded": success,
        "batches_failed": failed,
    }


def register() -> None:
    """
    Register the release in D1 source_releases table.
    """
    src = LOCAL_DIR / "alternateNamesV2_cities5000.txt"
    if not src.exists():
        print("ERROR: filtered file not found, run 'filter' first")
        sys.exit(1)

    sha = hashlib.sha256(open(src, "rb").read()).hexdigest()
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    release_id = f"{SOURCE_KEY}-altnames-{today}"
    raw_key = f"raw/{SOURCE_KEY}/{DATASET}/{today}/alternateNamesV2_cities5000.txt"
    manifest_key = f"raw/{SOURCE_KEY}/{DATASET}/{today}/manifest.json"
    size = src.stat().st_size

    sql = f"""INSERT OR REPLACE INTO source_releases
  (release_id, source_key, release_date, discovered_at, status,
   raw_sha256, raw_size_bytes, raw_r2_key, manifest_r2_key, started_at)
VALUES
  ('{release_id}', '{SOURCE_KEY}', '{today}',
   {int(datetime.now(timezone.utc).timestamp() * 1000)}, 'raw-stored',
   '{sha}', {size}, '{raw_key}', '{manifest_key}',
   {int(datetime.now(timezone.utc).timestamp() * 1000)});
"""
    sql_path = WORKSPACE / "tmp" / "register_geonames_altnames.sql"
    sql_path.parent.mkdir(parents=True, exist_ok=True)
    sql_path.write_text(sql)

    print(f"Release: {release_id}")
    print(f"SHA-256: {sha}")
    print(f"Size: {size:,} bytes")
    print(f"SQL written to: {sql_path}")
    print()
    print("Run: npx wrangler d1 execute timeandtimepro-full-v2 --env dev --remote --file " + str(sql_path))


def main() -> int:
    parser = argparse.ArgumentParser(description="GeoNames altNames ingestion")
    parser.add_argument(
        "step",
        choices=["download", "verify", "filter", "upload", "load", "register"],
        help="Pipeline step to run",
    )
    args = parser.parse_args()

    if args.step == "download":
        download()
    elif args.step == "verify":
        meta = verify()
        print(json.dumps(meta, indent=2))
    elif args.step == "filter":
        meta = filter_to_cities()
        print(json.dumps(meta, indent=2))
    elif args.step == "upload":
        manifest = upload()
        print(json.dumps(manifest, indent=2))
    elif args.step == "load":
        meta = load()
        print(json.dumps(meta, indent=2))
    elif args.step == "register":
        register()

    return 0


if __name__ == "__main__":
    sys.exit(main())
