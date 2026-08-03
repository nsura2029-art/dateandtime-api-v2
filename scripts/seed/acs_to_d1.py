#!/usr/bin/env python3
"""
scripts/seed/acs_to_d1.py

M11.5.1: Load US Census ACS 5-year estimates (B01001 Sex by Age) into D1.

Source: ACS 5-year 2022 Summary File
  https://www2.census.gov/programs-surveys/acs/summary_file/2022/table-based-SF/data/5YRData/acsdt5y2022-b01001.dat
  200 MB pipe-delimited file, ~32K place records
  Released December 2023, 5-year pooled ACS (2018-2022)

Schema (B01001):
  - 49 estimate variables + 49 margin-of-error variables
  - B01001_E001: Total population
  - B01001_E002: Male
  - B01001_E003-25: Male by age bucket (23 buckets)
  - B01001_E026: Female
  - B01001_E027-49: Female by age bucket (23 buckets)

GEO_ID format for places:
  1600000US[FIPS_STATE(2)][FIPS_PLACE(5)]
  e.g. 1600000US3651000 = state 36 (NY), place 51000 (NYC)

This loader:
  1. Downloads the .dat file (200MB)
  2. Greps for "160" records (places only)
  3. Parses each place, rolls up age groups
  4. Matches to our 14,459 US cities via fips_geoid
  5. Inserts into us_acs_attributes

Note: We're using the 2018-2022 ACS 5-year, the most recent available.
"""
import os
import sys
import json
import time
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")
RELEASE_ID = "acs5y-b01001-2022-2026-08-03"

URL = "https://www2.census.gov/programs-surveys/acs/summary_file/2022/table-based-SF/data/5YRData/acsdt5y2022-b01001.dat"


def http_query(sql: str, params: list = None) -> dict:
    body = {"sql": sql}
    if params:
        body["params"] = params
    payload = json.dumps(body).encode()
    req = urllib.request.Request(
        f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT}/d1/database/{DB_ID}/query",
        data=payload, method="POST",
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
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


def download_dat() -> Path:
    """Download the ACS B01001 .dat file."""
    tmp_dir = Path("tmp")
    tmp_dir.mkdir(exist_ok=True)
    dat_path = tmp_dir / "acs_b01001_2022.dat"
    if dat_path.exists() and dat_path.stat().st_size > 100_000_000:
        print(f"  Using cached {dat_path} ({dat_path.stat().st_size:,} bytes)")
        return dat_path
    print(f"  Downloading {URL} ...")
    req = urllib.request.Request(URL, method="GET")
    with urllib.request.urlopen(req, timeout=600) as r:
        data = r.read()
    with open(dat_path, "wb") as f:
        f.write(data)
    print(f"  Downloaded {len(data):,} bytes")
    return dat_path


def parse_place_record(line: str) -> dict:
    """Parse a single place record (1600000US...) into structured data.
    Returns None if line is malformed.
    """
    parts = line.split("|")
    if len(parts) < 99:  # GEO_ID + 49 estimates + 49 MOEs
        return None
    geo_id = parts[0]
    if not geo_id.startswith("1600000US"):
        return None
    fips_geoid = geo_id[9:]  # 7-digit FIPS (strip "1600000US" prefix = 9 chars)
    # Estimate columns are at indices 1, 3, 5, ... (every other starting at 1)
    # MOE columns are at indices 2, 4, 6, ... (every other starting at 2)
    def get_e(idx):
        v = parts[idx]
        if v in ("null", "-555555555", ""):
            return 0
        try:
            return int(v)
        except ValueError:
            return 0

    # B01001_E001 = total pop, _E002 = male, _E026 = female
    # Male age groups: E003-E025 (23 buckets)
    # Female age groups: E027-E049 (23 buckets)
    # Column formula: B01001_E{n} is at column 2*n-1 (0-indexed after GEO_ID)
    # E001 at col 1, E002 at col 3, E003 at col 5, ...
    # E025 at col 49, E026 at col 51, E027 at col 53, E049 at col 97
    total = get_e(1)
    male = get_e(3)
    female = get_e(51)
    male_ages = [get_e(2 * v - 1) for v in range(3, 26)]  # 23 buckets
    female_ages = [get_e(2 * v - 1) for v in range(27, 50)]  # 23 buckets

    # Roll up to major buckets
    # Male age buckets (0-indexed): 0=under5, 1=5-9, 2=10-14, 3=15-17, 4=18-19,
    # 5=20, 6=21, 7=22-24, 8=25-29, 9=30-34, 10=35-39, 11=40-44, 12=45-49, 13=50-54,
    # 14=55-59, 15=60-61, 16=62-64, 17=65-66, 18=67-69, 19=70-74, 20=75-79, 21=80-84, 22=85+
    # Same for female
    def rollup(ages):
        return {
            "under_5": ages[0],
            "age_5_to_17": sum(ages[1:4]),  # 5-9, 10-14, 15-17
            "age_18_to_24": sum(ages[4:8]),  # 18-19, 20, 21, 22-24
            "age_25_to_44": sum(ages[8:12]),  # 25-29, 30-34, 35-39, 40-44
            "age_45_to_64": sum(ages[12:17]),  # 45-49, 50-54, 55-59, 60-61, 62-64
            "age_65_plus": sum(ages[17:23]),  # 65-66, 67-69, 70-74, 75-79, 80-84, 85+
        }

    male_rollup = rollup(male_ages)
    female_rollup = rollup(female_ages)

    return {
        "fips_geoid": fips_geoid,
        "total_population": total,
        "male_population": male,
        "female_population": female,
        "under_5": male_rollup["under_5"] + female_rollup["under_5"],
        "age_5_to_17": male_rollup["age_5_to_17"] + female_rollup["age_5_to_17"],
        "age_18_to_24": male_rollup["age_18_to_24"] + female_rollup["age_18_to_24"],
        "age_25_to_44": male_rollup["age_25_to_44"] + female_rollup["age_25_to_44"],
        "age_45_to_64": male_rollup["age_45_to_64"] + female_rollup["age_45_to_64"],
        "age_65_plus": male_rollup["age_65_plus"] + female_rollup["age_65_plus"],
        "age_detail": json.dumps({
            "male": male_ages,
            "female": female_ages,
        }),
    }


