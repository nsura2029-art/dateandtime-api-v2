#!/usr/bin/env python3
"""
scripts/seed/census_india_to_d1.py

M11.7: Load Census of India 2011 PCA-UA data into D1.

Source: PCA11-UA-0000.xlsx (Primary Census Abstract - Urban Agglomeration)
  https://censusindia.gov.in/nada/index.php/catalog/45261/download/48987/PCA11-UA-0000.xlsx
  1.98 MB XLSX, 3,320 rows × 96 columns, released 2011

Hierarchy:
  Level 0 = Urban Agglomeration total (e.g. "Srinagar UA")
  Level 1 = Statutory city within UA (e.g. "Srinagar (M Corp.+OG)") — 1,946 records
  Level 2 = Sub-town / Outgrowth (OG) (e.g. "Bagh-I-Mehtab (OG)") — 902 records
  Level 3 = Sub-sub (rare) — 3 records

We match Level 1 + Level 2 to our DB (1,946 + 902 = 2,848 candidates).
Most are Level 1 cities (the actual statutory cities).

Matching strategy:
  1. Try exact name match (normalize: strip parentheticals, trim spaces)
  2. Try fuzzy match against our IN cities (state-aware)
  3. Match key: (state_code, normalized_city_name)

What gets stored:
  - All demographic data (population, sex, literacy, workers, SC/ST)
  - census_code (6-digit town code) → stored in cities.in_census_code
  - ua_code + ua_name (the parent Urban Agglomeration)
  - level (1 or 2)
  - census_year (2011)
"""
import os
import sys
import re
import time
import json
import urllib.request
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

try:
    import openpyxl
except ImportError:
    print("ERROR: openpyxl not installed. Run: pip install openpyxl --break-system-packages")
    sys.exit(1)

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")
RELEASE_ID = "in-census-2011-2026-08-03"

URL = "https://censusindia.gov.in/nada/index.php/catalog/45261/download/48987/PCA11-UA-0000.xlsx"


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


# Indian state code → ISO 3166-2 mapping (Census of India 2011 state codes)
# Source: Census of India uses 2-digit state codes; we map to our countries.cca2='IN'
# (all Indian states map to cca2='IN', but we keep state_code for granularity)
INDIAN_STATE_NAMES = {
    "01": "Jammu & Kashmir",
    "02": "Himachal Pradesh",
    "03": "Punjab",
    "04": "Chandigarh",
    "05": "Uttarakhand",
    "06": "Haryana",
    "07": "NCT of Delhi",
    "08": "Rajasthan",
    "09": "Uttar Pradesh",
    "10": "Bihar",
    "11": "Sikkim",
    "12": "Arunachal Pradesh",
    "13": "Nagaland",
    "14": "Manipur",
    "15": "Mizoram",
    "16": "Tripura",
    "17": "Meghalaya",
    "18": "Assam",
    "19": "West Bengal",
    "20": "Jharkhand",
    "21": "Odisha",
    "22": "Chhattisgarh",
    "23": "Madhya Pradesh",
    "24": "Gujarat",
    "25": "Daman & Diu",
    "26": "Dadra & Nagar Haveli",
    "27": "Maharashtra",
    "28": "Andhra Pradesh",
    "29": "Karnataka",
    "30": "Goa",
    "31": "Lakshadweep",
    "32": "Kerala",
    "33": "Tamil Nadu",
    "34": "Puducherry",
    "35": "Andaman & Nicobar Islands",
}


def normalize_name(name: str) -> str:
    """Normalize an Indian city name for matching."""
    if not name:
        return ""
    n = name.strip()
    # Remove leading "(a) ", "(b) " etc.
    n = re.sub(r"^\([a-z]\)\s*", "", n)
    # Remove "(M Corp.+OG)", "(MC)", "(CT)", "(CB)", "(OG)" suffixes
    n = re.sub(r"\s*\([^)]*\)\s*$", "", n).strip()
    # Normalize whitespace
    n = re.sub(r"\s+", " ", n)
    return n.lower()


