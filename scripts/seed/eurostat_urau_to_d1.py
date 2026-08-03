#!/usr/bin/env python3
"""
scripts/seed/eurostat_urau_to_d1.py

M11.6: Load Eurostat URAU (Urban Audit) City vs FUA data into D1.

Source: URAU_AT_2024.csv (despite the name, this is actually PAN-EU)
  https://gisco-services.ec.europa.eu/distribution/v2/urau/csv/URAU_AT_2024.csv
  63.5 KB, 1,332 records (Cities + FUAs for all EU countries)

Schema (CSV):
  URAU_CODE, URAU_CATG, CNTR_CODE, URAU_NAME, CITY_CPTL, FUA_CODE, AREA_SQM, NUTS3_2024

URAU_CATG values:
  C = City (the inner administrative city)
  F = Functional Urban Area (FUA) — the wider metro area

A City belongs to one FUA (via FUA_CODE). The FUA has a wider area and
includes the city plus surrounding suburbs/communes.

What this loader does:
  1. Download the URAU file
  2. For each City record (C), match to a city in our DB
  3. INSERT into eu_urau_attributes with:
     - urau_code, urau_name, fua_code, fua_name, area_sqm, nuts3_code
  4. For each FUA record (F), look up the FUA name from the same file
  5. Update cities.gisco_id where applicable

This is a "proof of concept" — the URAU dataset is small (1,332 records) but
provides a real City-vs-FUA distinction for ~739 EU cities.

The "City vs FUA" answer:
  - City: the administrative municipality (e.g. "Paris" is the city of Paris)
  - FUA:  the functional urban area — Paris + suburbs like Boulogne-Billancourt
  - For most users searching for "Paris", they want the city, not the metro
"""
import os
import sys
import csv
import json
import time
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

URL = "https://gisco-services.ec.europa.eu/distribution/v2/urau/csv/URAU_AT_2024.csv"
RELEASE_ID = f"eurostat-urau-2024-2026-08-03"


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


def normalize_name(name: str) -> str:
    n = name.strip()
    n = n.replace("ä", "ae").replace("ö", "oe").replace("ü", "ue")
    n = n.replace("Ä", "Ae").replace("Ö", "Oe").replace("Ü", "Ue")
    n = n.replace("ß", "ss")
    n = n.replace("ø", "o").replace("Ø", "O")
    return n.strip()


def download_urau() -> Path:
    print(f"  Downloading {URL} ...")
    req = urllib.request.Request(URL, method="GET")
    with urllib.request.urlopen(req, timeout=60) as r:
        data = r.read()
    print(f"  Downloaded {len(data):,} bytes")
    tmp_dir = Path("tmp")
    tmp_dir.mkdir(exist_ok=True)
    csv_path = tmp_dir / "urau_2024.csv"
    with open(csv_path, "wb") as f:
        f.write(data)
    print(f"  Saved to {csv_path}")
    return csv_path


