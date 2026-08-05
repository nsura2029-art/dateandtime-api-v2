#!/usr/bin/env python3
"""
scripts/seed/us_gazetteer_to_d1.py

M11.5: Load US Census Bureau Gazetteer file (2024) into D1.

Source: 2024_Gaz_place_national.txt (pipe-delimited, 32,334 place records)
  https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2024_Gazetteer/2024_Gaz_place_national.zip

Schema (pipe-delimited):
  USPS GEOID ANSICODE NAME LSAD FUNCSTAT ALAND AWATER ALAND_SQMI AWATER_SQMI INTPTLAT INTPTLONG

What this loader does:
  1. Download the 2024_Gaz_place_national.zip from census.gov
  2. Unzip the inner text file
  3. Parse pipe-delimited records
  4. For each record:
     - Match to a city in our DB by (state_code USPS, name) — handles "city" / "town" suffixes
     - Update cities.fips_state_code, fips_place_code, fips_geoid
  5. Report match rate and unmatched examples

Why this is needed:
  - We need FIPS codes to join with SUB-EST population data
  - LSAD gives us the legal class (city/town/village/CDP/borough)
  - Land/water area + internal point comes "for free"

The result feeds the SUB-EST loader: it uses cities.fips_geoid to join.
"""
import os
import sys
import csv
import json
import time
import urllib.request
import zipfile
import io
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

URL = "https://www2.census.gov/geo/docs/maps-data/data/gazetteer/2024_Gazetteer/2024_Gaz_place_national.zip"
RELEASE_ID = f"us-census-gazetteer-2024-2026-08-02"

