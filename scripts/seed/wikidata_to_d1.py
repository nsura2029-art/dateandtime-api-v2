#!/usr/bin/env python3
"""
scripts/seed/wikidata_to_d1.py

M11.2: Ingest Wikidata for our 148,331 cities (those with a wiki_data_id
in the cities table).

For each batch of 5K Q-ids, query the Wikidata Query Service SPARQL
endpoint and store the response in D1 wikidata_staging.

What we get per city:
  - English label (canonical name)
  - Alt labels (skos:altLabel) — additional alternate names
  - Wikipedia URL (en.wikipedia.org)
  - Population (P1082) — alternative to dr5hn's

Source: https://query.wikidata.org/sparql (CC0)
Batch size: 5,000 Q-ids per request (under SPARQL query size limit)
Rate limit: ~5 req/sec (Wikidata's User-Agent-based throttling)

Usage:
  python3 scripts/seed/wikidata_to_d1.py fetch   # download all
  python3 scripts/seed/wikidata_to_d1.py load    # load to D1
  python3 scripts/seed/wikidata_to_d1.py register
"""
import argparse
import json
import os
import sys
import time
import urllib.request
import urllib.error
import urllib.parse
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

# Cloudflare D1 HTTP API
ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

# Wikidata Query Service
WIKIDATA_SPARQL = "https://query.wikidata.org/sparql"
WIKIDATA_USER_AGENT = "dateandtime-api-v2-migration/1.0 (https://github.com/nsura2029-art/dateandtime-api-v2)"

WORKSPACE = Path("/workspace/dateandtime-api-v2")
LOCAL_CACHE = WORKSPACE / "tmp" / "wikidata_cache.jsonl"
RELEASE_ID = f"wikidata-entities-{datetime.now(timezone.utc).strftime('%Y-%m-%d')}"
BATCH = 1000  # Q-ids per SPARQL query
WORKERS = 1   # parallel SPARQL queries (Wikidata throttles aggressively)

if not TOKEN:
    print("ERROR: CLOUDFLARE_API_TOKEN env var not set")
    sys.exit(1)


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
            err = ""
            if not inner.get("success"):
                errs = inner.get("errors", [])
                if errs:
                    err = errs[0].get("message", "")
            return {
                "ok": resp.get("success") and inner.get("success", False),
                "data": inner.get("results", []),
                "error": err,
            }
    except Exception as e:
        return {"ok": False, "data": [], "error": str(e)}


def sparql_query(qids: list) -> list:
    """Query Wikidata SPARQL for the given Q-ids. Returns list of bindings.
    Uses POST because GET has a URI length limit (414 errors at 5K Q-ids).
    """
    # Build VALUES clause
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
                # Sometimes Wikidata returns JSON with embedded control chars
                # in literal values (e.g. \u0001). json.loads handles these
                # if strict=False, but we can also strip them.
                text = raw.decode("utf-8", errors="replace")
                # Strip control chars that aren't valid in JSON strings
                # (keep \t, \n, \r which are allowed)
                import re
                text = re.sub(r'[\x00-\x08\x0b-\x0c\x0e-\x1f]', '', text)
                resp = json.loads(text)
                return resp.get("results", {}).get("bindings", [])
        except urllib.error.HTTPError as e:
            if e.code == 429 and attempt < 2:
                # Rate-limited, wait and retry
                wait = 2 ** attempt * 5
                print(f"  Rate limited (429), waiting {wait}s ...")
                time.sleep(wait)
                continue
            body = e.read().decode("utf-8", errors="replace")[:500]
            print(f"  SPARQL error {e.code}: {body}")
            return []
        except json.JSONDecodeError as e:
            if attempt < 2:
                wait = 2 ** attempt * 3
                print(f"  JSON parse error, retrying in {wait}s ...")
                time.sleep(wait)
                continue
            print(f"  JSON parse error after {attempt+1} attempts: {e}")
            return []
        except Exception as e:
            print(f"  SPARQL exception: {e}")
            return []
    return []


