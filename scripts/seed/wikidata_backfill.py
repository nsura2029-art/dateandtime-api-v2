#!/usr/bin/env python3
"""
scripts/seed/wikidata_backfill.py

M11.2.7: Backfill missing wikidata_staging entries for 3,618 cities
that have a wiki_data_id but no entry in wikidata_staging.

Strategy:
  1. Get the 3,618 Q-ids from cities where wikidata_staging is missing
  2. Query Wikidata SPARQL in batches of 1000 (4 batches total)
  3. Upsert into wikidata_staging
  4. The M11.2.6 code in the API will then serve wikidata.description

This is faster than the original M11.2 ingestion because:
  - Only 3,618 Q-ids instead of 115K
  - We just need to UPSERT, not insert
  - 4 batches × ~10s = ~1 min
"""
import os
import sys
import re
import time
import json
import urllib.request
import urllib.error
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")
WIKIDATA_SPARQL = "https://query.wikidata.org/sparql"
WIKIDATA_USER_AGENT = "dateandtime-api-v2-migration/1.0 (https://github.com/nsura2029-art/dateandtime-api-v2)"

RELEASE_ID = "wikidata-entities-backfill-2026-08-03"
BATCH = 1000  # Q-ids per SPARQL query
BATCH_ROWS = 11  # rows per INSERT (7 cols × 11 = 77 vars, under D1's 100-var limit)


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


def get_missing_qids() -> list:
    """Get all Q-ids from cities that don't have a wikidata_staging entry."""
    print("  Finding cities with wiki_data_id but no wikidata_staging ...")
    res = http_query("""
      SELECT DISTINCT c.wiki_data_id as qid
      FROM cities c
      LEFT JOIN wikidata_staging w ON w.qid = c.wiki_data_id
      WHERE c.wiki_data_id IS NOT NULL
        AND c.wiki_data_id != ''
        AND w.qid IS NULL
    """)
    if not res["ok"]:
        raise RuntimeError(f"Failed to get Q-ids: {res['error']}")
    qids = [r["qid"] for r in res["data"]]
    print(f"  Found {len(qids):,} Q-ids needing backfill")
    return qids


def sparql_query(qids: list) -> dict:
    """Query Wikidata SPARQL for the given Q-ids.
    Returns: {qid: {english_label, alt_labels, wikipedia_url, wikidata_population}}
    """
    values = " ".join(f"wd:{q}" for q in qids)
    query = f"""SELECT ?city ?cityLabel ?altLabel ?article ?pop WHERE {{
  VALUES ?city {{ {values} }}
  OPTIONAL {{ ?city skos:altLabel ?altLabel FILTER(LANG(?altLabel) = "en") }}
  OPTIONAL {{
    ?article schema:about ?city ; schema:isPartOf <https://en.wikipedia.org/> .
  }}
  OPTIONAL {{ ?city wdt:P1082 ?pop }}
  SERVICE wikibase:label {{ bd:serviceParam wikibase:language "en" }}
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
            if e.code == 429:  # rate limit
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
    raise RuntimeError(f"Failed after 3 attempts")


def parse_bindings(bindings: list) -> dict:
    """Parse SPARQL bindings into {qid: {label, alts, article, pop}}."""
    result = {}  # qid -> {label, alts: [], article, pop}
    for b in bindings:
        qid = b.get("city", {}).get("value", "").rsplit("/", 1)[-1]
        if not qid:
            continue
        if qid not in result:
            result[qid] = {
                "english_label": b.get("cityLabel", {}).get("value", ""),
                "alt_labels": [],
                "wikipedia_url": b.get("article", {}).get("value", ""),
                "wikidata_population": None,
            }
        if "altLabel" in b:
            alts = result[qid]["alt_labels"]
            alt = b["altLabel"]["value"]
            if alt not in alts:
                alts.append(alt)
        if "pop" in b:
            try:
                result[qid]["wikidata_population"] = int(b["pop"]["value"])
            except (ValueError, TypeError):
                pass
    return result


def upsert_batch(parsed: dict, now_ms: int) -> bool:
    """Batch insert/replace wikidata_staging entries (chunks of BATCH_ROWS).
    Returns True if all rows inserted successfully.
    """
    if not parsed:
        return True
    items = list(parsed.items())
    for i in range(0, len(items), BATCH_ROWS):
        chunk = items[i:i + BATCH_ROWS]
        placeholders = ",".join(["(?,?,?,?,?,?,?)"] * len(chunk))
        sql = f"""INSERT OR REPLACE INTO wikidata_staging
  (release_id, qid, english_label, alt_labels_json, wikipedia_url, wikidata_population, retrieved_at)
VALUES {placeholders}"""
        params = []
        for qid, data in chunk:
            params.extend([
                RELEASE_ID,
                qid,
                data.get("english_label", ""),
                json.dumps(data.get("alt_labels", []), ensure_ascii=False),
                data.get("wikipedia_url"),
                data.get("wikidata_population"),
                now_ms,
            ])
        res = http_query(sql, params)
        if not res["ok"]:
            print(f"    Insert chunk failed: {res['error']}")
            return False
    return True


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Get missing Q-ids ...")
    qids = get_missing_qids()
    if not qids:
        print("  No missing Q-ids!")
        return

    print(f"\nStep 2: Fetch from Wikidata SPARQL in {(len(qids) + BATCH - 1) // BATCH} batches ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    success = 0
    failed = 0
    for i in range(0, len(qids), BATCH):
        batch = qids[i:i + BATCH]
        print(f"  Batch {i // BATCH + 1}: querying {len(batch)} Q-ids ...")
        try:
            bindings = sparql_query(batch)
            parsed = parse_bindings(bindings)
            print(f"    Got {len(parsed):,} results, inserting (chunks of {BATCH_ROWS}) ...")
            if upsert_batch(parsed, now_ms):
                success += len(parsed)
                print(f"    Inserted. Total: {success:,} success")
            else:
                failed += len(parsed)
                print(f"    Insert FAILED. Total: {success:,} success, {failed:,} failed")
        except Exception as e:
            print(f"    Batch failed: {e}")
            failed += len(batch)
        # Be nice to Wikidata
        time.sleep(2)

    print(f"\nStep 3: Verify ...")
    res = http_query("""
      SELECT COUNT(*) as n_with_qid, SUM(CASE WHEN w.qid IS NULL THEN 1 ELSE 0 END) as n_no_wiki
      FROM cities c
      LEFT JOIN wikidata_staging w ON w.qid = c.wiki_data_id
      WHERE c.wiki_data_id IS NOT NULL AND c.wiki_data_id != ''
    """)
    if res["ok"]:
        row = res["data"][0]
        print(f"  Cities with wiki_data_id: {row['n_with_qid']:,}")
        print(f"  Without wikidata_staging: {row['n_no_wiki']:,}")


if __name__ == "__main__":
    main()
