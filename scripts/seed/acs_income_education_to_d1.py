#!/usr/bin/env python3
"""
scripts/seed/acs_income_education_to_d1.py

M11.5.1 expand: ACS 5-Year Income (B19013) + Education (B15003)

Loads two ACS tables into D1:
  - us_acs_income_attributes (median household income, 1 estimate column)
  - us_acs_education_attributes (educational attainment, 25 estimate columns rolled up to 7 buckets)

Both joined to our cities via fips_geoid (same as M11.5 US Census + M11.5.1 Sex by Age).

B15003 variable mapping (per Census Bureau):
  E001: Total 25+
  E002-E016: less than HS (no high school diploma)
  E017: regular HS diploma
  E018: GED or alternative credential
  E019-E020: some college, no degree
  E021: Associate's degree
  E022: Bachelor's degree
  E023: Master's degree
  E024: Professional degree
  E025: Doctorate degree

Sources:
  B19013: https://www2.census.gov/.../5YRData/acsdt5y2022-b19013.dat (18 MB)
  B15003: https://www2.census.gov/.../5YRData/acsdt5y2022-b15003.dat (92 MB)
"""
import os
import sys
import time
import json
import urllib.request
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

INCOME_FILE = "tmp/acsdt5y2022-b19013.dat"  # 18 MB
EDUCATION_FILE = "tmp/acsdt5y2022-b15003.dat"  # 92 MB

RELEASE_ID = "acs-5y-2022-b19013-b15003"
PLACE_PREFIX = "1600000US"  # state-place summary level 160


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
                "error": (inner.get("errors", [{}])[0].get("message", "") if not inner.get("success") else ""),
            }
    except Exception as e:
        return {"ok": False, "data": [], "error": str(e)}


def get_fips_set() -> set:
    """Get all FIPS place codes we have in cities (for filtering ACS data)."""
    print("  Loading FIPS code set from cities ...")
    res = http_query("SELECT DISTINCT fips_geoid FROM cities WHERE fips_geoid IS NOT NULL AND fips_geoid != ''")
    if not res["ok"]:
        raise RuntimeError(f"Failed to get FIPS: {res['error']}")
    fips_set = {r["fips_geoid"] for r in res["data"]}
    print(f"  Got {len(fips_set):,} FIPS place codes")
    return fips_set


def parse_income(path: str, fips_set: set) -> dict:
    """Parse B19013 (income) file. Returns {fips_geoid: median_income}."""
    print(f"  Parsing {path} ...")
    result = {}
    skipped = 0
    with open(path, "r", encoding="utf-8") as f:
        # Header: GEO_ID|B19013_E001|B19013_M001
        header = f.readline().strip().split("|")
        # E001 is at column index 1
        for line in f:
            cols = line.rstrip("\n").split("|")
            if len(cols) < 2:
                continue
            geo_id = cols[0]
            if not geo_id.startswith(PLACE_PREFIX):
                continue  # skip state, county, metro, etc.
            # Strip "1600000US" prefix (9 chars)
            fips = geo_id[len(PLACE_PREFIX):]
            if fips not in fips_set:
                skipped += 1
                continue
            try:
                median = int(cols[1]) if cols[1] and cols[1] != "null" and cols[1] != "-888888888" else None
            except ValueError:
                median = None
            if median is not None:
                result[fips] = median
    print(f"  Income: {len(result):,} matched, {skipped:,} skipped (not in our cities)")
    return result


def parse_education(path: str, fips_set: set) -> dict:
    """Parse B15003 (education) file.
    Returns {fips_geoid: {population_25_plus, less_than_hs, hs_or_ged, some_college, associate_degree, bachelor_degree, graduate_degree, bachelor_or_higher}}.
    """
    print(f"  Parsing {path} ...")
    result = {}
    skipped = 0
    with open(path, "r", encoding="utf-8") as f:
        # Header: GEO_ID | B15003_E001 | B15003_M001 | B15003_E002 | B15003_M002 | ... | B15003_E025 | B15003_M025
        # E001 is at col 1, E002 at col 3, E003 at col 5, ..., E025 at col 49
        # Pattern: E{n} at column 2n-1
        for line in f:
            cols = line.rstrip("\n").split("|")
            if len(cols) < 50:
                continue
            geo_id = cols[0]
            if not geo_id.startswith(PLACE_PREFIX):
                continue
            fips = geo_id[len(PLACE_PREFIX):]
            if fips not in fips_set:
                skipped += 1
                continue

            def col(n):
                """Get E{n} value, return None if null/empty/-888888888."""
                v = cols[2 * n - 1]
                if not v or v == "null" or v == "-888888888":
                    return None
                try:
                    return int(v)
                except ValueError:
                    return None

            e001 = col(1)  # total 25+
            if e001 is None:
                continue

            # B15003 variable mapping (per Census Bureau):
            # E001: Total 25+
            # E002-E016: less than HS (no high school diploma)
            # E017: regular HS diploma
            # E018: GED or alternative credential
            # E019-E020: some college, no degree
            # E021: Associate's degree
            # E022: Bachelor's degree
            # E023: Master's degree
            # E024: Professional degree
            # E025: Doctorate degree
            less_than_hs = sum(filter(None, [col(i) for i in range(2, 17)]))
            # E017-E018 = HS diploma or GED
            hs_or_ged = sum(filter(None, [col(17), col(18)]))
            # E019-E020 = some college, no degree
            some_college = sum(filter(None, [col(19), col(20)]))
            # E021 = associate's
            assoc = col(21)
            # E022 = bachelor's
            bachelor = col(22)
            # E023-E025 = graduate (master's, professional, doctorate)
            grad = sum(filter(None, [col(23), col(24), col(25)]))

            # Bachelor or higher = associate + bachelor + graduate (E021-E025)
            bachelor_or_higher = (assoc or 0) + (bachelor or 0) + grad

            result[fips] = {
                "population_25_plus": e001,
                "less_than_hs": less_than_hs,
                "hs_or_ged": hs_or_ged,
                "some_college": some_college,
                "associate_degree": assoc,
                "bachelor_degree": bachelor,
                "graduate_degree": grad,
                "bachelor_or_higher": bachelor_or_higher,
            }
    print(f"  Education: {len(result):,} matched, {skipped:,} skipped")
    return result


