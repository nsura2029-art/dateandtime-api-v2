#!/usr/bin/env python3
"""
scripts/seed/wikidata_props_to_d1.py

M11.2.8: Fetch Wikidata P-code properties (P31, P17, P131, P625, P421)
for the top 5000 cities (by population) that we have in wikidata_staging.

Uses Wikidata SPARQL endpoint with batched VALUES clauses (1000 Q-ids per query).
5 batches × ~10s = ~1 min.

Source: https://query.wikidata.org/sparql
"""
import os
import sys
import re
import json
import time
import urllib.request
import urllib.error
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

WIKIDATA_SPARQL = "https://query.wikidata.org/sparql"
WIKIDATA_USER_AGENT = "dateandtime-api-v2-migration/1.0 (https://github.com/nsura2029-art/dateandtime-api-v2)"

RELEASE_ID = "wikidata-properties-2026-08-03"
BATCH = 500  # Q-ids per SPARQL query (smaller because we have many OPTIONAL clauses)
TOP_N = 5000  # Number of top cities to backfill


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


def get_top_qids(n: int) -> list:
    """Get top N Q-ids by population from wikidata_staging."""
    print(f"  Getting top {n:,} Q-ids by population ...")
    res = http_query(
        "SELECT qid, wikidata_population FROM wikidata_staging "
        "WHERE wikidata_population IS NOT NULL AND wikidata_population > 0 "
        "ORDER BY wikidata_population DESC LIMIT ?",
        [n]
    )
    if not res["ok"]:
        raise RuntimeError(f"Failed to get Q-ids: {res['error']}")
    qids = [r["qid"] for r in res["data"]]
    print(f"  Got {len(qids):,} Q-ids")
    return qids


def sparql_query(qids: list) -> list:
    """Query Wikidata for the given Q-ids. Returns list of bindings."""
    values = " ".join(f"wd:{q}" for q in qids)
    # Use property paths to handle P625 (coord as POINT format)
    query = f"""SELECT ?city ?instance_of ?country ?admin ?coord ?timezone WHERE {{
  VALUES ?city {{ {values} }}
  OPTIONAL {{ ?city wdt:P31 ?instance_of }}
  OPTIONAL {{ ?city wdt:P17 ?country }}
  OPTIONAL {{ ?city wdt:P131 ?admin }}
  OPTIONAL {{ ?city wdt:P625 ?coord }}
  OPTIONAL {{ ?city wdt:P421 ?timezone }}
}}"""
    req = urllib.request.Request(
        WIKIDATA_SPARQL, method="POST",
        headers={
            "Accept": "application/sparql-results+json",
            "Content-Type": "application/sparql-query",
            "User-Agent": WIKIDATA_USER_AGENT,
        },
        data=query.encode("utf-8"),
    )
    for attempt in range(3):
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                raw = r.read()
                text = raw.decode("utf-8", errors="replace")
                text = re.sub(r'[\x00-\x08\x0b-\x0c\x0e-\x1f]', '', text)
                resp = json.loads(text)
                return resp.get("results", {}).get("bindings", [])
        except urllib.error.HTTPError as e:
            if e.code == 429:
                wait = 5 * (attempt + 1)
                print(f"  Rate limited, waiting {wait}s ...")
                time.sleep(wait)
                continue
            elif e.code == 500:
                wait = 3
                print(f"  Server error, retrying in {wait}s ...")
                time.sleep(wait)
                continue
            else:
                raise
    raise RuntimeError(f"Failed after 3 attempts for {len(qids)} Q-ids")