def parse_ua_name(ua_name: str) -> tuple:
    """Parse a UA Name like ' (a) Srinagar (M Corp.+OG)' into (parent_ua, suffix)."""
    if not ua_name:
        return ("", "")
    m = re.match(r"^\s*\(([a-z])\)\s*(.+)$", ua_name)
    if m:
        return (m.group(2).strip(), m.group(1))
    return (ua_name.strip(), "")


def download_pca_ua() -> Path:
    """Download the PCA-UA XLSX file."""
    tmp_dir = Path("tmp")
    tmp_dir.mkdir(exist_ok=True)
    xlsx_path = tmp_dir / "pca_ua_2011.xlsx"
    if xlsx_path.exists() and xlsx_path.stat().st_size > 1_000_000:
        print(f"  Using cached {xlsx_path} ({xlsx_path.stat().st_size:,} bytes)")
        return xlsx_path
    print(f"  Downloading {URL} ...")
    import ssl
    ctx = ssl.create_default_context()
    ctx.check_hostname = False
    ctx.verify_mode = ssl.CERT_NONE
    req = urllib.request.Request(URL, method="GET")
    with urllib.request.urlopen(req, timeout=300, context=ctx) as r:
        data = r.read()
    with open(xlsx_path, "wb") as f:
        f.write(data)
    print(f"  Downloaded {len(data):,} bytes → {xlsx_path}")
    return xlsx_path


def get_in_cities_by_state() -> dict:
    """Fetch all our IN cities grouped by state name for fast matching."""
    print("  Fetching our IN cities (with state name) ...")
    res = http_query("""
      SELECT c.id, c.name, s.name as state_name
      FROM cities c
      JOIN countries co ON co.id = c.country_id
      LEFT JOIN administrative_regions s ON s.id = c.state_id AND s.type = 'state'
      WHERE co.cca2 = 'IN'
    """)
    if not res["ok"]:
        raise RuntimeError(f"IN cities fetch failed: {res['error']}")
    # Group by (state_name, normalized_name) → city_id
    by_state = {}
    for row in res["data"]:
        key_state = (row.get("state_name") or "").strip()
        key_norm = normalize_name(row["name"])
        if key_state and key_norm:
            by_state[(key_state.lower(), key_norm)] = row["id"]
    total = len(res["data"])
    print(f"  {total:,} IN cities")
    return by_state


def parse_pca_ua(xlsx_path: Path) -> list:
    """Parse PCA-UA XLSX into a list of city records."""
    print(f"  Parsing {xlsx_path} ...")
    wb = openpyxl.load_workbook(xlsx_path, read_only=True, data_only=True)
    ws = wb["Data"]
    cities = []
    for i, row in enumerate(ws.iter_rows(min_row=2, values_only=True)):
        if not row or not row[6]:
            continue
        try:
            level = int(row[6])
        except (TypeError, ValueError):
            continue
        # Keep Level 0 (UA total), Level 1 (statutory city), Level 2 (sub-towns/OGs)
        if level not in (0, 1, 2):
            continue
        # Skip if no UA code (Level 0 has UA code but no town code)
        if not row[4]:
            continue
        # For Level 1+ we need a town code; Level 0 has no town code
        town_code = str(row[3]).strip() if row[3] else None
        cities.append({
            "state_code": str(row[0] or "").strip(),
            "district_code": str(row[1] or "").strip(),
            "sub_dist_code": str(row[2] or "").strip(),
            "town_code": town_code,
            "ua_code": str(row[4] or "").strip(),
            "ua_name": str(row[5] or "").strip(),
            "level": level,
            "households": int(row[9] or 0) if row[9] else 0,
            "population": int(row[10] or 0) if row[10] else 0,
            "male_population": int(row[11] or 0) if row[11] else 0,
            "female_population": int(row[12] or 0) if row[12] else 0,
            "child_population": int(row[13] or 0) if row[13] else 0,
            "child_male": int(row[14] or 0) if row[14] else 0,
            "child_female": int(row[15] or 0) if row[15] else 0,
            "sc_population": int(row[16] or 0) if row[16] else 0,
            "st_population": int(row[19] or 0) if row[19] else 0,
            "literate_population": int(row[22] or 0) if row[22] else 0,
            "illiterate_population": int(row[25] or 0) if row[25] else 0,
            "workers_total": int(row[28] or 0) if row[28] else 0,
            "main_workers": int(row[31] or 0) if row[31] else 0,
            "marginal_workers": int(row[46] or 0) if row[46] else 0,
            "non_workers": int(row[91] or 0) if row[91] else 0,
        })
    print(f"  {len(cities):,} candidate records (Level 0+1+2)")
    return cities