# LSAD code → human-readable legal class
LSAD_MAP = {
    "25": "city",
    "43": "town",
    "47": "village",
    "57": "CDP",  # Census Designated Place
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


def download_gazetteer() -> Path:
    print(f"  Downloading {URL} ...")
    req = urllib.request.Request(URL, method="GET")
    with urllib.request.urlopen(req, timeout=60) as r:
        data = r.read()
    print(f"  Downloaded {len(data):,} bytes")
    # Save to tmp
    tmp_dir = Path("tmp")
    tmp_dir.mkdir(exist_ok=True)
    zip_path = tmp_dir / "gaz_2024.zip"
    with open(zip_path, "wb") as f:
        f.write(data)
    print(f"  Saved to {zip_path}")
    return zip_path


def parse_gazetteer(zip_path: Path) -> list:
    """Parse the gazetteer text file inside the zip (tab-delimited)."""
    print(f"  Extracting + parsing {zip_path} ...")
    rows = []
    with zipfile.ZipFile(zip_path) as z:
        for name in z.namelist():
            if name.endswith(".txt"):
                with z.open(name) as f:
                    text = io.TextIOWrapper(f, encoding="utf-8")
                    reader = csv.DictReader(text, delimiter="\t")
                    for row in reader:
                        # Strip whitespace from keys and values (Census file has
                        # wide fields with trailing whitespace for visual alignment)
                        cleaned = {k.strip(): v.strip() for k, v in row.items() if k}
                        rows.append(cleaned)
    print(f"  Parsed {len(rows):,} gazetteer records")
    return rows


def get_us_state_mapping() -> dict:
    """Map USPS state code (e.g. 'CA') → FIPS state code (e.g. '06')."""
    # Standard FIPS 5-2 state code mapping (50 states + DC + PR)
    mapping = {
        "AL": "01", "AK": "02", "AZ": "04", "AR": "05", "CA": "06",
        "CO": "08", "CT": "09", "DE": "10", "DC": "11", "FL": "12",
        "GA": "13", "HI": "15", "ID": "16", "IL": "17", "IN": "18",
        "IA": "19", "KS": "20", "KY": "21", "LA": "22", "ME": "23",
        "MD": "24", "MA": "25", "MI": "26", "MN": "27", "MS": "28",
        "MO": "29", "MT": "30", "NE": "31", "NV": "32", "NH": "33",
        "NJ": "34", "NM": "35", "NY": "36", "NC": "37", "ND": "38",
        "OH": "39", "OK": "40", "OR": "41", "PA": "42", "RI": "44",
        "SC": "45", "SD": "46", "TN": "47", "TX": "48", "UT": "49",
        "VT": "50", "VA": "51", "WA": "53", "WV": "54", "WI": "55",
        "WY": "56", "AS": "60", "GU": "66", "MP": "69", "PR": "72",
        "VI": "78", "UM": "74",  # Minor outlying islands
    }
    return mapping


def get_us_cities_by_state() -> dict:
    """Fetch all our US cities grouped by state for fast matching.
    Returns: {usps_state: {normalized_name_lower: city_id}} for O(1) lookup.
    """
    print("  Fetching our US cities by state ...")
    res = http_query("""
      SELECT c.id, c.name, c.state_code
      FROM cities c
      WHERE c.country_id = (SELECT id FROM countries WHERE cca2 = 'US')
    """)
    if not res["ok"]:
        raise RuntimeError(f"US cities fetch failed: {res['error']}")
    by_state = {}
    for row in res["data"]:
        st = row["state_code"]
        if st not in by_state:
            by_state[st] = {}
        norm = normalize_name(row["name"]).lower()
        by_state[st][norm] = row["id"]
    return by_state


def normalize_name(name: str) -> str:
    """Normalize a gazetteer name for matching (strip LSAD suffix)."""
    n = name.strip()
    # Remove common LSAD suffixes
    for suffix in [" city", " town", " village", " CDP", " borough", " municipality",
                   " (balance)", " (consolidated)", " metro township"]:
        if n.lower().endswith(suffix.lower()):
            n = n[: -len(suffix)]
            break
    return n.strip()


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Download + parse 2024 Gazetteer file ...")
    zip_path = download_gazetteer()
    rows = parse_gazetteer(zip_path)
    if not rows:
        print("ERROR: no rows parsed")
        sys.exit(1)

    print(f"\nStep 2: Map USPS → FIPS state codes ...")
    state_map = get_us_state_mapping()
    print(f"  {len(state_map)} state mappings loaded")

    print(f"\nStep 3: Fetch our US cities ...")
    our_cities_by_state = get_us_cities_by_state()
    total = sum(len(v) for v in our_cities_by_state.values())
    print(f"  {total:,} US cities in {len(our_cities_by_state)} states")

    print(f"\nStep 4: Match gazetteer → our cities (by state + name) ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    matched = 0
    unmatched_samples = []

    def update_city(city_id: int, fips_state: str, fips_place: str, fips_geoid: str,
                    lsad_code: int, legal_class: str, funcstat: str,
                    land_area_sqmi: float, water_area_sqmi: float,
                    internal_lat: float, internal_lon: float) -> bool:
        # Update cities with FIPS codes
        sql1 = "UPDATE cities SET fips_state_code = ?, fips_place_code = ?, fips_geoid = ? WHERE id = ?"
        res1 = http_query(sql1, [fips_state, fips_place, fips_geoid, city_id])
        if not res1["ok"]:
            return False
        # Insert/upsert into us_census_attributes with gazetteer fields
        sql2 = """
          INSERT INTO us_census_attributes
          (city_id, fips_state, fips_place, fips_geoid,
           lsad_code, legal_class, funcstat,
           land_area_sqmi, water_area_sqmi, internal_lat, internal_lon,
           release_id, gaz_release_id, fetched_at)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          ON CONFLICT(city_id) DO UPDATE SET
            fips_state=excluded.fips_state,
            fips_place=excluded.fips_place,
            fips_geoid=excluded.fips_geoid,
            lsad_code=excluded.lsad_code,
            legal_class=excluded.legal_class,
            funcstat=excluded.funcstat,
            land_area_sqmi=excluded.land_area_sqmi,
            water_area_sqmi=excluded.water_area_sqmi,
            internal_lat=excluded.internal_lat,
            internal_lon=excluded.internal_lon,
            gaz_release_id=excluded.gaz_release_id
        """
        params2 = [
            city_id, fips_state, fips_place, fips_geoid,
            lsad_code, legal_class, funcstat,
            land_area_sqmi, water_area_sqmi, internal_lat, internal_lon,
            "",  # release_id is set by sub-est loader later
            RELEASE_ID,
            now_ms,
        ]
        res2 = http_query(sql2, params2)
        return res2["ok"]

    updates_to_run = []
    for row in rows:
        usps = row.get("USPS", "").strip()
        geoid = row.get("GEOID", "").strip()
        name = row.get("NAME", "").strip()
        lsad_raw = row.get("LSAD", "0").strip() or "0"
        try:
            lsad_code = int(lsad_raw)
        except ValueError:
            lsad_code = 0
        funcstat = row.get("FUNCSTAT", "").strip()
        try:
            land_area_sqmi = float(row.get("ALAND_SQMI", "") or 0)
        except ValueError:
            land_area_sqmi = 0
        try:
            water_area_sqmi = float(row.get("AWATER_SQMI", "") or 0)
        except ValueError:
            water_area_sqmi = 0
        try:
            internal_lat = float(row.get("INTPTLAT", "") or 0)
        except ValueError:
            internal_lat = 0
        try:
            internal_lon = float(row.get("INTPTLONG", "") or 0)
        except ValueError:
            internal_lon = 0

        if not usps or not geoid or not name:
            continue

        # FIPS state from USPS
        fips_state = state_map.get(usps)
        if not fips_state:
            continue

        # FIPS place = last 5 digits of 7-digit GEOID
        fips_place = geoid[2:7] if len(geoid) >= 7 else ""

        # Normalize name for matching — O(1) dict lookup
        normalized = normalize_name(name).lower()
        our_state_cities = our_cities_by_state.get(usps, {})
        matched_id = our_state_cities.get(normalized)

        if matched_id is None:
            if len(unmatched_samples) < 10:
                unmatched_samples.append(f"{usps} {name} (norm: {normalized})")
            continue

        # Map LSAD to legal_class
        legal_class = LSAD_MAP.get(str(lsad_code), "")

        updates_to_run.append((
            matched_id, fips_state, fips_place, geoid,
            lsad_code, legal_class, funcstat,
            land_area_sqmi, water_area_sqmi, internal_lat, internal_lon
        ))

    print(f"  Matched {len(updates_to_run):,} gazetteer → our cities")
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

    # Verify
    print(f"\nStep 6: Verify fips_geoid coverage ...")
    res = http_query("""
      SELECT COUNT(*) as n
      FROM cities c
      WHERE c.country_id = (SELECT id FROM countries WHERE cca2 = 'US')
        AND c.fips_geoid IS NOT NULL
    """)
    if res["ok"]:
        n = res["data"][0]["n"]
        print(f"  US cities with fips_geoid: {n:,}")


if __name__ == "__main__":
    main()
