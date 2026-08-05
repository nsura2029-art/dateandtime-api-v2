#!/usr/bin/env python3
"""
scripts/seed/admin2_map_cities.py

M12 Step 2: After admin-2 regions are loaded, update cities.admin2_id
by resolving the geonameId mapping.
"""
import os
import sys
import json
import urllib.request

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")
HEADERS = {"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"}


def http_query(sql: str, params: list = None) -> dict:
    body = {"sql": sql}
    if params:
        body["params"] = params
    payload = json.dumps(body).encode()
    req = urllib.request.Request(
        f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT}/d1/database/{DB_ID}/query",
        data=payload, method="POST",
        headers=HEADERS,
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


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    # Load city → admin2 geonameId mapping
    with open("tmp/admin2_city_updates.json") as f:
        city_admin2 = json.load(f)  # {city_id_str: geonameId}
    print(f"Loaded {len(city_admin2):,} city → admin-2 mappings")

    # Get all admin-2 records: {geonameId: id}
    print("Fetching admin-2 geonameId → id mapping ...")
    res = http_query("SELECT id, geoname_id FROM administrative_regions WHERE level = 2 AND geoname_id IS NOT NULL")
    if not res["ok"]:
        print(f"ERROR: {res['error']}")
        return
    admin2_id = {r["geoname_id"]: r["id"] for r in res["data"]}
    print(f"  {len(admin2_id):,} admin-2 regions in DB")

    # Build city_id → admin2_id mapping
    updates = []
    unmapped = 0
    for city_id_str, geonameId in city_admin2.items():
        city_id = int(city_id_str)
        a2_id = admin2_id.get(geonameId)
        if a2_id:
            updates.append((city_id, a2_id))
        else:
            unmapped += 1
    print(f"  {len(updates):,} updates, {unmapped:,} unmapped")

    # Build UPDATE SQL using CASE WHEN for efficiency
    # D1 has 100-var limit. UPDATE ... SET admin2_id = CASE id WHEN ... END WHERE id IN (..., ..., ...)
    # 2 vars per case + 1 var for IN list. For 50 updates: 1 + 50 = 51 vars. Under limit.
    # Actually CASE WHEN with values not params: it's literal SQL, not prepared statement
    BATCH = 100  # 100 UPDATEs per case-batch is fine since it's literal SQL
    sql_path = "tmp/admin2_city_update.sql"
    os.makedirs("tmp", exist_ok=True)
    with open(sql_path, "w") as f:
        for i in range(0, len(updates), BATCH):
            chunk = updates[i:i + BATCH]
            case_lines = "\n    ".join(
                f"WHEN {cid} THEN {a2id}"
                for cid, a2id in chunk
            )
            in_list = ",".join(str(cid) for cid, _ in chunk)
            f.write(f"UPDATE cities SET admin2_id = CASE id\n    {case_lines}\n  END WHERE id IN ({in_list});\n")
    print(f"  Wrote {sql_path} ({len(updates):,} updates in {len(updates)//BATCH + 1} batches)")

    print(f"\n=== NEXT STEPS ===")
    print(f"  Run: npx wrangler d1 execute timeandtimepro-full-v2 --file={sql_path} --env dev --remote")


if __name__ == "__main__":
    main()