def upsert_income(records: dict, now_ms: int) -> int:
    """Upsert income records in chunks. Returns count of successful inserts."""
    if not records:
        return 0
    items = list(records.items())
    # 5 cols × 20 rows = 100 vars, at the limit. Use 18 to be safe.
    BATCH_ROWS = 18
    success = 0
    for i in range(0, len(items), BATCH_ROWS):
        chunk = items[i:i + BATCH_ROWS]
        placeholders = ",".join(["(?,?,?,?,?)"] * len(chunk))
        sql = f"""INSERT OR REPLACE INTO us_acs_income_attributes
      (fips_geoid, median_income, acs_year, release_id, fetched_at)
    VALUES {placeholders}"""
        params = []
        for fips, median in chunk:
            params.extend([fips, median, 2022, RELEASE_ID, now_ms])
        res = http_query(sql, params)
        if not res["ok"]:
            print(f"    Income chunk {i // BATCH_ROWS + 1} failed: {res['error'][:100]}")
            return success
        success += len(chunk)
    return success


def upsert_education(records: dict, now_ms: int) -> int:
    """Upsert education records in parallel chunks. Returns count of successful inserts."""
    if not records:
        return 0
    items = list(records.items())
    # 12 cols × 8 rows = 96 vars, safe
    BATCH_ROWS = 8
    chunks = []
    for i in range(0, len(items), BATCH_ROWS):
        chunk = items[i:i + BATCH_ROWS]
        placeholders = ",".join(["(?,?,?,?,?,?,?,?,?,?,?,?)"] * len(chunk))
        sql = f"""INSERT OR REPLACE INTO us_acs_education_attributes
      (fips_geoid, population_25_plus, less_than_hs, hs_or_ged, some_college, associate_degree, bachelor_degree, graduate_degree, bachelor_or_higher, acs_year, release_id, fetched_at)
    VALUES {placeholders}"""
        params = []
        for fips, d in chunk:
            params.extend([
                fips, d["population_25_plus"], d["less_than_hs"], d["hs_or_ged"],
                d["some_college"], d["associate_degree"], d["bachelor_degree"],
                d["graduate_degree"], d["bachelor_or_higher"], 2022, RELEASE_ID, now_ms,
            ])
        chunks.append((sql, params, len(chunk)))

    # Parallel execution with 4 workers
    from concurrent.futures import ThreadPoolExecutor
    success = 0
    total = len(chunks)
    completed = 0
    with ThreadPoolExecutor(max_workers=4) as executor:
        futures = {executor.submit(http_query, sql, params): size for sql, params, size in chunks}
        for future in as_completed(futures):
            size = futures[future]
            completed += 1
            try:
                res = future.result()
                if not res["ok"]:
                    print(f"    Education chunk {completed}/{total} failed: {res['error'][:100]}")
                else:
                    success += size
            except Exception as e:
                print(f"    Education chunk {completed}/{total} exception: {e}")
            if completed % 100 == 0:
                print(f"    {completed}/{total} chunks done ({success} rows)")
    return success


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Get FIPS place codes from cities ...")
    fips_set = get_fips_set()
    if not fips_set:
        print("  No FIPS codes found!")
        return

    print("\nStep 2: Parse ACS files ...")
    income = parse_income(INCOME_FILE, fips_set)
    education = parse_education(EDUCATION_FILE, fips_set)

    print(f"\nStep 3: Upload to D1 ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    n_income = upsert_income(income, now_ms)
    print(f"  Income: {n_income:,} rows inserted")
    n_education = upsert_education(education, now_ms)
    print(f"  Education: {n_education:,} rows inserted")

    print(f"\nStep 4: Verify ...")
    res = http_query("SELECT COUNT(*) as n FROM us_acs_income_attributes")
    if res["ok"]:
        print(f"  us_acs_income_attributes: {res['data'][0]['n']:,} rows")
    res = http_query("SELECT COUNT(*) as n FROM us_acs_education_attributes")
    if res["ok"]:
        print(f"  us_acs_education_attributes: {res['data'][0]['n']:,} rows")

    # Sample stats
    res = http_query("""
      SELECT
        COUNT(*) as n,
        ROUND(AVG(median_income), 0) as avg_income,
        MIN(median_income) as min_income,
        MAX(median_income) as max_income
      FROM us_acs_income_attributes
      WHERE median_income > 0
    """)
    if res["ok"]:
        row = res["data"][0]
        print(f"  Income stats: avg=${row['avg_income']:,.0f}, min=${row['min_income']:,.0f}, max=${row['max_income']:,.0f}")

    res = http_query("""
      SELECT
        COUNT(*) as n,
        ROUND(AVG(CAST(bachelor_or_higher AS REAL) * 100 / population_25_plus), 1) as pct_bach
      FROM us_acs_education_attributes
      WHERE population_25_plus > 0
    """)
    if res["ok"]:
        row = res["data"][0]
        print(f"  Education stats: avg {row['pct_bach']}% bachelor's or higher")


if __name__ == "__main__":
    main()
