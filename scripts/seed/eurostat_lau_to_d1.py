#!/usr/bin/env python3
"""
scripts/seed/eurostat_lau_to_d1.py

M11.6: Load Eurostat LAU (Local Administrative Units) into D1.

Source: LAU_RG_01M_2024_3035.csv (CSV, 5.6MB, 97,987 records)
  https://gisco-services.ec.europa.eu/distribution/v2/lau/csv/LAU_RG_01M_2024_3035.csv
  Released 2026-02-18, 30 country codes (EU-27 + EFTA + candidates)

Schema (CSV):
  GISCO_ID, CNTR_CODE, LAU_NAME, POP_2024, POP_DENS_2024, AREA_KM2, YEAR

What this loader does:
  1. Download the LAU file
  2. For each record, match to a city in our DB by (country_code, normalized_name)
  3. INSERT or UPDATE into eu_lau_attributes with:
     - gisco_id, lau_name, pop_2024, pop_density_2024, area_km2
  4. Update cities.gisco_id for matched cities
  5. Report match rate and unmatched examples

Coverage:
  - 30 country codes
  - 5 countries (AL, ES, FR, IS, RS) have 0-pop for all LAU — privacy laws
  - Other 25 countries have ~95-100% pop coverage
  - Our DB has 17,055 US + ~70K EU cities = ~80K EU candidates
  - LAU has 97,987 records — including many small towns our DB may not have

Match algorithm (O(N+M) for fast):
  - For each EU country in our DB, build {normalized_name.lower: city_id}
  - For each LAU record, look up by (country_code, normalized_name)
  - Special handling: skip suffix (e.g. ", Stadt", ", Stadt")
"""
import os
import sys
import csv
import json
import time
import urllib.request
import re
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

URL = "https://gisco-services.ec.europa.eu/distribution/v2/lau/csv/LAU_RG_01M_2024_3035.csv"
RELEASE_ID = f"eurostat-lau-2024-2026-08-03"

