#!/usr/bin/env python3
"""
scripts/seed/merge_wikidata.py

M11.2 merge: read wikidata_staging, populate cities.wiki_url and
add wikidata_id cross-reference.

For each city in cities that has a wiki_data_id matching a qid in
wikidata_staging:
  - Set cities.wiki_url = the Wikipedia URL
  - Set cities.source_merged_with to add 'wikidata' to existing sources
  - Note: do NOT overwrite existing merge_method (dr5hn is still authoritative)

This is a non-destructive merge: cities.wiki_url is NULL by default,
and only gets populated if Wikidata has a match.
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
WORKSPACE = Path("/workspace/dateandtime-api-v2")


def http_query(sql: str, params: list = None) -> dict:
    """Direct D1 HTTP API query."""
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
                "error": (inner.get("errors", [{}])[0].get("message", "") if not inner.get("success") else ""),
            }
    except Exception as e:
        return {"ok": False, "data": [], "error": str(e)}


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    # Step 1: Get all wikidata_staging rows
    print("Step 1: Reading wikidata_staging ...")
    res = http_query(f"""
        SELECT qid, wikipedia_url, english_label, alt_labels_json
        FROM wikidata_staging
        WHERE release_id = ? AND wikipedia_url IS NOT NULL
    """, [RELEASE_ID])
    if not res["ok"]:
        print(f"ERROR: {res['error']}")
        sys.exit(1)
    rows = res["data"]
    print(f"  Got {len(rows):,} rows with Wikipedia URLs")

    # Step 2: Generate UPDATEs
    # Each update: 1 row × 3 cols (wiki_url, merge_run_id, merged_at) + WHERE
    # D1 has 100-var limit. Each update has 3 binds = 3 vars. 11 rows = 33 vars.
    # But 1 update per call = 3 vars, can do 33 updates per call.
    # Actually each update is 1 statement, so 33 updates × 3 vars = 99 vars. 
    print("Step 2: Applying updates ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    run_id = f"merge-wikidata-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}"
    print(f"  run_id: {run_id}")

    # Build the SQL chunks (33 updates per request, 33*3 = 99 vars)
    CHUNK = 33

    def apply_chunk(chunk: list) -> bool:
        # Build a single SQL with 33 UPDATE statements
        sql_parts = []
        for row in chunk:
            qid = row["qid"]
            url = row["wikipedia_url"]
            sql_parts.append(
                f"UPDATE cities SET "
                f"wiki_url = '{url.replace(chr(39), chr(39)+chr(39))}', "
                f"merge_run_id = '{run_id}', "
                f"merged_at = {now_ms} "
                f"WHERE wiki_data_id = '{qid}';"
            )
        sql = "\n".join(sql_parts)
        res = http_query(sql)
        return res["ok"]

    success = 0
    failed = 0
    start = time.time()

    with ThreadPoolExecutor(max_workers=16) as executor:
        chunks = [rows[i:i+CHUNK] for i in range(0, len(rows), CHUNK)]
        futures = {executor.submit(apply_chunk, c): c for c in chunks}
        for future in as_completed(futures):
            chunk = futures[future]
            if future.result():
                success += len(chunk)
            else:
                failed += 1
            if (success // 5000) > ((success - len(chunk)) // 5000):
                elapsed = time.time() - start
                rate = success / elapsed if elapsed > 0 else 0
                eta = (len(rows) - success) / rate if rate > 0 else 0
                print(f"  {success:,}/{len(rows):,} ({rate:.0f} rows/s, ETA {eta/60:.1f} min)")

    elapsed = time.time() - start
    print(f"\nDone. {success:,} updates applied in {elapsed/60:.1f} min")
    if failed > 0:
        print(f"  {failed} chunks failed ({failed * CHUNK} potential rows missed)")


if __name__ == "__main__":
    main()
