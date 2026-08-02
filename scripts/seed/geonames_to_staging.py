#!/usr/bin/env python3
"""
scripts/seed/geonames_to_staging.py

Parse the verified GeoNames cities5000.txt and load into D1 cities_staging table.
This is the staging step — the cities_staging → cities_live swap is a separate
two-phase commit operation that we run only after validation passes.

GeoNames columns (tab-separated):
  0  geonameid
  1  name
  2  asciiname
  3  alternatenames
  4  latitude
  5  longitude
  6  feature_class
  7  feature_code
  8  country_code
  9  cc2
  10 admin1_code
  11 admin2_code
  12 admin3_code
  13 admin4_code
  14 population
  15 elevation
  16 dem
  17 timezone
  18 modified_date
"""
import json
import os
import sqlite3
import sys
import time
from pathlib import Path

LOCAL_TXT = Path("/tmp/geonames/cities5000.txt")
LOCAL_MANIFEST = Path("/tmp/geonames/manifest.json")
WORKSPACE = Path("/workspace/dateandtime-api-v2")
LOCAL_DB = WORKSPACE / "tmp" / "cities_staging.db"

# D1 batch limits (from memory): 12 cols → BATCH_SIZE=8 (96 vars)
COLS = 14  # cities_staging has 14 cols (incl. staging_id, loaded_at)
BATCH_SIZE = 6  # 14*6=84 vars, well under 100 limit

SOURCE_KEY = "geonames"
DATASET = "cities5000"
RELEASE_DATE = time.strftime("%Y-%m-%d")
RELEASE_ID = f"{SOURCE_KEY}-{DATASET}-{RELEASE_DATE}"


def main():
    if not LOCAL_TXT.exists():
        print("ERROR: /tmp/geonames/cities5000.txt not found. Run geonames_cities5000.py download+verify first.")
        sys.exit(1)

    # Load manifest to get sha256 etc
    if LOCAL_MANIFEST.exists():
        manifest = json.loads(LOCAL_MANIFEST.read_text())
        sha = manifest["raw_sha256"]
    else:
        sha = "unknown"

    LOCAL_DB.parent.mkdir(parents=True, exist_ok=True)
    if LOCAL_DB.exists():
        LOCAL_DB.unlink()
    conn = sqlite3.connect(str(LOCAL_DB))
    cur = conn.cursor()

    # Create the same schema as D1 cities_staging
    cur.execute("""
        CREATE TABLE cities_staging (
            staging_id INTEGER PRIMARY KEY AUTOINCREMENT,
            release_id TEXT NOT NULL,
            external_id TEXT NOT NULL,
            name TEXT NOT NULL,
            ascii_name TEXT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            country_code TEXT,
            admin1_code TEXT,
            admin2_code TEXT,
            feature_class TEXT,
            feature_code TEXT,
            population INTEGER,
            elevation INTEGER,
            dem INTEGER,
            timezone TEXT,
            modified_date TEXT,
            loaded_at INTEGER NOT NULL,
            UNIQUE(release_id, external_id)
        )
    """)

    print(f"Reading {LOCAL_TXT} ...")
    rows = []
    total = 0
    skipped = 0
    with open(LOCAL_TXT, encoding="utf-8") as f:
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 19:
                skipped += 1
                continue
            try:
                lat = float(parts[4])
                lon = float(parts[5])
            except (ValueError, IndexError):
                skipped += 1
                continue
            # Strip alternatenames (col 3) — not in our staging schema
            # We'll only keep geonameid, name, asciiname, lat, lon, country, admin1, admin2, fclass, fcode, pop, elev, dem, tz, mod_date
            rows.append((
                RELEASE_ID,
                parts[0],  # geonameid
                parts[1],  # name
                parts[2],  # asciiname
                lat,
                lon,
                parts[8] or None,  # country_code
                parts[10] or None,  # admin1_code
                parts[11] or None,  # admin2_code
                parts[6] or None,  # feature_class
                parts[7] or None,  # feature_code
                int(parts[14]) if parts[14] else None,  # population
                int(parts[15]) if parts[15] else None,  # elevation
                int(parts[16]) if parts[16] else None,  # dem
                parts[17] or None,  # timezone
                parts[18] or None,  # modified_date
                int(time.time() * 1000),
            ))
            total += 1

    print(f"Parsed {total:,} rows, skipped {skipped:,}")

    # Insert in batches
    placeholders = ",".join(["?"] * 17)
    insert_sql = f"INSERT OR REPLACE INTO cities_staging ({','.join(['release_id','external_id','name','ascii_name','latitude','longitude','country_code','admin1_code','admin2_code','feature_class','feature_code','population','elevation','dem','timezone','modified_date','loaded_at'])}) VALUES ({placeholders})"

    inserted = 0
    for i in range(0, len(rows), BATCH_SIZE):
        batch = rows[i:i + BATCH_SIZE]
        cur.executemany(insert_sql, batch)
        inserted += len(batch)
        if (i // BATCH_SIZE) % 50 == 0:
            print(f"  inserted {inserted:,}/{len(rows):,}")

    conn.commit()
    print(f"Total inserted: {inserted:,}")

    # Validate
    cur.execute("SELECT COUNT(*) FROM cities_staging")
    n = cur.fetchone()[0]
    cur.execute("SELECT COUNT(DISTINCT country_code) FROM cities_staging")
    n_countries = cur.fetchone()[0]
    cur.execute("SELECT COUNT(DISTINCT timezone) FROM cities_staging WHERE timezone IS NOT NULL")
    n_tz = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM cities_staging WHERE timezone IS NULL")
    n_null_tz = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM cities_staging WHERE population IS NULL")
    n_null_pop = cur.fetchone()[0]
    cur.execute("SELECT COUNT(*) FROM cities_staging WHERE population = 0")
    n_zero_pop = cur.fetchone()[0]

    print()
    print("=== Staging summary ===")
    print(f"Total rows:        {n:,}")
    print(f"Countries:         {n_countries}")
    print(f"Timezones:         {n_tz}")
    print(f"NULL timezone:     {n_null_tz}")
    print(f"NULL population:   {n_null_pop}")
    print(f"Zero population:   {n_zero_pop}")
    print()
    print(f"Local DB:          {LOCAL_DB}")
    print(f"Size:              {LOCAL_DB.stat().st_size:,} bytes")
    print()
    print("Next step: wrangler d1 execute to load cities_staging into D1,")
    print("          then run two-phase commit: cities_staging → cities_live.")
    print()
    # Write a small JSON summary for the upload script
    summary = {
        "release_id": RELEASE_ID,
        "release_date": RELEASE_DATE,
        "raw_sha256": sha,
        "row_count": n,
        "country_count": n_countries,
        "timezone_count": n_tz,
        "null_timezone": n_null_tz,
        "null_population": n_null_pop,
        "zero_population": n_zero_pop,
    }
    Path("/tmp/geonames/staging_summary.json").write_text(json.dumps(summary, indent=2))
    print(f"Summary: /tmp/geonames/staging_summary.json")

    conn.close()


if __name__ == "__main__":
    main()