# EU country codes in LAU file
LAU_COUNTRIES = {
    "AL", "AT", "BE", "BG", "CH", "CY", "CZ", "DE", "DK", "EE",
    "EL", "ES", "FI", "FR", "HR", "HU", "IE", "IS", "IT", "LI",
    "LT", "LU", "LV", "MK", "MT", "NL", "NO", "PL", "PT", "RO",
    "RS", "SE", "SI", "SK"
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


def normalize_name(name: str) -> str:
    """Normalize a LAU name for matching (strip common suffixes)."""
    n = name.strip()
    # Remove common LAU suffixes (German, French, etc.)
    for suffix in [
        ", Stadt", " Stadt",  # German: "Berlin, Stadt"
        ", Stadtteil", " Stadtteil",
        ", commune", " commune",
        ", Gemeinde", " Gemeinde",
        ", Gemeinde in", " Gemeinde in",
        ", Ortsgemeinde", " Ortsgemeinde",
        " (CZ)", " (DE)", " (AT)",  # country disambiguators
    ]:
        if n.endswith(suffix):
            n = n[: -len(suffix)]
            break
    # Remove diacritics for matching (DE, AT, CH use umlauts, etc.)
    n = n.replace("ä", "ae").replace("ö", "oe").replace("ü", "ue")
    n = n.replace("Ä", "Ae").replace("Ö", "Oe").replace("Ü", "Ue")
    n = n.replace("ß", "ss")
    n = n.replace("ø", "o").replace("Ø", "O")
    return n.strip()


def download_lau() -> Path:
    print(f"  Downloading {URL} ...")
    req = urllib.request.Request(URL, method="GET")
    with urllib.request.urlopen(req, timeout=60) as r:
        data = r.read()
    print(f"  Downloaded {len(data):,} bytes")
    tmp_dir = Path("tmp")
    tmp_dir.mkdir(exist_ok=True)
    csv_path = tmp_dir / "lau_2024.csv"
    with open(csv_path, "wb") as f:
        f.write(data)
    print(f"  Saved to {csv_path}")
    return csv_path


def get_eu_cities_by_country() -> dict:
    """Fetch all our EU cities grouped by cca2 for fast matching.
    Returns: {cca2: {normalized_name_lower: city_id}}
    """
    print("  Fetching our EU cities by country ...")
    # EU countries are in our "Europe" region
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
        if cca2 not in LAU_COUNTRIES:
            continue
        if cca2 not in by_country:
            by_country[cca2] = {}
        norm = normalize_name(row["name"]).lower()
        by_country[cca2][norm] = row["id"]
    total = sum(len(v) for v in by_country.values())
    print(f"  {total:,} EU cities in {len(by_country)} LAU-tracked countries")
    return by_country


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Download LAU 2024 file ...")
    csv_path = download_lau()

    print("\nStep 2: Fetch our EU cities ...")
    our_cities_by_country = get_eu_cities_by_country()

    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)

    print(f"\nStep 3: Match LAU → our cities (by country + name) ...")
    matched = 0
    unmatched_samples = []

    def update_city(city_id: int, gisco_id: str, country_code: str, lau_name: str,
                    pop_2024: int, pop_density_2024: float, area_km2: float) -> bool:
        # Update cities with gisco_id
        sql1 = "UPDATE cities SET gisco_id = ? WHERE id = ?"
        res1 = http_query(sql1, [gisco_id, city_id])
        if not res1["ok"]:
            return False
        # Upsert into eu_lau_attributes
        sql2 = """
          INSERT INTO eu_lau_attributes
          (city_id, gisco_id, country_code, lau_name, pop_2024, pop_density_2024,
           area_km2, year, release_id, fetched_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, 2024, ?, ?)
          ON CONFLICT(city_id) DO UPDATE SET
            gisco_id=excluded.gisco_id,
            country_code=excluded.country_code,
            lau_name=excluded.lau_name,
            pop_2024=excluded.pop_2024,
            pop_density_2024=excluded.pop_density_2024,
            area_km2=excluded.area_km2,
            year=excluded.year,
            release_id=excluded.release_id,
            fetched_at=excluded.fetched_at
        """
        params2 = [
            city_id, gisco_id, country_code, lau_name,
            pop_2024, pop_density_2024, area_km2,
            RELEASE_ID, now_ms,
        ]
        res2 = http_query(sql2, params2)
        return res2["ok"]

    updates_to_run = []
    with open(csv_path, "r", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            gisco_id = row.get("GISCO_ID", "").strip()
            country_code = row.get("CNTR_CODE", "").strip()
            lau_name = row.get("LAU_NAME", "").strip()
            try:
                pop_2024 = int(row.get("POP_2024", "0") or 0)
            except ValueError:
                pop_2024 = 0
            try:
                pop_density_2024 = float(row.get("POP_DENS_2024", "0") or 0)
            except ValueError:
                pop_density_2024 = 0
            try:
                area_km2 = float(row.get("AREA_KM2", "0") or 0)
            except ValueError:
                area_km2 = 0

            if not gisco_id or not country_code or not lau_name:
                continue
            if country_code not in LAU_COUNTRIES:
                continue

            # O(1) dict lookup
            normalized = normalize_name(lau_name).lower()
            our_country_cities = our_cities_by_country.get(country_code, {})
            matched_id = our_country_cities.get(normalized)

            if matched_id is None:
                if len(unmatched_samples) < 10:
                    unmatched_samples.append(f"{country_code} {lau_name} (norm: {normalized})")
                continue

            updates_to_run.append((
                matched_id, gisco_id, country_code, lau_name,
                pop_2024, pop_density_2024, area_km2,
            ))

    print(f"  Matched {len(updates_to_run):,} LAU → our cities")
    print(f"  Unmatched (first 10): {unmatched_samples}")

    print(f"\nStep 4: Run {len(updates_to_run):,} city updates in parallel ...")
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

    print(f"\nStep 5: Verify ...")
    res = http_query("""
      SELECT
        COUNT(*) as n,
        SUM(CASE WHEN pop_2024 > 0 THEN 1 ELSE 0 END) as n_with_pop,
        MIN(pop_2024) as min_pop,
        MAX(pop_2024) as max_pop,
        SUM(pop_2024) as total_pop
      FROM eu_lau_attributes
    """)
    if res["ok"]:
        r = res["data"][0]
        print(f"  Rows in eu_lau_attributes: {r['n']:,}")
        print(f"  With pop_2024 > 0: {r['n_with_pop']:,}")
        print(f"  Min/Max/Total pop: {r['min_pop']} / {r['max_pop']} / {r['total_pop'] or 0:,}")


if __name__ == "__main__":
    main()
