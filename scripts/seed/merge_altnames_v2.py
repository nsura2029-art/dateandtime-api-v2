#!/usr/bin/env python3
"""
scripts/seed/merge_altnames_v2.py

M11.1.5 — Re-run the layer merge using GeoNames alternateNamesV2 alt names
(now in D1 alt_names_staging) to find additional historical_alias and
fuzzy matches that the M11.1 merge missed.

The M11.1 merge only used dr5hn's place_names for historical_alias.
GeoNames's own alt names (in alt_names_staging) provide 4,314 more
historic names that we can use.

Strategy:
  1. Read dr5hn's geonames_id assignments from M11.1
  2. For each alt_name in alt_names_staging:
     - Find dr5hn cities whose name matches the alt name
     - Skip the obvious self-match (alt name == city's own canonical name)
     - Tag with historical_alias_v2 (if is_historic=1) or fuzzy_v2
  3. Generate SQL: UPDATE cities SET geonames_id, merge_method, etc.

Usage:
  python3 scripts/seed/merge_altnames_v2.py
"""
import argparse
import hashlib
import json
import os
import subprocess
import sys
import unicodedata
from datetime import datetime, timezone
from pathlib import Path

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")
ALNAMES_REL = "geonames-altnames-2026-08-02"
WORKSPACE = Path("/workspace/dateandtime-api-v2")


def http_query(sql: str, params: list = None) -> dict:
    """Direct D1 HTTP API query."""
    import urllib.request
    import urllib.error
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


def normalize_for_search(s: str) -> str:
    if not s:
        return ""
    s = unicodedata.normalize("NFD", s)
    s = "".join(c for c in s if unicodedata.category(c) != "Mn")
    s = s.lower()
    s = "".join(c for c in s if c.isalnum())
    return s


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    # Step 1: Get all alt names (English/agnostic only) from D1
    print("Step 1: Reading alt names from D1 ...")
    res = http_query(f"""
        SELECT geonameid, alternate_name, is_historic
        FROM alt_names_staging
        WHERE isolanguage IN ('', 'en') AND is_historic = 1
          AND release_id = ?
    """, [ALNAMES_REL])
    if not res["ok"]:
        print(f"ERROR: {res['error']}")
        sys.exit(1)
    alt_names = res["data"]
    print(f"  Loaded {len(alt_names):,} historic alt names from D1")

    # Step 2: Get dr5hn cities (id, name, geonames_id) — only those with wiki_data_id
    print("Step 2: Reading dr5hn cities with geonames_id ...")
    res = http_query("""
        SELECT id, name, ascii_name, geonames_id, wiki_data_id
        FROM cities
        WHERE geonames_id IS NOT NULL
    """)
    if not res["ok"]:
        print(f"ERROR: {res['error']}")
        sys.exit(1)
    dr5hn_cities = res["data"]
    print(f"  Loaded {len(dr5hn_cities):,} dr5hn cities with geonames_id")

    # Build indexes
    # geonameid -> dr5hn city id
    gid_to_dr5hn = {}
    # normalized name -> [dr5hn id, ...]
    name_to_dr5hn = {}
    for row in dr5hn_cities:
        cid = row["id"]
        gid = row["geonames_id"]
        if gid:
            gid_to_dr5hn[gid] = cid
        for n in (row.get("name"), row.get("ascii_name")):
            if n:
                norm = normalize_for_search(n)
                if norm:
                    name_to_dr5hn.setdefault(norm, []).append(cid)

    print(f"  {len(gid_to_dr5hn):,} geonameid -> dr5hn mappings")
    print(f"  {len(name_to_dr5hn):,} unique normalized names in dr5hn")

    # Step 3: Find new matches via alt names
    print("Step 3: Finding new matches via alt names ...")
    seen = set()
    matches = []  # (dr5hn_cid, alt_geonameid, alt_name, method)
    for alt in alt_names:
        alt_norm = normalize_for_search(alt["alternate_name"])
        if not alt_norm:
            continue
        candidates = name_to_dr5hn.get(alt_norm, [])
        for cid in candidates:
            pair = (cid, alt["geonameid"])
            if pair in seen:
                continue
            seen.add(pair)
            # Skip if this is the self-match (the alt name points to the
            # same city that already has this geonames_id)
            if gid_to_dr5hn.get(alt["geonameid"]) == cid:
                continue
            # Found a new match!
            method = "historical_alias_v2" if alt["is_historic"] else "fuzzy_v2"
            matches.append((cid, alt["geonameid"], alt["alternate_name"], method))

    print(f"  Found {len(matches):,} new matches")

    # Step 4: Generate SQL
    print("Step 4: Generating SQL ...")
    run_id = f"merge-altnames-v2-{datetime.now(timezone.utc).strftime('%Y%m%d-%H%M%S')}"
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)

    sql_lines = [
        "-- M11.1.5 alt_names merge",
        f"-- run_id: {run_id}",
        f"-- matches: {len(matches):,}",
        f"-- generated: {datetime.now(timezone.utc).isoformat()}",
        "",
        "BEGIN TRANSACTION;",
        "",
    ]
    for cid, gid, alt_name, method in matches:
        # Only update if this city doesn't already have a more authoritative match
        # (we don't want to overwrite a 'exact' match with a 'historical_alias_v2')
        sql_lines.append(
            f"UPDATE cities SET "
            f"geonames_id = {gid}, "
            f"source_merged_with = 'geonames', "
            f"merge_method = '{method}', "
            f"merge_run_id = '{run_id}', "
            f"merged_at = {now_ms} "
            f"WHERE id = {cid} AND merge_method NOT IN ('exact', 'geonames_only');"
        )
    sql_lines.extend(["", "COMMIT;", ""])
    sql = "\n".join(sql_lines)

    timestamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
    h = hashlib.sha1(sql.encode()).hexdigest()[:8]
    out_path = WORKSPACE / "tmp" / f"merge_altnames_v2-{timestamp}-{h}.sql"
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(sql)
    print(f"\nWrote {len(sql):,} bytes to {out_path}")

    # Summary by method
    by_method = {}
    for cid, gid, alt_name, method in matches:
        by_method[method] = by_method.get(method, 0) + 1
    print("By method:")
    for method, count in sorted(by_method.items()):
        print(f"  {method}: {count:,}")

    print(f"\nNext: npx wrangler d1 execute timeandtimepro-full-v2 --env dev --remote --file {out_path}")


if __name__ == "__main__":
    main()