def get_qids() -> list:
    """Read all wiki_data_id values from cities table."""
    print("Reading wiki_data_id from D1 cities table ...")
    res = http_query("""
        SELECT DISTINCT wiki_data_id
        FROM cities
        WHERE wiki_data_id IS NOT NULL
          AND wiki_data_id != ''
          AND wiki_data_id LIKE 'Q%'
    """)
    if not res["ok"]:
        print(f"ERROR: {res['error']}")
        sys.exit(1)
    qids = [r["wiki_data_id"] for r in res["data"]]
    print(f"  Got {len(qids):,} Q-ids")
    return qids


def fetch_all(qids: list) -> dict:
    """
    Fetch all Q-ids from Wikidata in parallel batches.
    Returns: {qid: {english_label, alt_labels, wikipedia_url, wikidata_population}}
    """
    # Build batches
    batches = []
    for i in range(0, len(qids), BATCH):
        batches.append(qids[i:i + BATCH])
    print(f"Total batches: {len(batches)} of {BATCH} Q-ids each")

    # Process in parallel
    results = {}  # qid -> {label, alts, article, pop}
    errors = []
    start = time.time()

    with ThreadPoolExecutor(max_workers=WORKERS) as executor:
        futures = {executor.submit(sparql_query, batch): i for i, batch in enumerate(batches)}
        for future in as_completed(futures):
            i = futures[future]
            bindings = future.result()
            for b in bindings:
                qid = b.get("city", {}).get("value", "").rsplit("/", 1)[-1]
                if not qid.startswith("Q"):
                    continue
                entry = results.setdefault(qid, {
                    "english_label": None,
                    "alt_labels": [],
                    "wikipedia_url": None,
                    "wikidata_population": None,
                })
                # Each binding can have 0-1 of each OPTIONAL field
                if "cityLabel" in b:
                    entry["english_label"] = b["cityLabel"]["value"]
                if "altLabel" in b and b["altLabel"]["value"] not in entry["alt_labels"]:
                    entry["alt_labels"].append(b["altLabel"]["value"])
                if "article" in b and entry["wikipedia_url"] is None:
                    entry["wikipedia_url"] = b["article"]["value"]
                if "pop" in b and entry["wikidata_population"] is None:
                    try:
                        entry["wikidata_population"] = int(float(b["pop"]["value"]))
                    except (ValueError, TypeError):
                        pass
            if (i + 1) % 5 == 0 or i == 0:
                elapsed = time.time() - start
                rate = (i + 1) / elapsed if elapsed > 0 else 0
                eta = (len(batches) - i - 1) / rate if rate > 0 else 0
                print(f"  {i+1}/{len(batches)} batches ({rate:.1f}/s, ETA {eta/60:.1f} min)")

    elapsed = time.time() - start
    print(f"\nDone. {len(results):,} cities fetched in {elapsed/60:.1f} min")
    return results


def save_cache(results: dict) -> None:
    """Save results to a JSONL file for replay-ability."""
    LOCAL_CACHE.parent.mkdir(parents=True, exist_ok=True)
    with open(LOCAL_CACHE, "w", encoding="utf-8") as f:
        for qid, data in results.items():
            f.write(json.dumps({"qid": qid, **data}) + "\n")
    print(f"Saved {len(results):,} entries to {LOCAL_CACHE}")