def get_us_cities_by_fips() -> dict:
    """Fetch all our US cities with FIPS, keyed by 7-digit GEOID."""
    print("  Fetching our US cities with FIPS GEOID ...")
    res = http_query("""
      SELECT c.id, c.fips_geoid
      FROM cities c
      JOIN countries co ON co.id = c.country_id
      WHERE co.cca2 = 'US'
        AND c.fips_geoid IS NOT NULL
    """)
    if not res["ok"]:
        raise RuntimeError(f"US cities fetch failed: {res['error']}")
    by_fips = {row["fips_geoid"]: row["id"] for row in res["data"]}
    print(f"  {len(by_fips):,} US cities with FIPS GEOID")
    return by_fips


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Download ACS B01001 .dat ...")
    dat_path = download_dat()

    print("\nStep 2: Fetch our US cities with FIPS ...")
    our_cities_by_fips = get_us_cities_by_fips()

    print("\nStep 3: Parse place records from .dat ...")
    place_records = []
    n_total = 0
    with open(dat_path) as f:
        # Skip header
        next(f)
        for line in f:
            n_total += 1
            if not line.startswith("1600000US"):
                continue
            rec = parse_place_record(line.rstrip("\n"))
            if rec:
                place_records.append(rec)
    print(f"  Total records: {n_total:,}")
    print(f"  Place records: {len(place_records):,}")

    print("\nStep 4: Match places to our cities ...")
    updates_to_run = []
    matched = 0
    unmatched = 0
    for rec in place_records:
        fips = rec["fips_geoid"]
        our_id = our_cities_by_fips.get(fips)
        if our_id is None:
            unmatched += 1
            continue
        updates_to_run.append((rec, our_id))
        matched += 1
    print(f"  Matched: {matched:,} / {len(place_records):,}")
    print(f"  Unmatched: {unmatched:,}")

    if not updates_to_run:
        print("  Nothing to update")
        return

    print(f"\nStep 5: Insert {matched:,} records in parallel ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    success = 0
    start = time.time()
    last_log = start

    def insert_record(rec, our_id):
        sql = """
          INSERT INTO us_acs_attributes
          (city_id, fips_geoid, total_population, male_population, female_population,
           under_5, age_5_to_17, age_18_to_24, age_25_to_44, age_45_to_64, age_65_plus,
           age_detail, median_age, acs_year, release_id, fetched_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(city_id) DO UPDATE SET
            fips_geoid=excluded.fips_geoid,
            total_population=excluded.total_population,
            male_population=excluded.male_population,
            female_population=excluded.female_population,
            under_5=excluded.under_5,
            age_5_to_17=excluded.age_5_to_17,
            age_18_to_24=excluded.age_18_to_24,
            age_25_to_44=excluded.age_25_to_44,
            age_45_to_64=excluded.age_45_to_64,
            age_65_plus=excluded.age_65_plus,
            age_detail=excluded.age_detail,
            release_id=excluded.release_id,
            fetched_at=excluded.fetched_at
        """
        params = [
            our_id, rec["fips_geoid"], rec["total_population"],
            rec["male_population"], rec["female_population"],
            rec["under_5"], rec["age_5_to_17"], rec["age_18_to_24"],
            rec["age_25_to_44"], rec["age_45_to_64"], rec["age_65_plus"],
            rec["age_detail"],
            None,  # median_age — from B01002, not loaded here
            2022, RELEASE_ID, now_ms,
        ]
        res = http_query(sql, params)
        return res["ok"]

    with ThreadPoolExecutor(max_workers=16) as executor:
        futures = {executor.submit(insert_record, rec, cid): (rec, cid) for rec, cid in updates_to_run}
        for future in as_completed(futures):
            if future.result():
                success += 1
            now = time.time()
            if now - last_log > 3:
                elapsed = now - start
                rate = success / elapsed if elapsed > 0 else 0
                eta = (matched - success) / rate if rate > 0 else 0
                print(f"  {success:,}/{matched:,} ({rate:.0f}/s, ETA {eta:.0f}s)", flush=True)
                last_log = now

    elapsed = time.time() - start
    print(f"\n  Done. {success:,} cities updated in {elapsed:.1f}s")

    print(f"\nStep 6: Verify ...")
    res = http_query("""
      SELECT
        COUNT(*) as n,
        SUM(total_population) as total_pop,
        AVG(age_65_plus) as avg_senior_pop
      FROM us_acs_attributes
    """)
    if res["ok"]:
        r = res["data"][0]
        print(f"  Rows in us_acs_attributes: {r['n']:,}")
        print(f"  Total ACS population: {r['total_pop']:,}")


if __name__ == "__main__":
    main()
