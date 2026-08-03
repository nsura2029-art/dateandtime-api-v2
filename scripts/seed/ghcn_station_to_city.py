#!/usr/bin/env python3
"""
scripts/seed/ghcn_station_to_city.py

M11.8: For each of our top N cities, find the nearest GHCN-Daily station.
Then download the per-station GSOM (Global Summary of the Month) CSV file
and aggregate TMAX, TMIN, PRCP for 2020-2023.

Outputs a SQL file ready for `wrangler d1 execute --file=`.
"""
import os
import sys
import json
import time
import math
import urllib.request
import threading
from concurrent.futures import ThreadPoolExecutor, as_completed
from datetime import datetime, timezone

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

NCEI_BASE = "https://www.ncei.noaa.gov/data/gsom/access"
RELEASE_ID = "ncei-gsom-2020-2023"
DATA_YEARS = "2020-2023"
TOP_N = 30000
MAX_WORKERS = 4  # NCEI Apache may block high concurrency


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


def parse_stations(path: str) -> list:
    """Parse ghcnd-stations.txt fixed-width. Returns [{id, lat, lon, elev, name}]."""
    stations = []
    with open(path) as f:
        for line in f:
            sid = line[0:11].strip()
            try:
                lat = float(line[12:20].strip())
                lon = float(line[21:30].strip())
                elev = float(line[31:37].strip()) if line[31:37].strip() else None
            except ValueError:
                continue
            name = line[41:71].strip()
            stations.append({"id": sid, "lat": lat, "lon": lon, "elev": elev, "name": name})
    return stations


def haversine_km(lat1, lon1, lat2, lon2) -> float:
    R = 6371.0
    phi1, phi2 = math.radians(lat1), math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlam = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2) ** 2 + math.cos(phi1) * math.cos(phi2) * math.sin(dlam / 2) ** 2
    return 2 * R * math.asin(math.sqrt(a))


def get_top_cities(n: int) -> list:
    print(f"  Getting top {n:,} cities by population ...")
    res = http_query(
        """SELECT id, name, latitude, longitude FROM cities
           WHERE latitude IS NOT NULL AND longitude IS NOT NULL
                 AND population IS NOT NULL AND population > 0
           ORDER BY population DESC LIMIT ?""",
        [n]
    )
    if not res["ok"]:
        raise RuntimeError(f"Failed to get cities: {res['error']}")
    print(f"  Got {len(res['data']):,} cities")
    return res["data"]


def find_nearest_station(city: dict, grid: dict) -> dict:
    """Find nearest station using a 1-degree grid for fast lookup."""
    best = None
    best_km = float("inf")
    lat, lon = city["latitude"], city["longitude"]
    # Check 3x3 grid of 1-degree cells (center + 8 neighbors)
    # 1 degree lat ≈ 111 km, 1 degree lon varies with lat
    for dlat in (-1, 0, 1):
        for dlon in (-1, 0, 1):
            key = f"{int(lat) + dlat}_{int(lon) + dlon}"
            for s in grid.get(key, []):
                km = haversine_km(lat, lon, s["lat"], s["lon"])
                if km < best_km:
                    best_km = km
                    best = s
    if best is None:
        # Fallback: expand search
        for dlat in (-2, -1, 0, 1, 2):
            for dlon in (-2, -1, 0, 1, 2):
                if abs(dlat) <= 1 and abs(dlon) <= 1:
                    continue
                key = f"{int(lat) + dlat}_{int(lon) + dlon}"
                for s in grid.get(key, []):
                    km = haversine_km(lat, lon, s["lat"], s["lon"])
                    if km < best_km:
                        best_km = km
                        best = s
    if best:
        best["distance_km"] = round(best_km, 1)
    return best


def build_grid(stations: list) -> dict:
    """Build a 1-degree grid of stations for fast lookup."""
    grid: dict = {}
    for s in stations:
        key = f"{int(s['lat'])}_{int(s['lon'])}"
        grid.setdefault(key, []).append(s)
    return grid