def get_eu_cities_by_country() -> dict:
    """Fetch all our EU cities grouped by cca2 for fast matching."""
    print("  Fetching our EU cities by country ...")
    res = http_query("""
      SELECT c.id, c.name, co.cca2
      FROM cities c
      JOIN countries co ON co.id = c.country_id
      WHERE co.region_id IN (
        SELECT id FROM regions WHERE name LIKE '%Europe%'
      )
    """)
    if not res["ok"]:
        raise RuntimeError(f"EU cities fetch failed: {res['error']}")
    by_country = {}
    for row in res["data"]:
        cca2 = row["cca2"]
        if cca2 not in by_country:
            by_country[cca2] = {}
        norm = normalize_name(row["name"]).lower()
        by_country[cca2][norm] = row["id"]
    total = sum(len(v) for v in by_country.values())
    print(f"  {total:,} EU cities")
    return by_country


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Download URAU 2024 file ...")
    csv_path = download_urau()

    print("\nStep 2: Parse URAU file (build FUA lookup + city list) ...")
    fua_lookup = {}  # {fua_code: fua_name}
    raw_cities = []  # list of city records to process
    raw_fuas = []  # list of FUA records (for documentation)
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            urau_code = row.get("URAU_CODE", "").strip()
            urau_catg = row.get("URAU_CATG", "").strip()
            country = row.get("CNTR_CODE", "").strip()
            name = row.get("URAU_NAME", "").strip()
            fua_code = row.get("FUA_CODE", "").strip()
            nuts3 = row.get("NUTS3_2024", "").strip()
            try:
                area_sqm = float(row.get("AREA_SQM", "0") or 0)
            except ValueError:
                area_sqm = 0

            if urau_catg == "F":
                raw_fuas.append({
                    "urau_code": urau_code,
                    "name": name,
                    "country": country,
                    "area_sqm": area_sqm,
                    "nuts3": nuts3,
                })
            elif urau_catg == "C":
                raw_cities.append({
                    "urau_code": urau_code,
                    "country": country,
                    "name": name,
                    "fua_code": fua_code,
                    "area_sqm": area_sqm,
                    "nuts3": nuts3,
                })

    # IMPORTANT: build FUA lookup AFTER all FUA records are read
    # The CSV file orders FUA records AFTER their city records in some cases
    for fua in raw_fuas:
        fua_lookup[fua["urau_code"]] = fua["name"]

    # Now build the cities list with FUA names resolved
    cities = []
    for city in raw_cities:
        cities.append({
            **city,
            "fua_name": fua_lookup.get(city["fua_code"], ""),
        })

    print(f"  FUAs: {len(fua_lookup):,}")
    print(f"  Cities: {len(cities):,} (with FUA name: {sum(1 for c in cities if c['fua_name']):,})")

    print("\nStep 3: Fetch our EU cities ...")
    our_cities_by_country = get_eu_cities_by_country()

    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)

    print(f"\nStep 4: Match URAU Cities → our cities ...")
    matched = 0
    unmatched_samples = []

    def update_city(city_id: int, urau_code: str, urau_name: str,
                    fua_code: str, fua_name: str, area_sqm: float, nuts3: str) -> bool:
        # Update cities with gisco_id (URAU code is a GISCO-style ID, e.g. "AT002C")
        # The gisco_id column uses "_" separator (e.g. "AT_002C") so transform
        urau_as_gisco = f"{urau_code[:2]}_{urau_code[2:]}" if len(urau_code) >= 4 else urau_code
        sql1 = "UPDATE cities SET gisco_id = ? WHERE id = ?"
        res1 = http_query(sql1, [urau_as_gisco, city_id])
        if not res1["ok"]:
            return False
        # Upsert into eu_urau_attributes
        sql2 = """
          INSERT INTO eu_urau_attributes
          (city_id, urau_code, urau_name, fua_code, fua_name, area_sqm, nuts3_code,
           release_id, fetched_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(city_id) DO UPDATE SET
            urau_code=excluded.urau_code,
            urau_name=excluded.urau_name,
            fua_code=excluded.fua_code,
            fua_name=excluded.fua_name,
            area_sqm=excluded.area_sqm,
            nuts3_code=excluded.nuts3_code,
            release_id=excluded.release_id,
            fetched_at=excluded.fetched_at
        """
        params = [
            city_id, urau_code, urau_name, fua_code, fua_name,
            area_sqm, nuts3, RELEASE_ID, now_ms,
        ]
        res2 = http_query(sql2, params)
        return res2["ok"]

    updates_to_run = []
    for city in cities:
        normalized = normalize_name(city["name"]).lower()
        our_country_cities = our_cities_by_country.get(city["country"], {})
        matched_id = our_country_cities.get(normalized)
        if matched_id is None:
            if len(unmatched_samples) < 10:
                unmatched_samples.append(f"{city['country']} {city['name']} (norm: {normalized})")
            continue
        updates_to_run.append((
            matched_id, city["urau_code"], city["name"],
            city["fua_code"], city["fua_name"],
            city["area_sqm"], city["nuts3"],
        ))

    print(f"  Matched {len(updates_to_run):,} URAU cities → our cities")
    print(f"  Unmatched (first 10): {unmatched_samples}")

    print(f"\nStep 5: Run {len(updates_to_run):,} city updates in parallel ...")
    success = 0
    start = time.time()
    last_log = start
    with ThreadPoolExecutor(max_workers=16) as executor:
        futures = {executor.submit(update_city, *u): u for u in updates_to_run}
        for future in as_completed(futures):
            if future.result():
                success += 1
            now = time.time()
            if now - last_log > 2:
                elapsed = now - start
                rate = success / elapsed if elapsed > 0 else 0
                eta = (len(updates_to_run) - success) / rate if rate > 0 else 0
                print(f"  {success:,}/{len(updates_to_run):,} ({rate:.0f}/s, ETA {eta:.0f}s)", flush=True)
                last_log = now

    elapsed = time.time() - start
    print(f"\n  Done. {success:,} cities updated in {elapsed:.1f}s")

    print(f"\nStep 6: Verify ...")
    res = http_query("""
      SELECT
        COUNT(*) as n,
        COUNT(DISTINCT fua_code) as n_fuas,
        SUM(CASE WHEN fua_name != '' THEN 1 ELSE 0 END) as n_with_fua_name
      FROM eu_urau_attributes
    """)
    if res["ok"]:
        r = res["data"][0]
        print(f"  Rows in eu_urau_attributes: {r['n']:,}")
        print(f"  Distinct FUAs: {r['n_fuas']:,}")
        print(f"  With FUA name: {r['n_with_fua_name']:,}")


if __name__ == "__main__":
    main()
