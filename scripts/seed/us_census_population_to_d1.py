#!/usr/bin/env python3
"""
scripts/seed/us_census_population_to_d1.py

M11.5: Load US Census Bureau Population Estimates Program (PEP) into D1.

Source: sub-est2025.csv (CSV, 81,354 rows, 7.1MB)
  https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv
  Released 2026-05-14

Schema (CSV):
  SUMLEV, STATE, COUNTY, PLACE, COUSUB, CONCIT, PRIMGEO_FLAG, FUNCSTAT,
  NAME, STNAME, ESTIMATESBASE2020, POPESTIMATE2020..POPESTIMATE2025

What this loader does:
  1. Download sub-est2025.csv
  2. Filter to SUMLEV=162 (incorporated places — 19,483 records)
  3. For each record, match to a city in our DB by (fips_state, fips_place)
     — these were populated by us_gazetteer_to_d1.py
  4. INSERT OR REPLACE into us_census_attributes with:
     - Population time series (pop_2020..pop_2025)
     - FIPS codes, LSAD, funcstat
  5. Apply separately for the Gazetteer columns (land_area, internal_point, etc.)
     — actually we update those on cities directly in us_gazetteer_to_d1.py

Two passes:
  Pass A: Gazetteer provides FIPS + LSAD + area + internal point
          → updates cities table directly
  Pass B: SUB-EST provides population time series
          → populates us_census_attributes, joined on cities.fips_geoid

Why we don't overwrite cities.population:
  - dr5hn is curated and we want to preserve it
  - We expose Census data via the API's new "census" block
  - Future M11.x could do an intelligent merge (Census for US, dr5hn elsewhere)
"""
import os
import sys
import csv
import json
import time
import urllib.request
import io
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

URL = "https://www2.census.gov/programs-surveys/popest/datasets/2020-2025/cities/totals/sub-est2025.csv"
RELEASE_ID = f"us-census-sub-est-2025-2026-08-02"
GAZ_RELEASE_ID = f"us-census-gazetteer-2024-2026-08-02"

# LSAD code → human-readable legal class
LSAD_MAP = {
    "25": "city",
    "43": "town",
    "47": "village",
    "57": "CDP",
    "62": "borough",
    "53": "municipality",
}