def fetch_station_csv(station_id: str) -> tuple:
    """Fetch GSOM CSV for a station. Returns (station_id, rows) where rows is
    [(YYYY-MM, tmax, tmin, prcp), ...] or None on error."""
    url = f"{NCEI_BASE}/{station_id}.csv"
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "dateandtime-api-v2/1.0"})
        with urllib.request.urlopen(req, timeout=30) as r:
            data = r.read().decode("utf-8", errors="replace")
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return (station_id, None, "404 not found")  # Common: many stations don't have monthly data
        return (station_id, None, f"HTTP {e.code}")
    except Exception as e:
        return (station_id, None, str(e))

    # Parse: header line + data lines
    # Columns are QUOTED: "STATION","DATE","LATITUDE",...,"TMAX","TMIN",...,"PRCP",...
    import csv
    import io
    reader = csv.reader(io.StringIO(data))
    try:
        header = next(reader)
    except StopIteration:
        return (station_id, None, "Empty file")
    # Strip quotes from header
    header = [h.strip('"') for h in header]
    try:
        idx_tmax = header.index("TMAX")
        idx_tmin = header.index("TMIN")
        idx_prcp = header.index("PRCP")
    except ValueError:
        return (station_id, None, "Missing columns")

    rows_by_month: dict = {}
    for parts in reader:
        if len(parts) < len(header):
            continue
        date = parts[1]  # YYYY-MM
        if not (date.startswith("2020") or date.startswith("2021") or date.startswith("2022") or date.startswith("2023")):
            continue
        month_key = date  # YYYY-MM
        if month_key not in rows_by_month:
            rows_by_month[month_key] = {"tmax": [], "tmin": [], "prcp": 0.0}
        v = parts[idx_tmax].strip('"')
        if v and v != "":
            try:
                rows_by_month[month_key]["tmax"].append(float(v))
            except ValueError:
                pass
        v = parts[idx_tmin].strip('"')
        if v and v != "":
            try:
                rows_by_month[month_key]["tmin"].append(float(v))
            except ValueError:
                pass
        v = parts[idx_prcp].strip('"')
        if v and v != "":
            try:
                rows_by_month[month_key]["prcp"] += float(v)
            except ValueError:
                pass

    # Aggregate: monthly avg TMAX, TMIN, sum PRCP
    monthly = []
    for m in range(1, 13):
        # Use 2023 (most recent year of normals)
        key = f"2023-{m:02d}"
        if key in rows_by_month and rows_by_month[key]["tmax"]:
            tmax_avg = sum(rows_by_month[key]["tmax"]) / len(rows_by_month[key]["tmax"])
            tmin_avg = sum(rows_by_month[key]["tmin"]) / len(rows_by_month[key]["tmin"]) if rows_by_month[key]["tmin"] else None
            prcp_total = rows_by_month[key]["prcp"]
            monthly.append((m, round(tmax_avg, 1), round(tmin_avg, 1) if tmin_avg is not None else None, round(prcp_total, 1)))
    return (station_id, monthly, None)


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Load GHCN stations ...")
    stations = parse_stations("tmp/ghcnd-stations.txt")
    print(f"  Loaded {len(stations):,} stations")

    print(f"\nStep 2: Build 1-degree grid for fast nearest-station lookup ...")
    grid = build_grid(stations)
    print(f"  Grid: {len(grid):,} cells")

    print(f"\nStep 3: Get top {TOP_N:,} cities ...")
    cities = get_top_cities(TOP_N)

    print(f"\nStep 4: Match cities to nearest stations ...")
    city_station = []
    for c in cities:
        s = find_nearest_station(c, grid)
        if s:
            city_station.append((c["id"], c["name"], s))
    print(f"  Matched {len(city_station):,} cities to stations")
    # Distance distribution
    distances = [s["distance_km"] for _, _, s in city_station]
    print(f"  Distance: min={min(distances):.1f}km, median={sorted(distances)[len(distances)//2]:.1f}km, max={max(distances):.1f}km")
    print(f"  Cities > 100km from any station: {sum(1 for d in distances if d > 100):,}")
    print(f"  Cities > 50km from any station: {sum(1 for d in distances if d > 50):,}")

    # Unique stations
    unique_stations = {s["id"]: s for _, _, s in city_station}
    print(f"  Unique stations: {len(unique_stations):,}")

    print(f"\nStep 5: Download GSOM data for {len(unique_stations):,} stations ({MAX_WORKERS} workers) ...")
    start = time.time()
    monthly_data: dict = {}  # station_id -> [(month, hi, lo, prcp), ...]
    errors = []
    completed = 0
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as ex:
        futures = {ex.submit(fetch_station_csv, sid): sid for sid in unique_stations}
        for fut in as_completed(futures):
            completed += 1
            sid, monthly, err = fut.result()
            if err:
                errors.append((sid, err))
            elif monthly:
                monthly_data[sid] = monthly
            if completed % 100 == 0:
                elapsed = time.time() - start
                rate = completed / elapsed
                eta = (len(unique_stations) - completed) / rate / 60 if rate > 0 else 0
                print(f"  {completed:,}/{len(unique_stations):,} ({len(monthly_data):,} OK, {len(errors):,} err) - {rate:.1f}/s - ETA {eta:.1f} min")

    elapsed = time.time() - start
    print(f"\n  Done: {len(monthly_data):,} stations, {len(errors):,} errors, {elapsed:.0f}s")

    if not monthly_data:
        print("  No data to insert!")
        return

    print(f"\nStep 6: Build SQL file ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    rows = []
    matched_count = 0
    for city_id, city_name, station in city_station:
        sid = station["id"]
        if sid not in monthly_data:
            continue
        for m, hi, lo, prcp in monthly_data[sid]:
            rows.append(
                f"({city_id}, {m}, {hi}, {lo if lo is not None else 'NULL'}, {prcp}, "
                f"'{DATA_YEARS}', 'ncei-gsom', '{RELEASE_ID}', {now_ms})"
            )
        matched_count += 1

    print(f"  Matched cities with data: {matched_count:,}")
    print(f"  Total monthly rows: {len(rows):,}")

    sql_path = "tmp/climate_ncei.sql"
    BATCH_ROWS = 8
    with open(sql_path, "w") as f:
        f.write("DELETE FROM climate_real WHERE source = 'ncei-gsom';\n")
        for i in range(0, len(rows), BATCH_ROWS):
            chunk = rows[i:i + BATCH_ROWS]
            f.write(f"INSERT OR REPLACE INTO climate_real "
                    f"(city_id, month, avg_high_c, avg_low_c, precipitation_mm, data_years, source, release_id, retrieved_at) "
                    f"VALUES {','.join(chunk)};\n")

    print(f"  Wrote {sql_path} ({len(rows):,} rows, {len(rows) // BATCH_ROWS} batches)")
    print(f"  To load: npx wrangler d1 execute timeandtimepro-full-v2 --file={sql_path} --env dev")


if __name__ == "__main__":
    main()