def upsert_city(rec: dict, our_city_id: int, census_code: str, now_ms: int) -> bool:
    """Insert/update in_census_attributes for a matched city."""
    # Update cities.in_census_code first
    sql1 = "UPDATE cities SET in_census_code = ? WHERE id = ?"
    res1 = http_query(sql1, [census_code, our_city_id])
    if not res1["ok"]:
        return False

    # Upsert in_census_attributes
    sql2 = """
      INSERT INTO in_census_attributes
      (city_id, census_code, state_code, district_code, sub_district_code,
       ua_code, ua_name, level,
       households, population, male_population, female_population,
       child_population, child_male, child_female,
       sc_population, st_population,
       literate_population, illiterate_population,
       workers_total, main_workers, marginal_workers, non_workers,
       census_year, release_id, fetched_at)
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(city_id) DO UPDATE SET
        census_code=excluded.census_code,
        state_code=excluded.state_code,
        district_code=excluded.district_code,
        sub_district_code=excluded.sub_district_code,
        ua_code=excluded.ua_code,
        ua_name=excluded.ua_name,
        level=excluded.level,
        households=excluded.households,
        population=excluded.population,
        male_population=excluded.male_population,
        female_population=excluded.female_population,
        child_population=excluded.child_population,
        child_male=excluded.child_male,
        child_female=excluded.child_female,
        sc_population=excluded.sc_population,
        st_population=excluded.st_population,
        literate_population=excluded.literate_population,
        illiterate_population=excluded.illiterate_population,
        workers_total=excluded.workers_total,
        main_workers=excluded.main_workers,
        marginal_workers=excluded.marginal_workers,
        non_workers=excluded.non_workers,
        release_id=excluded.release_id,
        fetched_at=excluded.fetched_at
    """
    params = [
        our_city_id, census_code, rec["state_code"], rec["district_code"],
        rec["sub_dist_code"], rec["ua_code"], rec["ua_name"], rec["level"],
        rec["households"], rec["population"], rec["male_population"], rec["female_population"],
        rec["child_population"], rec["child_male"], rec["child_female"],
        rec["sc_population"], rec["st_population"],
        rec["literate_population"], rec["illiterate_population"],
        rec["workers_total"], rec["main_workers"], rec["marginal_workers"], rec["non_workers"],
        2011, RELEASE_ID, now_ms,
    ]
    res2 = http_query(sql2, params)
    return res2["ok"]


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Download PCA-UA XLSX ...")
    xlsx_path = download_pca_ua()

    print("\nStep 2: Parse XLSX ...")
    cities = parse_pca_ua(xlsx_path)

    print("\nStep 3: Fetch our IN cities ...")
    our_cities_by_state = get_in_cities_by_state()

    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)

    print("\nStep 4: Match cities (preferring Level 1 over Level 0) ...")
    matched = 0
    unmatched_samples = []
    # Group candidates by (state, normalized_name) so we can prefer Level 1
    by_key = {}  # (state, norm_name) -> list of (rec, level)
    for rec in cities:
        state_name = INDIAN_STATE_NAMES.get(rec["state_code"], "")
        if not state_name:
            unmatched_samples.append(f"unknown state {rec['state_code']}")
            continue
        ua_name_clean = re.sub(r"^\s*\([a-z]+\)\s*", "", rec["ua_name"])
        # Generate possible match names
        candidates = []
        # 1. Full UA name (cleaned)
        n1 = normalize_name(ua_name_clean)
        if n1:
            candidates.append(n1)
        # 2. Remove any (M Corp.) etc. suffix
        n2 = re.sub(r"\s*\([^)]*\)\s*$", "", ua_name_clean).strip()
        n2_norm = normalize_name(n2)
        if n2_norm and n2_norm != n1:
            candidates.append(n2_norm)
        # 3. Try removing "Greater" prefix (e.g. "Greater Mumbai" → "Mumbai")
        n3 = re.sub(r"^greater\s+", "", n2, flags=re.IGNORECASE).strip()
        n3_norm = normalize_name(n3)
        if n3_norm and n3_norm not in candidates:
            candidates.append(n3_norm)
        # 4. Try removing "Bruhat" prefix
        n4 = re.sub(r"^bruhat\s+", "", n2, flags=re.IGNORECASE).strip()
        n4_norm = normalize_name(n4)
        if n4_norm and n4_norm not in candidates:
            candidates.append(n4_norm)
        # 5. Try removing " UA" suffix (Level 0 names end with "UA")
        n5 = re.sub(r"\s+ua$", "", n2, flags=re.IGNORECASE).strip()
        n5_norm = normalize_name(n5)
        if n5_norm and n5_norm not in candidates:
            candidates.append(n5_norm)
        for c in candidates:
            key = (state_name.lower(), c)
            if key not in by_key:
                by_key[key] = []
            by_key[key].append(rec)

    # Build a "by_state" lookup of all keys per state for prefix matching
    by_state_keys = {}  # state_lower → [(full_key, list_of_recs)]
    for key, recs in by_key.items():
        state_lower = key[0]
        by_state_keys.setdefault(state_lower, []).append((key, recs))

    # Now resolve: for each (state, name) in our DB, find the best match
    # Prefer Level 1 (city proper) over Level 0 (metro) — Level 1 is more specific
    updates_to_run = []
    matched_keys = set()
    for key, our_city_id in our_cities_by_state.items():
        state_lower, name_lower = key
        if key in by_key:
            # Direct match — prefer Level 1 over Level 0
            candidates = sorted(by_key[key], key=lambda r: (r["level"] != 1, r["level"]))
            best = candidates[0]
            census_code = best["town_code"] or best["ua_code"]
            updates_to_run.append((best, our_city_id, census_code))
            matched_keys.add(key)
        else:
            # Try prefix match: "Bruhat Bangalore" should match "Bangalore" in our DB
            matched_prefix = False
            for full_key, recs in by_state_keys.get(state_lower, []):
                if full_key == key:
                    continue
                if full_key[1].endswith(" " + name_lower) or full_key[1].endswith(name_lower):
                    candidates = sorted(recs, key=lambda r: (r["level"] != 1, r["level"]))
                    best = candidates[0]
                    census_code = best["town_code"] or best["ua_code"]
                    updates_to_run.append((best, our_city_id, census_code))
                    matched_keys.add(key)
                    matched_prefix = True
                    break
            if not matched_prefix and len(unmatched_samples) < 5:
                unmatched_samples.append(f"{key[0]} | {key[1]}")

    matched = len(updates_to_run)
    print(f"  Matched {matched:,} unique cities (out of {len(our_cities_by_state):,} IN cities)")
    print(f"  Unmatched: {len(our_cities_by_state) - matched}")
    for u in unmatched_samples:
        print(f"    Unmatched: {u}")

    print(f"\nStep 5: Run {matched:,} city upserts in parallel ...")
    success = 0
    start = time.time()
    last_log = start
    with ThreadPoolExecutor(max_workers=16) as executor:
        futures = {executor.submit(upsert_city, rec, city_id, census_code, now_ms): (rec, city_id) for rec, city_id, census_code in updates_to_run}
        for future in as_completed(futures):
            if future.result():
                success += 1
            now = time.time()
            if now - last_log > 2:
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
        COUNT(DISTINCT state_code) as states,
        COUNT(DISTINCT ua_code) as uas,
        SUM(CASE WHEN population > 0 THEN 1 ELSE 0 END) as n_with_pop,
        SUM(population) as total_pop
      FROM in_census_attributes
    """)
    if res["ok"]:
        r = res["data"][0]
        print(f"  Rows in in_census_attributes: {r['n']:,}")
        print(f"  States: {r['states']}")
        print(f"  UAs: {r['uas']:,}")
        print(f"  With population: {r['n_with_pop']:,}")
        print(f"  Total population: {r['total_pop']:,}")


if __name__ == "__main__":
    main()