def http_query(sql: str, params: list = None) -> dict:
    url = f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT}/d1/database/{DB_ID}/query"
    body = {"sql": sql}
    if params:
        body["params"] = params
    payload = json.dumps(body).encode()
    req = urllib.request.Request(
        url, data=payload, method="POST",
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            resp = json.loads(r.read().decode())
            inner = (resp.get("result") or [{}])[0]
            return {
                "ok": resp.get("success") and inner.get("success", False),
                "data": inner.get("results", []),
                "meta": inner.get("meta", {}),
                "error": (inner.get("errors", [{}])[0].get("message", "") if not inner.get("success") else ""),
            }
    except Exception as e:
        return {"ok": False, "data": [], "meta": {}, "error": str(e)}


def get_fips_to_city_id() -> dict:
    """Get {fips_geoid: city_id} for all US cities (those with FIPS codes assigned)."""
    print("  Fetching our US cities with FIPS geoid ...")
    res = http_query("""
      SELECT c.id, c.fips_geoid
      FROM cities c
      WHERE c.country_id = (SELECT id FROM countries WHERE cca2 = 'US')
        AND c.fips_geoid IS NOT NULL
    """)
    if not res["ok"]:
        raise RuntimeError(f"US cities FIPS fetch failed: {res['error']}")
    mapping = {row["fips_geoid"]: row["id"] for row in res["data"]}
    print(f"  {len(mapping):,} US cities with FIPS geoid")
    return mapping


def download_sub_est() -> Path:
    print(f"  Downloading {URL} ...")
    req = urllib.request.Request(URL, method="GET")
    with urllib.request.urlopen(req, timeout=60) as r:
        data = r.read()
    print(f"  Downloaded {len(data):,} bytes")
    tmp_dir = Path("tmp")
    tmp_dir.mkdir(exist_ok=True)
    csv_path = tmp_dir / "sub-est2025.csv"
    with open(csv_path, "wb") as f:
        f.write(data)
    print(f"  Saved to {csv_path}")
    return csv_path


def parse_and_insert(csv_path: Path, fips_to_id: dict) -> int:
    """Parse SUB-EST and INSERT OR REPLACE into us_census_attributes."""
    print(f"  Parsing + inserting {csv_path} ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)

    def insert_row(city_id: int, row: dict) -> bool:
        fips_state = row["STATE"].zfill(2)
        fips_place = row["PLACE"].zfill(5)
        fips_geoid = fips_state + fips_place
        # Use ON CONFLICT(city_id) DO UPDATE so we don't clobber the
        # Gazetteer fields (legal_class, land_area_sqmi, etc.) set by
        # us_gazetteer_to_d1.py. INSERT OR REPLACE would wipe them.
        sql = """
          INSERT INTO us_census_attributes
          (city_id, fips_state, fips_place, fips_geoid,
           pop_2020, pop_2021, pop_2022, pop_2023, pop_2024, pop_2025,
           estimates_base_2020, release_id, fetched_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(city_id) DO UPDATE SET
            fips_state=excluded.fips_state,
            fips_place=excluded.fips_place,
            fips_geoid=excluded.fips_geoid,
            pop_2020=excluded.pop_2020,
            pop_2021=excluded.pop_2021,
            pop_2022=excluded.pop_2022,
            pop_2023=excluded.pop_2023,
            pop_2024=excluded.pop_2024,
            pop_2025=excluded.pop_2025,
            estimates_base_2020=excluded.estimates_base_2020,
            release_id=excluded.release_id,
            fetched_at=excluded.fetched_at
        """
        # Handle empty values as NULL
        def parse_int(v):
            v = v.strip()
            if not v:
                return None
            try:
                return int(v)
            except ValueError:
                return None

        params = [
            city_id,
            fips_state,
            fips_place,
            fips_geoid,
            parse_int(row.get("POPESTIMATE2020", "")),
            parse_int(row.get("POPESTIMATE2021", "")),
            parse_int(row.get("POPESTIMATE2022", "")),
            parse_int(row.get("POPESTIMATE2023", "")),
            parse_int(row.get("POPESTIMATE2024", "")),
            parse_int(row.get("POPESTIMATE2025", "")),
            parse_int(row.get("ESTIMATESBASE2020", "")),
            RELEASE_ID,
            now_ms,
        ]
        res = http_query(sql, params)
        return res["ok"]

    # First pass: build list of (city_id, row) tuples
    updates = []
    matched = 0
    unmatched = 0
    with open(csv_path, "r", encoding="latin-1", errors="replace") as f:
        reader = csv.DictReader(f)
        for row in reader:
            if row.get("SUMLEV") != "162":
                continue  # Only incorporated places
            fips_state = row.get("STATE", "").zfill(2)
            fips_place = row.get("PLACE", "").zfill(5)
            fips_geoid = fips_state + fips_place
            city_id = fips_to_id.get(fips_geoid)
            if city_id is None:
                unmatched += 1
                continue
            updates.append((city_id, row))
            matched += 1

    print(f"  Matched: {matched:,} / {matched + unmatched:,} incorporated places")
    print(f"  Unmatched: {unmatched:,} (Census places not in our cities)")

    # Second pass: insert in parallel
    success = 0
    start = time.time()
    last_log = start
    with ThreadPoolExecutor(max_workers=16) as executor:
        futures = {executor.submit(insert_row, *u): u for u in updates}
        for future in as_completed(futures):
            if future.result():
                success += 1
            now = time.time()
            if now - last_log > 2:
                elapsed = now - start
                rate = success / elapsed if elapsed > 0 else 0
                eta = (len(updates) - success) / rate if rate > 0 else 0
                print(f"  {success:,}/{len(updates):,} ({rate:.0f}/s, ETA {eta:.0f}s)", flush=True)
                last_log = now

    elapsed = time.time() - start
    print(f"\n  Done. {success:,} census attributes inserted in {elapsed:.1f}s")
    return success


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Get FIPS → city_id mapping ...")
    fips_to_id = get_fips_to_city_id()
    if not fips_to_id:
        print("ERROR: no US cities have FIPS geoid. Run us_gazetteer_to_d1.py first.")
        sys.exit(1)

    print("\nStep 2: Download SUB-EST2025 ...")
    csv_path = download_sub_est()

    print("\nStep 3: Parse + insert into us_census_attributes ...")
    success = parse_and_insert(csv_path, fips_to_id)

    print(f"\nStep 4: Verify ...")
    res = http_query("""
      SELECT
        (SELECT COUNT(*) FROM us_census_attributes WHERE release_id = ?) as n,
        (SELECT COUNT(*) FROM us_census_attributes WHERE pop_2025 IS NOT NULL) as n_with_pop,
        (SELECT MIN(pop_2025) FROM us_census_attributes WHERE pop_2025 IS NOT NULL) as min_pop,
        (SELECT MAX(pop_2025) FROM us_census_attributes WHERE pop_2025 IS NOT NULL) as max_pop,
        (SELECT SUM(pop_2025) FROM us_census_attributes WHERE pop_2025 IS NOT NULL) as total_pop
    """, [RELEASE_ID])
    if res["ok"]:
        r = res["data"][0]
        print(f"  Rows in us_census_attributes for {RELEASE_ID}: {r['n']:,}")
        print(f"  Rows with pop_2025: {r['n_with_pop']:,}")
        print(f"  Min pop: {r['min_pop']}")
        print(f"  Max pop: {r['max_pop']}")
        print(f"  Total pop (sum): {r['total_pop']:,}")


if __name__ == "__main__":
    main()