def load_to_d1(results: dict) -> None:
    """Load results to D1 wikidata_staging using the parallel HTTP API."""
    print("Loading to D1 ...")
    # Build SQL batches (11 rows per batch, 9 cols = 99 params, under 100-var limit)
    BATCH_ROWS = 11
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)

    items = list(results.items())
    print(f"  Total: {len(items):,} rows")

    success = 0
    failed = 0
    start = time.time()

    def insert_batch(chunk: list) -> bool:
        placeholders = ",".join(["(?,?,?,?,?,?,?)"] * len(chunk))
        sql = f"""INSERT OR REPLACE INTO wikidata_staging
  (release_id, qid, english_label, alt_labels_json, wikipedia_url, wikidata_population, retrieved_at)
VALUES {placeholders}"""
        params = []
        for qid, data in chunk:
            params.extend([
                RELEASE_ID,
                qid,
                data.get("english_label"),
                json.dumps(data.get("alt_labels", []), ensure_ascii=False),
                data.get("wikipedia_url"),
                data.get("wikidata_population"),
                now_ms,
            ])
        res = http_query(sql, params)
        return res["ok"]

    with ThreadPoolExecutor(max_workers=16) as executor:
        batches = [items[i:i+BATCH_ROWS] for i in range(0, len(items), BATCH_ROWS)]
        futures = {executor.submit(insert_batch, b): i for i, b in enumerate(batches)}
        for future in as_completed(futures):
            if future.result():
                success += len(futures[future]) * BATCH_ROWS
            else:
                failed += 1
            if (success + failed) % 5000 < BATCH_ROWS * WORKERS:
                elapsed = time.time() - start
                rate = (success + failed * BATCH_ROWS) / elapsed if elapsed > 0 else 0
                eta = (len(items) - success) / rate if rate > 0 else 0
                print(f"  {success:,}/{len(items):,} ({rate:.0f} rows/s, ETA {eta/60:.1f} min)")

    elapsed = time.time() - start
    print(f"\nDone. {success:,} rows loaded in {elapsed/60:.1f} min ({success/elapsed:.0f} rows/s)")
    if failed > 0:
        print(f"  {failed} batches failed")


def register_release() -> None:
    """Register the release in D1 source_releases."""
    import subprocess
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    size = LOCAL_CACHE.stat().st_size if LOCAL_CACHE.exists() else 0
    sql = f"""INSERT OR REPLACE INTO source_releases
  (release_id, source_key, release_date, discovered_at, status,
   raw_sha256, raw_size_bytes, raw_r2_key, manifest_r2_key, started_at)
VALUES
  ('{RELEASE_ID}', 'wikidata', '{today}',
   {int(datetime.now(timezone.utc).timestamp() * 1000)}, 'raw-stored',
   '', {size}, '', '',
   {int(datetime.now(timezone.utc).timestamp() * 1000)});
"""
    sql_path = WORKSPACE / "tmp" / "register_wikidata_release.sql"
    sql_path.parent.mkdir(parents=True, exist_ok=True)
    sql_path.write_text(sql)
    print(f"Release: {RELEASE_ID}")
    print(f"SQL written to: {sql_path}")
    print()
    print("Run: npx wrangler d1 execute timeandtimepro-full-v2 --env dev --remote --file " + str(sql_path))


def main():
    parser = argparse.ArgumentParser(description="Wikidata ingestion")
    parser.add_argument("step", choices=["qids", "fetch", "load", "register"], help="Pipeline step")
    args = parser.parse_args()

    if args.step == "qids":
        qids = get_qids()
        print(f"  Total Q-ids: {len(qids)}")
        # Save to file
        out = WORKSPACE / "tmp" / "wikidata_qids.txt"
        out.write_text("\n".join(qids))
        print(f"  Saved to {out}")
    elif args.step == "fetch":
        qids = get_qids()
        results = fetch_all(qids)
        save_cache(results)
    elif args.step == "load":
        # Load from cache file
        if not LOCAL_CACHE.exists():
            print(f"ERROR: {LOCAL_CACHE} not found. Run 'fetch' first.")
            sys.exit(1)
        results = {}
        with open(LOCAL_CACHE, encoding="utf-8") as f:
            for line in f:
                d = json.loads(line)
                qid = d.pop("qid")
                results[qid] = d
        print(f"Loaded {len(results):,} entries from cache")
        load_to_d1(results)
    elif args.step == "register":
        register_release()


if __name__ == "__main__":
    main()