def parse_bindings(bindings: list) -> dict:
    """Parse SPARQL bindings into {qid: {instance_of, country_qid, admin_qid, coord_lat, coord_lon, timezone_qid}}."""
    result = {}
    for b in bindings:
        qid_raw = b.get("city", {}).get("value", "")
        qid = qid_raw.rsplit("/", 1)[-1]
        if not qid:
            continue
        if qid not in result:
            result[qid] = {
                "instance_of": None,
                "country_qid": None,
                "admin_qid": None,
                "coord_lat": None,
                "coord_lon": None,
                "timezone_qid": None,
            }
        if "instance_of" in b:
            result[qid]["instance_of"] = b["instance_of"]["value"].rsplit("/", 1)[-1]
        if "country" in b:
            result[qid]["country_qid"] = b["country"]["value"].rsplit("/", 1)[-1]
        if "admin" in b:
            result[qid]["admin_qid"] = b["admin"]["value"].rsplit("/", 1)[-1]
        if "coord" in b:
            # P625 returns "Point(long lat)" format
            coord_str = b["coord"]["value"]
            m = re.match(r"Point\(([-\d.]+)\s+([-\d.]+)\)", coord_str)
            if m:
                result[qid]["coord_lon"] = float(m.group(1))
                result[qid]["coord_lat"] = float(m.group(2))
        if "timezone" in b:
            result[qid]["timezone_qid"] = b["timezone"]["value"].rsplit("/", 1)[-1]
    return result


def upsert_batch(records: dict, now_ms: int) -> int:
    """Upsert records in chunks. Returns count of successful inserts."""
    if not records:
        return 0
    items = list(records.items())
    # 9 cols × 11 rows = 99 vars (under D1 100-var limit)
    BATCH_ROWS = 11
    success = 0
    for i in range(0, len(items), BATCH_ROWS):
        chunk = items[i:i + BATCH_ROWS]
        placeholders = ",".join(["(?,?,?,?,?,?,?,?,?)"] * len(chunk))
        sql = f"""INSERT OR REPLACE INTO wikidata_properties
  (qid, instance_of, country_qid, admin_qid, coord_lat, coord_lon, timezone_qid, release_id, retrieved_at)
VALUES {placeholders}"""
        params = []
        for qid, d in chunk:
            params.extend([
                qid,
                d["instance_of"],
                d["country_qid"],
                d["admin_qid"],
                d["coord_lat"],
                d["coord_lon"],
                d["timezone_qid"],
                RELEASE_ID,
                now_ms,
            ])
        res = http_query(sql, params)
        if not res["ok"]:
            print(f"    Chunk failed: {res['error'][:200]}")
            return success
        success += len(chunk)
    return success


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Get top N Q-ids by population ...")
    qids = get_top_qids(TOP_N)
    if not qids:
        print("  No Q-ids found!")
        return

    print(f"\nStep 2: Fetch properties from Wikidata SPARQL in {(len(qids) + BATCH - 1) // BATCH} batches ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    total_success = 0
    for i in range(0, len(qids), BATCH):
        batch = qids[i:i + BATCH]
        print(f"  Batch {i // BATCH + 1}: querying {len(batch)} Q-ids ...")
        try:
            bindings = sparql_query(batch)
            parsed = parse_bindings(bindings)
            print(f"    Got {len(parsed):,} results, inserting ...")
            n = upsert_batch(parsed, now_ms)
            total_success += n
            print(f"    Done batch {i // BATCH + 1}. Total: {total_success:,} rows")
        except Exception as e:
            print(f"    Batch failed: {e}")
        # Be nice to Wikidata
        time.sleep(2)

    print(f"\nStep 3: Verify ...")
    res = http_query("SELECT COUNT(*) as n FROM wikidata_properties")
    if res["ok"]:
        print(f"  wikidata_properties: {res['data'][0]['n']:,} rows")
    res = http_query("""
      SELECT
        SUM(CASE WHEN instance_of IS NOT NULL THEN 1 ELSE 0 END) as has_instance,
        SUM(CASE WHEN country_qid IS NOT NULL THEN 1 ELSE 0 END) as has_country,
        SUM(CASE WHEN admin_qid IS NOT NULL THEN 1 ELSE 0 END) as has_admin,
        SUM(CASE WHEN coord_lat IS NOT NULL THEN 1 ELSE 0 END) as has_coord,
        SUM(CASE WHEN timezone_qid IS NOT NULL THEN 1 ELSE 0 END) as has_tz
      FROM wikidata_properties
    """)
    if res["ok"]:
        row = res["data"][0]
        print(f"  Coverage:")
        print(f"    instance_of: {row['has_instance']:,}")
        print(f"    country_qid: {row['has_country']:,}")
        print(f"    admin_qid: {row['has_admin']:,}")
        print(f"    coord_lat/lon: {row['has_coord']:,}")
        print(f"    timezone_qid: {row['has_tz']:,}")


if __name__ == "__main__":
    main()
