#!/usr/bin/env python3
"""
scripts/seed/merge_wikidata_population.py

M11.2.x: Apply Wikidata population values to cities table.

Strategy:
  - ONLY fill in NULL populations (don't overwrite dr5hn's curated values)
  - Wikidata may have stale population; dr5hn's is more authoritative when present
  - This recovers ~21,000 NULLs

SQL pattern (one statement per HTTP call, multiple UPDATEs in one CASE):
  UPDATE cities SET
    population = CASE wiki_data_id
      WHEN ? THEN ?
      WHEN ? THEN ?
      ...
    END
  WHERE wiki_data_id IN (?, ?, ...) AND population IS NULL

We can batch ~12 Q-ids per call (12 WHEN clauses × 2 params = 24 + 12 IN = 36 binds).
That's 9× faster than one row per call.
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
RELEASE_ID = "wikidata-entities-2026-08-02"
CHUNK = 12  # 12 × (2 + 1) = 36 binds, well under 100-var limit
WORKERS = 16


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


def build_sql(chunk: list, run_id: str, now_ms: int) -> tuple:
    """Build the CASE WHEN UPDATE SQL for a chunk of rows."""
    when_clauses = []
    qids = []
    params = []
    for row in chunk:
        qid = row["qid"]
        pop = int(row["wikidata_population"])
        when_clauses.append("WHEN ? THEN ?")
        qids.append(qid)
        params.extend([qid, pop])
    placeholders = " ".join(when_clauses)
    in_placeholders = ",".join(["?"] * len(qids))
    sql = f"""UPDATE cities SET
  population = CASE wiki_data_id {placeholders} END,
  merge_run_id = ?,
  merged_at = ?
WHERE wiki_data_id IN ({in_placeholders}) AND population IS NULL"""
    # Append run_id, now_ms, then qids for IN clause
    full_params = params + [run_id, now_ms] + qids
    return sql, full_params


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Reading wikidata_staging (with population) ...")
    res = http_query(f"""
        SELECT qid, wikidata_population
        FROM wikidata_staging
        WHERE release_id = ? AND wikidata_population IS NOT NULL
    """, [RELEASE_ID])
    if not res["ok"]:
        print(f"ERROR: {res['error']}")
        sys.exit(1)
    rows = res["data"]
    print(f"  Got {len(rows):,} Wikidata rows with population")

    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    run_id = f"merge-wikidata-pop-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}"
    print(f"Step 2: Applying updates (run_id={run_id}) ...")
    print(f"  Strategy: only update cities where population IS NULL")
    print(f"  CHUNK={CHUNK} Q-ids/stmt, {WORKERS} workers")
    print(f"  36 binds/stmt: 12 WHEN clauses + run_id + now_ms + 12 IN ids")

    def apply_chunk(chunk: list) -> int:
        sql, params = build_sql(chunk, run_id, now_ms)
        res = http_query(sql, params)
        if res["ok"]:
            return res.get("meta", {}).get("changes", 0)
        return 0

    success_rows = 0
    total_changes = 0
    failed = 0
    start = time.time()
    last_log = start

    with ThreadPoolExecutor(max_workers=WORKERS) as executor:
        chunks = [rows[i:i+CHUNK] for i in range(0, len(rows), CHUNK)]
        futures = {executor.submit(apply_chunk, c): c for c in chunks}
        for future in as_completed(futures):
            chunk_size = len(futures[future])
            changes = future.result()
            success_rows += chunk_size
            total_changes += changes
            now = time.time()
            if now - last_log > 3:
                elapsed = now - start
                rate = success_rows / elapsed if elapsed > 0 else 0
                eta = (len(rows) - success_rows) / rate if rate > 0 else 0
                print(f"  {success_rows:,}/{len(rows):,} ({rate:.0f} rows/s, ETA {eta/60:.1f} min, {total_changes:,} cities updated)", flush=True)
                last_log = now

    elapsed = time.time() - start
    print(f"\nDone. {success_rows:,} Wikidata entries applied in {elapsed/60:.1f} min")
    print(f"  Total cities with new population: {total_changes:,}")


if __name__ == "__main__":
    main()
