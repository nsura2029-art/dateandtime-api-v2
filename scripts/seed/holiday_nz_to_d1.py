#!/usr/bin/env python3
"""
scripts/seed/holiday_nz_to_d1.py

Load NZ holidays from Nager.Date for 2026 and 2027.
Uses the same approach as holiday_nl_us_to_d1.py but simpler (no country_filter_policy needed for MVP).
"""
import os
import sys
import time
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


def fetch_json(url: str) -> list:
    req = urllib.request.Request(url, headers={"User-Agent": "dateandtime-api-v2-holidays/1.0"})
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())


def get_or_create_concept(name_en: str, name_local: str = None, tradition: str = None, release_id: str = None) -> int:
    r = http_query("SELECT id FROM holiday_concept WHERE name_en = ? LIMIT 1", [name_en])
    if r["ok"] and r["data"]:
        return r["data"][0]["id"]
    r = http_query(
        "INSERT INTO holiday_concept (name_en, name_local, tradition, release_id, created_at) VALUES (?, ?, ?, ?, ?) RETURNING id",
        [name_en, name_local, tradition, release_id, int(time.time() * 1000)]
    )
    if not r["ok"]:
        raise RuntimeError(f"Failed to insert concept: {r['error']}")
    return r["data"][0]["id"]


NAGER_TYPE_TO_FILTERS = {
    "Public": ["PUBLIC_NATIONAL"],
    "Bank": ["BANK_CLOSURE"],
    "School": ["SCHOOL_HOLIDAY"],
    "Authorities": ["GOVERNMENT_CLOSURE"],
    "Optional": ["OPTIONAL_HOLIDAY"],
    "Observance": ["OBS_IMPORTANT", "OBS_COMMON"],
}


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    # Get NZ country_id
    r = http_query("SELECT id FROM countries WHERE cca2 = 'NZ'")
    if not r["ok"] or not r["data"]:
        print("ERROR: NZ not in countries table")
        sys.exit(1)
    country_id = r["data"][0]["id"]
    print(f"NZ country_id: {country_id}")

    total = 0
    for year in [2026, 2027]:
        print(f"\nFetching NZ {year} from Nager.Date ...")
        url = f"https://date.nager.at/api/v3/PublicHolidays/{year}/NZ"
        data = fetch_json(url)
        print(f"  Got {len(data)} holidays")
        for h in data:
            concept_name = h.get("name", "").strip()
            if not concept_name:
                continue
            local_name = h.get("localName", "").strip()
            types = h.get("types", ["Public"])
            global_ = h.get("global", True)
            counties = h.get("counties")
            tradition = None
            if any(kw in concept_name for kw in ["Christmas", "Easter", "Anzac"]):
                tradition = "christian" if "Christmas" in concept_name or "Easter" in concept_name else None
            concept_id = get_or_create_concept(concept_name, name_local=local_name, tradition=tradition, release_id=f"nager-date-nz-{year}")
            if counties:
                for subdiv in counties:
                    r = http_query(
                        """INSERT INTO holiday_occurrence
                           (concept_id, country_id, subdivision_code, start_date, end_date, date_role, legal_status, scope_level, event_domain, date_status, release_id, created_at, updated_at)
                           VALUES (?, ?, ?, ?, ?, 'actual', 'public', 'subdivision', 'civil', 'confirmed', ?, ?, ?) RETURNING id""",
                        [concept_id, country_id, subdiv, h["date"], h["date"], f"nager-date-nz-{year}", int(time.time() * 1000), int(time.time() * 1000)]
                    )
                    if not r["ok"]:
                        continue
                    occ_id = r["data"][0]["id"]
                    filters = NAGER_TYPE_TO_FILTERS.get(t, ["PUBLIC_NATIONAL"]) if (t := types[0] if types else "Public") else ["PUBLIC_NATIONAL"]
                    if "PUBLIC_NATIONAL" in filters and not global_:
                        filters.remove("PUBLIC_NATIONAL")
                        filters.append("PUBLIC_LOCAL")
                    for f in filters:
                        http_query("INSERT OR IGNORE INTO holiday_occurrence_filter (occurrence_id, filter_code) VALUES (?, ?)", [occ_id, f])
                    http_query(
                        "INSERT OR REPLACE INTO holiday_occurrence_source (occurrence_id, source_key, assertion_role, freshness, raw_payload) VALUES (?, ?, 'asserted', ?, ?)",
                        [occ_id, "nager_date", int(time.time() * 1000), json.dumps(h)]
                    )
                    total += 1
            else:
                r = http_query(
                    """INSERT INTO holiday_occurrence
                       (concept_id, country_id, subdivision_code, start_date, end_date, date_role, legal_status, scope_level, event_domain, date_status, release_id, created_at, updated_at)
                       VALUES (?, ?, NULL, ?, ?, 'actual', 'public', 'country', 'civil', 'confirmed', ?, ?, ?) RETURNING id""",
                    [concept_id, country_id, h["date"], h["date"], f"nager-date-nz-{year}", int(time.time() * 1000), int(time.time() * 1000)]
                )
                if not r["ok"]:
                    continue
                occ_id = r["data"][0]["id"]
                t = types[0] if types else "Public"
                filters = NAGER_TYPE_TO_FILTERS.get(t, ["PUBLIC_NATIONAL"])
                for f in filters:
                    http_query("INSERT OR IGNORE INTO holiday_occurrence_filter (occurrence_id, filter_code) VALUES (?, ?)", [occ_id, f])
                http_query(
                    "INSERT OR REPLACE INTO holiday_occurrence_source (occurrence_id, source_key, assertion_role, freshness, raw_payload) VALUES (?, ?, 'asserted', ?, ?)",
                    [occ_id, "nager_date", int(time.time() * 1000), json.dumps(h)]
                )
                total += 1

    print(f"\nTotal loaded: {total} NZ holiday occurrences")
    r = http_query("SELECT COUNT(*) as n FROM holiday_occurrence WHERE country_id = ?", [country_id])
    if r["ok"]:
        print(f"  NZ total in DB: {r['data'][0]['n']}")


if __name__ == "__main__":
    main()
