#!/usr/bin/env python3
"""
scripts/seed/altnames_to_d1_http.py

Load alternateNamesV2_cities5000.txt into D1 alt_names_staging using the
D1 HTTP API directly with parallel requests (much faster than wrangler).

For 767K rows in batches of 11 (99 vars each) with 16 parallel workers,
loads in ~3-5 minutes.

D1 HTTP API limit: ~100 vars/statement. With 9 cols, max 11 rows/batch.
"""
import os
import sys
import json
import time
import urllib.request
import urllib.error
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")
SOURCE_PATH = Path("/tmp/geonames/alternateNamesV2_cities5000.txt")
RELEASE_ID = f"geonames-altnames-{datetime.now(timezone.utc).strftime('%Y-%m-%d')}"
BATCH = 11  # 9 cols × 11 = 99 params, under 100
WORKERS = 16  # parallel HTTP requests

if not TOKEN:
    print("ERROR: CLOUDFLARE_API_TOKEN env var not set")
    sys.exit(1)


def post_query(sql: str, params: list) -> dict:
    """POST a single SQL statement to the D1 HTTP API."""
    url = f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT}/d1/database/{DB_ID}/query"
    payload = json.dumps({"sql": sql, "params": params}).encode("utf-8")
    req = urllib.request.Request(
        url,
        data=payload,
        method="POST",
        headers={
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            resp = json.loads(r.read().decode("utf-8"))
            outer_ok = resp.get("success", False)
            inner = (resp.get("result") or [{}])[0]
            inner_ok = inner.get("success", False)
            err = ""
            if not inner_ok:
                errs = inner.get("errors", [])
                if errs:
                    err = errs[0].get("message", "")
            return {
                "ok": outer_ok and inner_ok,
                "data": inner.get("results", []),
                "meta": inner.get("meta", {}),
                "error": err,
            }
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8")[:500]
        return {"ok": False, "data": [], "error": body}
    except Exception as e:
        return {"ok": False, "data": [], "error": str(e)}


def build_batch_sql(chunk: list, now_ms: int) -> tuple:
    """Build SQL + params for a batch of 11 rows."""
    placeholders = ",".join(["(?,?,?,?,?,?,?,?,?)"] * len(chunk))
    sql = f"""INSERT OR REPLACE INTO alt_names_staging
  (release_id, geonameid, isolanguage, alternate_name, is_preferred, is_short, is_colloquial, is_historic, loaded_at)
VALUES {placeholders}"""
    params = []
    for p in chunk:
        alt_id, gid, lang, name, pref, short, col, hist = p
        params.extend([
            RELEASE_ID,
            int(gid),
            lang,
            name,
            int(pref) if pref else 0,
            int(short) if short else 0,
            int(col) if col else 0,
            int(hist) if hist else 0,
            now_ms,
        ])
    return sql, params


def main():
    print(f"Loading {SOURCE_PATH} into alt_names_staging as release_id={RELEASE_ID}")
    print(f"BATCH={BATCH} rows/req, WORKERS={WORKERS}")

    # Read and parse
    rows = []
    with open(SOURCE_PATH, encoding="utf-8") as f:
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 8:
                continue
            try:
                int(parts[0])
                int(parts[1])
            except ValueError:
                continue
            rows.append(parts[:8])
    print(f"Total rows: {len(rows):,}")

    # Build all batches
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    batches = []
    for i in range(0, len(rows), BATCH):
        chunk = rows[i:i + BATCH]
        sql, params = build_batch_sql(chunk, now_ms)
        batches.append((i, sql, params))
    total_batches = len(batches)
    print(f"Total batches: {total_batches:,} ({total_batches * BATCH:,} potential rows)")

    # Submit in parallel
    success = 0
    failed = 0
    start = time.time()
    last_report = start

    with ThreadPoolExecutor(max_workers=WORKERS) as executor:
        futures = {executor.submit(post_query, sql, params): i for i, sql, params in batches}
        for future in as_completed(futures):
            res = future.result()
            if res["ok"]:
                success += BATCH
            else:
                failed += 1
                if failed <= 3:
                    print(f"  FAILED: {res.get('error', '')[:200]}")

            now = time.time()
            if now - last_report > 5:
                elapsed = now - start
                rate = (success + failed * BATCH) / elapsed if elapsed > 0 else 0
                eta = (len(rows) - success - failed * BATCH) / rate if rate > 0 else 0
                print(f"  {success:,}/{len(rows):,} ({rate:.0f} rows/s, ETA {eta/60:.1f} min, {failed} failed)")
                last_report = now

    elapsed = time.time() - start
    print(f"\nDone. {success:,} rows loaded in {elapsed/60:.1f} min ({success/elapsed:.0f} rows/s)")
    if failed > 0:
        print(f"  {failed} batches failed ({failed * BATCH} potential rows lost)")


if __name__ == "__main__":
    main()
