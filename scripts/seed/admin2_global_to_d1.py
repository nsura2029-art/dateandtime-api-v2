#!/usr/bin/env python3
"""
scripts/seed/admin2_global_to_d1.py

M12: Load GeoNames admin-2 codes (47K rows) + map cities → admin-2.

Approach:
1. Parse admin2Codes.txt → load into administrative_regions with level=2
2. For each city, find its admin-2 via the GeoNames cities1000.txt dump
   - cities1000.txt has admin2 column (the GeoNames admin-2 code)
   - We look up that code in admin2Codes.txt to get the geonameId
   - We match that geonameId in administrative_regions
3. Update cities.admin2_id

Output: bulk SQL for `wrangler d1 execute --file=`
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


def parse_admin2_file(path: str) -> list:
    """Parse admin2Codes.txt. Format: code\\tname\\tascii_name\\tgeonameId
    code = CC.A1.A2 (e.g. US.12.101)
    """
    records = []
    with open(path) as f:
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 4:
                continue
            code = parts[0]
            cc_parts = code.split(".")
            if len(cc_parts) != 3:
                continue
            records.append({
                "code": code,
                "cca2": cc_parts[0],
                "admin1_code": cc_parts[1],
                "admin2_code": cc_parts[2],
                "name": parts[1],
                "ascii_name": parts[2] or parts[1],
                "geonameId": int(parts[3]),
            })
    return records


def parse_cities1000_admin2(path: str) -> dict:
    """Parse cities1000.txt. Return {geonameId: {cca2, admin1_code, admin2_code}}"""
    out = {}
    with open(path) as f:
        for line in f:
            parts = line.rstrip("\n").split("\t")
            if len(parts) < 12:
                continue
            try:
                geonameId = int(parts[0])
            except ValueError:
                continue
            admin2 = parts[11]
            if not admin2:
                continue
            out[geonameId] = {
                "cca2": parts[8],
                "admin1_code": parts[10],
                "admin2_code": admin2,
            }
    return out


def get_country_map() -> dict:
    res = http_query("SELECT id, cca2 FROM countries")
    if not res["ok"]:
        raise RuntimeError(f"Failed: {res['error']}")
    return {r["cca2"]: r["id"] for r in res["data"]}


def get_geonameid_to_city() -> dict:
    """Get {geonames_id: city_id} for our cities."""
    res = http_query("SELECT id, geonames_id FROM cities WHERE geonames_id IS NOT NULL")
    if not res["ok"]:
        raise RuntimeError(f"Failed: {res['error']}")
    return {r["geonames_id"]: r["id"] for r in res["data"] if r["geonames_id"]}


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Parse admin2Codes.txt ...")
    admin2_records = parse_admin2_file("tmp/admin2Codes.txt")
    print(f"  {len(admin2_records):,} admin-2 records parsed")

    print("\nStep 2: Build (cca2, admin1_code, admin2_code) → geonameId map ...")
    admin2_by_code = {}
    for r in admin2_records:
        key = (r["cca2"], r["admin1_code"], r["admin2_code"])
        admin2_by_code[key] = r["geonameId"]
    print(f"  {len(admin2_by_code):,} unique (cca2, a1, a2) codes")

    print("\nStep 3: Get country map ...")
    country_map = get_country_map()
    print(f"  {len(country_map):,} countries")

    print("\nStep 4: Build admin-2 INSERT SQL (no parent_id for now) ...")
    rows = []
    for r in admin2_records:
        country_id = country_map.get(r["cca2"])
        if not country_id:
            continue
        name = r["name"].replace("'", "''")
        ascii_name = r["ascii_name"].replace("'", "''")
        rows.append(
            f"({country_id}, NULL, '{r['code']}', '{name}', '{ascii_name}', 'admin2', 2, {r['geonameId']})"
        )
    print(f"  {len(rows):,} rows to insert")

    BATCH = 12  # 8 cols × 12 = 96 vars (under 100)
    sql_path = "tmp/admin2_insert.sql"
    os.makedirs("tmp", exist_ok=True)
    with open(sql_path, "w") as f:
        f.write("DELETE FROM administrative_regions WHERE level = 2;\n")
        for i in range(0, len(rows), BATCH):
            chunk = rows[i:i + BATCH]
            f.write(f"INSERT OR REPLACE INTO administrative_regions "
                    f"(country_id, parent_id, code, name, ascii_name, type, level, geoname_id) "
                    f"VALUES {','.join(chunk)};\n")
    print(f"  Wrote {sql_path} ({len(rows):,} rows)")

    print("\nStep 5: Parse cities1000.txt for admin-2 codes ...")
    cities_admin2 = parse_cities1000_admin2("tmp/cities1000.txt")
    print(f"  {len(cities_admin2):,} cities with admin-2 in GeoNames dump")

    print("\nStep 6: Match our cities to admin-2 geonameId ...")
    geonameid_to_city = get_geonameid_to_city()
    print(f"  {len(geonameid_to_city):,} of our cities have geonames_id")

    city_admin2_id = {}  # city_id → admin2 geonameId
    for geoid, info in cities_admin2.items():
        city_id = geonameid_to_city.get(geoid)
        if not city_id:
            continue
        key = (info["cca2"], info["admin1_code"], info["admin2_code"])
        admin2_geonameId = admin2_by_code.get(key)
        if admin2_geonameId:
            city_admin2_id[city_id] = admin2_geonameId
    print(f"  {len(city_admin2_id):,} cities matched to admin-2")

    print("\nStep 7: Build cities UPDATE SQL (will run after admin-2 inserted) ...")
    # We need to update cities.admin2_id = (SELECT id FROM administrative_regions WHERE geoname_id = ?)
    # But D1 doesn't allow correlated updates easily. Better: do a temp table or use subquery.
    # Use a temp table approach: INSERT INTO admin2_city_map, then UPDATE FROM.
    # Or: do it client-side with direct admin2_id values
    # Simpler: write UPDATE statements that set admin2_id to a specific value
    # We need admin2_id (PK of administrative_regions), not geoname_id
    # So we need to: get all admin-2 geoname_id → id, then write UPDATE

    # For now, just write the mapping data so we can use it after admin-2 loads
    update_path = "tmp/admin2_city_updates.json"
    with open(update_path, "w") as f:
        # city_id → admin2 geonameId (we'll resolve to id after admin-2 load)
        json.dump({str(k): v for k, v in city_admin2_id.items()}, f)
    print(f"  Wrote {update_path} ({len(city_admin2_id):,} entries)")

    print("\n=== NEXT STEPS ===")
    print("  1. Run: npx wrangler d1 execute timeandtimepro-full-v2 --file=tmp/admin2_insert.sql --env dev --remote")
    print("  2. Then run: python3 scripts/seed/admin2_map_cities.py")


if __name__ == "__main__":
    main()
