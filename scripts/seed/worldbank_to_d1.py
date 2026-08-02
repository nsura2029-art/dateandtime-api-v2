#!/usr/bin/env python3
"""
scripts/seed/worldbank_to_d1.py

M11.4: Load World Bank SP.POP.TOTL (country population) into D1.

Source: World Bank Indicators API
  https://api.worldbank.org/v2/country/all/indicator/SP.POP.TOTL?format=json&date=2024

Pivoted from UN WPP 2024 (originally planned) to World Bank because:
  - UN WPP CSV download URLs returned 404 at fetch time
  - World Bank has the same data category (country population)
  - World Bank JSON API is simpler (no big CSV to download/parse)
  - World Bank is already in source_registry (world_bank / sp-pop-totl)
  - World Bank is updated annually (lastupdated: 2026-07-13)

Schema (migration 146):
  country_populations (country_id, year, population, source, release_id, fetched_at)

How it works:
  1. Fetch the World Bank API for SP.POP.TOTL year=2024
  2. Filter to real countries only (countryiso3code is in our 250-country set)
     - Skip aggregates like AFE (Africa Eastern), EUU (European Union)
  3. Match by ISO 3166-1 alpha-3 (cca3) to our countries.id
  4. INSERT OR REPLACE into country_populations
  5. Save raw JSON to tmp/worldbank_pop_2024.json for R2 archival

Notes:
  - World Bank has 217 entities; we have 250 countries. Some mismatch
    (e.g. WB has separate entries for Taiwan we don't, we have some
    territories WB doesn't)
  - Year: 2024 (most recent, lastupdated: 2026-07-13)
  - Insert via D1 HTTP API (5 binds per row, 16 parallel workers)
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

API_URL = "https://api.worldbank.org/v2/country/all/indicator/SP.POP.TOTL?format=json&date=2024&per_page=400"
YEAR = 2024
SOURCE = "world_bank"
RELEASE_ID = f"worldbank-pop-{YEAR}-2026-08-02"


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


def get_our_cca3_set() -> set:
    """Fetch our 250 countries' cca3 codes for filtering."""
    res = http_query("SELECT cca3 FROM countries")
    if not res["ok"]:
        raise RuntimeError(f"countries fetch failed: {res['error']}")
    return {row["cca3"] for row in res["data"]}


def get_cca3_to_id() -> dict:
    """Return {cca3: country_id} mapping from D1."""
    res = http_query("SELECT id, cca3 FROM countries")
    if not res["ok"]:
        raise RuntimeError(f"countries fetch failed: {res['error']}")
    return {row["cca3"]: row["id"] for row in res["data"]}


def fetch_worldbank() -> list:
    """Fetch SP.POP.TOTL year=2024 from World Bank API."""
    print(f"  Fetching {API_URL} ...")
    req = urllib.request.Request(API_URL, method="GET")
    with urllib.request.urlopen(req, timeout=60) as r:
        resp = json.loads(r.read().decode())
    # resp is [metadata, [entries...]]
    if not isinstance(resp, list) or len(resp) < 2:
        raise RuntimeError("Unexpected World Bank response")
    return resp[1]


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Get our 250 countries (cca3 → country_id) ...")
    cca3_to_id = get_cca3_to_id()
    our_cca3 = set(cca3_to_id.keys())
    print(f"  {len(our_cca3)} countries in our DB")

    print("\nStep 2: Fetch World Bank SP.POP.TOTL year=2024 ...")
    wb_data = fetch_worldbank()
    print(f"  {len(wb_data)} entries from World Bank")

    # Save raw to tmp
    tmp_dir = Path("tmp")
    tmp_dir.mkdir(exist_ok=True)
    raw_path = tmp_dir / "worldbank_pop_2024.json"
    with open(raw_path, "w") as f:
        json.dump(wb_data, f, indent=2)
    print(f"  Saved raw to {raw_path}")

    # Filter: keep only entries where countryiso3code is in our cca3 set
    # AND value is not null
    rows = []
    skipped_no_match = 0
    skipped_null = 0
    for entry in wb_data:
        iso3 = entry.get("countryiso3code", "")
        value = entry.get("value")
        country_name = entry.get("country", {}).get("value", "")
        if iso3 not in our_cca3:
            skipped_no_match += 1
            continue
        if value is None:
            skipped_null += 1
            continue
        country_id = cca3_to_id[iso3]
        rows.append({
            "country_id": country_id,
            "iso3": iso3,
            "country_name": country_name,
            "year": YEAR,
            "population": int(value),
        })
    print(f"  After filter: {len(rows)} matched our countries")
    print(f"  Skipped: {skipped_no_match} not in our cca3, {skipped_null} NULL value")

    if not rows:
        print("ERROR: no rows to insert")
        sys.exit(1)

    print(f"\nStep 3: Insert {len(rows)} rows into country_populations ...")
    print(f"  release_id={RELEASE_ID}, source={SOURCE}, year={YEAR}")

    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)

    def apply_row(row: dict) -> int:
        sql = """INSERT OR REPLACE INTO country_populations
                 (country_id, year, population, source, release_id, fetched_at)
                 VALUES (?, ?, ?, ?, ?, ?)"""
        params = [row["country_id"], row["year"], row["population"], SOURCE, RELEASE_ID, now_ms]
        res = http_query(sql, params)
        if res["ok"]:
            return res.get("meta", {}).get("changes", 0)
        return 0

    success = 0
    total_changes = 0
    start = time.time()
    last_log = start

    with ThreadPoolExecutor(max_workers=16) as executor:
        futures = {executor.submit(apply_row, row): row for row in rows}
        for future in as_completed(futures):
            changes = future.result()
            success += 1
            total_changes += changes
            now = time.time()
            if now - last_log > 2:
                elapsed = now - start
                rate = success / elapsed if elapsed > 0 else 0
                eta = (len(rows) - success) / rate if rate > 0 else 0
                print(f"  {success:,}/{len(rows):,} ({rate:.0f} rows/s, ETA {eta:.0f}s, {total_changes:,} inserted)", flush=True)
                last_log = now

    elapsed = time.time() - start
    print(f"\nDone. {success:,} rows in {elapsed:.1f}s")
    print(f"  Total inserted: {total_changes:,}")

    print(f"\nStep 4: Verify with D1 ...")
    res = http_query("SELECT COUNT(*) as n FROM country_populations WHERE release_id = ?", [RELEASE_ID])
    if res["ok"]:
        print(f"  country_populations rows for {RELEASE_ID}: {res['data'][0]['n']:,}")

    # Show some sample rows
    res = http_query("""SELECT cp.year, cp.population, c.cca2, c.name
                        FROM country_populations cp
                        JOIN countries c ON c.id = cp.country_id
                        WHERE cp.release_id = ? AND cp.population > 100000000
                        ORDER BY cp.population DESC LIMIT 5""", [RELEASE_ID])
    if res["ok"]:
        print(f"\n  Top 5 most populous (from World Bank {YEAR}):")
        for r in res["data"]:
            print(f"    {r['cca2']} {r['name']:30} {r['population']:>15,}")


if __name__ == "__main__":
    main()
