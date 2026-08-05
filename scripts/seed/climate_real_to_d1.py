#!/usr/bin/env python3
"""
scripts/seed/climate_real_to_d1.py

M11.8: Real climate data from Open-Meteo Historical API for top 30K cities by population.

Open-Meteo: free, no API key, global coverage.
- 1 API call per city (4 years of daily data, 2020-2023)
- Aggregate to monthly normals: avg_high_c, avg_low_c, precipitation_mm
- Parallelize: 10 concurrent requests (Open-Meteo limit)
- ~2-3 hours for 30K cities

Output: bulk SQL file for `wrangler d1 execute --file=` (much faster than HTTP API)
"""
import os
import sys
import json
import time
import threading
import urllib.request
import urllib.error
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

OPEN_METEO_URL = "https://archive-api.open-meteo.com/v1/archive"
RELEASE_ID = "open-meteo-2020-2023"
DATA_YEARS = "2020-2023"
MAX_WORKERS = 1  # 1 worker to avoid the sticky minutely rate limit
TOP_N = 5000

# Single-worker sequential
_last_request_lock = threading.Lock()
_last_request_time = [0.0]


def rate_limited_request(worker_id: int, url: str, timeout: int = 60, max_retries: int = 10) -> str:
    """Make a request with sequential throttle."""
    for attempt in range(max_retries):
        with _last_request_lock:
            last = _last_request_time[0]
            elapsed = time.time() - last
            # 1.5s between requests = 0.67 req/s, well under any minutely limit
            if elapsed < 1.5:
                time.sleep(1.5 - elapsed)
            _last_request_time[0] = time.time()
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "dateandtime-api-v2-migration/1.0"})
            with urllib.request.urlopen(req, timeout=timeout) as r:
                return r.read().decode()
        except urllib.error.HTTPError as e:
            if e.code == 429:
                wait = 90
                sys.stderr.write(f"    [w{worker_id}] 429 minutely limit, waiting {wait}s ...\n")
                time.sleep(wait)
                continue
            if e.code in (500, 503):
                time.sleep(10)
                continue
            raise
    raise RuntimeError(f"Failed after {max_retries} retries")


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


def fetch_climate(args: tuple) -> tuple:
    worker_id, city = args
    lat = city["latitude"]
    lon = city["longitude"]
    url = (
        f"{OPEN_METEO_URL}?latitude={lat}&longitude={lon}"
        f"&start_date=2020-01-01&end_date=2023-12-31"
        f"&daily=temperature_2m_max,temperature_2m_min,precipitation_sum"
        f"&timezone=auto"
    )
    try:
        text = rate_limited_request(worker_id, url, timeout=60)
        data = json.loads(text)
    except urllib.error.HTTPError as e:
        return (city["id"], None, f"HTTP {e.code}")
    except Exception as e:
        return (city["id"], None, str(e))

    if "daily" not in data:
        return (city["id"], None, "No daily data")

    times = data["daily"]["time"]
    tmaxs = data["daily"]["temperature_2m_max"]
    tmins = data["daily"]["temperature_2m_min"]
    prcps = data["daily"]["precipitation_sum"]

    by_month: dict = {}
    for i, t in enumerate(times):
        month = int(t[5:7])
        if month not in by_month:
            by_month[month] = {"max": [], "min": [], "prcp": 0.0}
        if tmaxs[i] is not None:
            by_month[month]["max"].append(tmaxs[i])
        if tmins[i] is not None:
            by_month[month]["min"].append(tmins[i])
        if prcps[i] is not None:
            by_month[month]["prcp"] += prcps[i]

    monthly = []
    for m in range(1, 13):
        if m in by_month and by_month[m]["max"]:
            avg_max = sum(by_month[m]["max"]) / len(by_month[m]["max"])
            avg_min = sum(by_month[m]["min"]) / len(by_month[m]["min"])
            monthly.append((m, round(avg_max, 1), round(avg_min, 1), round(by_month[m]["prcp"], 1)))
    return (city["id"], monthly, None)


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Get top N cities by population ...")
    cities = get_top_cities(TOP_N)
    if not cities:
        print("  No cities found!")
        return

    print(f"\nStep 2: Fetch climate from Open-Meteo ({len(cities):,} cities, {MAX_WORKERS} workers) ...")
    start = time.time()
    monthly_rows: dict = {}
    errors = []
    completed = 0
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as ex:
        futures = {ex.submit(fetch_climate, (i % MAX_WORKERS, c)): c for i, c in enumerate(cities)}
        for fut in as_completed(futures):
            completed += 1
            city_id, monthly, err = fut.result()
            if err:
                errors.append((city_id, err))
            elif monthly:
                monthly_rows[city_id] = monthly
            if completed % 200 == 0:
                elapsed = time.time() - start
                rate = completed / elapsed
                eta = (len(cities) - completed) / rate / 60 if rate > 0 else 0
                print(f"  {completed:,}/{len(cities):,} ({len(monthly_rows):,} OK, {len(errors):,} err) - {rate:.1f}/s - ETA {eta:.1f} min")

    elapsed = time.time() - start
    print(f"\n  Done: {len(monthly_rows):,} cities, {len(errors):,} errors, {elapsed:.0f}s")

    if not monthly_rows:
        print("  No data to insert!")
        return

    print(f"\nStep 3: Build bulk SQL file ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    rows = []
    for city_id, months in monthly_rows.items():
        for month, hi, lo, prcp in months:
            rows.append(
                f"({city_id}, {month}, {hi}, {lo}, {prcp}, "
                f"'{DATA_YEARS}', 'open-meteo', '{RELEASE_ID}', {now_ms})"
            )

    sql_path = "tmp/climate_real.sql"
    os.makedirs("tmp", exist_ok=True)
    BATCH_ROWS = 8
    with open(sql_path, "w") as f:
        f.write("DELETE FROM climate_real WHERE source = 'open-meteo';\n")
        for i in range(0, len(rows), BATCH_ROWS):
            chunk = rows[i:i + BATCH_ROWS]
            f.write(f"INSERT OR REPLACE INTO climate_real "
                    f"(city_id, month, avg_high_c, avg_low_c, precipitation_mm, data_years, source, release_id, retrieved_at) "
                    f"VALUES {','.join(chunk)};\n")

    print(f"  Wrote {sql_path} ({len(rows):,} rows, {len(rows) // BATCH_ROWS} batches)")
    print(f"  To load: npx wrangler d1 execute timeandtimepro-full-v2 --file={sql_path} --env dev")


if __name__ == "__main__":
    main()
