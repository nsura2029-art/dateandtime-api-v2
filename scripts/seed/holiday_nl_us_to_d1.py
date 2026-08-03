#!/usr/bin/env python3
"""
scripts/seed/holiday_nl_us_to_d1.py

M13 MVP: Fetch NL + US holidays for 2026-2027 from OpenHolidays + Nager.Date
and load into the holidays DB.

Sources:
- NL: OpenHolidays API (Open Database License, free)
- US: Nager.Date (free, MIT-style)

Output: bulk SQL for `wrangler d1 execute --file=`
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


def fetch_json(url: str, headers: dict = None) -> list:
    h = {"User-Agent": "dateandtime-api-v2-holidays/1.0"}
    if headers:
        h.update(headers)
    req = urllib.request.Request(url, headers=h)
    with urllib.request.urlopen(req, timeout=60) as r:
        return json.loads(r.read().decode())


def get_country_id(cca2: str) -> int:
    r = http_query("SELECT id FROM countries WHERE cca2 = ?", [cca2])
    if not r["ok"] or not r["data"]:
        raise RuntimeError(f"Country {cca2} not found")
    return r["data"][0]["id"]


def get_or_create_concept(name_en: str, name_local: str = None, tradition: str = None, release_id: str = None) -> int:
    """Get or insert a concept. Returns the concept_id."""
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


# Nager.Date type → our filter codes
NAGER_TYPE_TO_FILTERS = {
    "Public": ["PUBLIC_NATIONAL"],
    "Bank": ["BANK_CLOSURE"],
    "School": ["SCHOOL_HOLIDAY"],
    "Authorities": ["GOVERNMENT_CLOSURE"],
    "Optional": ["OPTIONAL_HOLIDAY"],
    "Observance": ["OBS_IMPORTANT", "OBS_COMMON"],
}


def nager_to_filters(types: list, global_: bool) -> list:
    """Map Nager.Date types to our filter codes."""
    filters = set()
    for t in types:
        for f in NAGER_TYPE_TO_FILTERS.get(t, []):
            filters.add(f)
    # If global=false (state/local), swap PUBLIC_NATIONAL → PUBLIC_LOCAL
    if "PUBLIC_NATIONAL" in filters and not global_:
        filters.discard("PUBLIC_NATIONAL")
        filters.add("PUBLIC_LOCAL")
    return list(filters)


# OpenHolidays type mapping (NL mostly)
OPENHOLIDAYS_TYPE_TO_FILTERS = {
    "Public": ["PUBLIC_NATIONAL"],
    "School": ["SCHOOL_HOLIDAY"],
    "Bank": ["BANK_CLOSURE"],
    "Authorities": ["GOVERNMENT_CLOSURE"],
    "Optional": ["OPTIONAL_HOLIDAY"],
    "Observance": ["OBS_IMPORTANT"],
}


def load_nl(year: int) -> int:
    """Load NL public holidays from OpenHolidays. Returns count loaded."""
    print(f"  Fetching NL {year} from OpenHolidays ...")
    url = f"https://openholidaysapi.org/PublicHolidays?countryIsoCode=NL&validFrom={year}-01-01&validTo={year}-12-31&languageIsoCode=en"
    data = fetch_json(url)
    print(f"    Got {len(data)} holidays")
    country_id = get_country_id("NL")
    loaded = 0
    for h in data:
        concept_name = next((n["text"] for n in h.get("name", []) if n.get("language") == "EN"), None)
        if not concept_name:
            continue
        # Map OpenHolidays type to legal_status
        h_type = h.get("type", "Public")
        legal_status = "public" if h_type == "Public" else "de_facto" if h_type == "Observance" else "optional"
        # Concept (shared)
        tradition = None
        if any(kw in concept_name for kw in ["Easter", "Pentecost", "Christmas", "Ascension", "Good Friday"]):
            tradition = "christian"
        concept_id = get_or_create_concept(concept_name, tradition=tradition, release_id="openholidays-nl-2026")
        # Occurrence
        start = h["startDate"]
        end = h.get("endDate") or start
        nationwide = h.get("nationwide", True)
        scope = "country" if nationwide else "subdivision"
        # Filters
        filters = OPENHOLIDAYS_TYPE_TO_FILTERS.get(h_type, ["PUBLIC_NATIONAL"])
        # Insert occurrence
        r = http_query(
            """INSERT INTO holiday_occurrence
               (concept_id, country_id, subdivision_code, start_date, end_date, date_role, legal_status, scope_level, event_domain, date_status, release_id, created_at, updated_at)
               VALUES (?, ?, NULL, ?, ?, 'actual', ?, ?, 'civil', 'confirmed', ?, ?, ?) RETURNING id""",
            [concept_id, country_id, start, end, legal_status, scope, "openholidays-nl-2026", int(time.time() * 1000), int(time.time() * 1000)]
        )
        if not r["ok"]:
            print(f"    Insert failed: {r['error'][:100]}")
            continue
        occ_id = r["data"][0]["id"]
        # Filters
        for f in filters:
            http_query("INSERT OR IGNORE INTO holiday_occurrence_filter (occurrence_id, filter_code) VALUES (?, ?)", [occ_id, f])
        # Source attribution
        http_query(
            "INSERT OR REPLACE INTO holiday_occurrence_source (occurrence_id, source_key, assertion_role, freshness, raw_payload) VALUES (?, ?, 'asserted', ?, ?)",
            [occ_id, "openholidays_api", int(time.time() * 1000), json.dumps(h)]
        )
        loaded += 1
    return loaded


def load_us(year: int) -> int:
    """Load US public holidays from Nager.Date. Returns count loaded."""
    print(f"  Fetching US {year} from Nager.Date ...")
    url = f"https://date.nager.at/api/v3/PublicHolidays/{year}/US"
    data = fetch_json(url)
    print(f"    Got {len(data)} holidays")
    country_id = get_country_id("US")
    loaded = 0
    for h in data:
        concept_name = h.get("name", "").strip()
        if not concept_name:
            continue
        local_name = h.get("localName", "").strip()
        types = h.get("types", ["Public"])
        global_ = h.get("global", True)
        counties = h.get("counties")  # null if federal
        # Concept
        tradition = None
        if any(kw in concept_name for kw in ["Christmas", "Easter", "Thanksgiving"]):
            tradition = "christian"
        concept_id = get_or_create_concept(concept_name, name_local=local_name, tradition=tradition, release_id=f"nager-date-us-{year}")
        # For state-level holidays, create one occurrence per state
        if counties:
            # State-level: insert one occurrence per (state, county) — for MVP just one occurrence with first state
            # Better: insert one occurrence per state, each with that state's scope
            for subdiv in counties:
                # Insert occurrence
                r = http_query(
                    """INSERT INTO holiday_occurrence
                       (concept_id, country_id, subdivision_code, start_date, end_date, date_role, legal_status, scope_level, event_domain, date_status, release_id, created_at, updated_at)
                       VALUES (?, ?, ?, ?, ?, 'actual', 'public', 'subdivision', 'civil', 'confirmed', ?, ?, ?) RETURNING id""",
                    [concept_id, country_id, subdiv, h["date"], h["date"], f"nager-date-us-{year}", int(time.time() * 1000), int(time.time() * 1000)]
                )
                if not r["ok"]:
                    continue
                occ_id = r["data"][0]["id"]
                filters = nager_to_filters(types, global_=False)
                for f in filters:
                    http_query("INSERT OR IGNORE INTO holiday_occurrence_filter (occurrence_id, filter_code) VALUES (?, ?)", [occ_id, f])
                http_query(
                    "INSERT OR REPLACE INTO holiday_occurrence_source (occurrence_id, source_key, assertion_role, freshness, raw_payload) VALUES (?, ?, 'asserted', ?, ?)",
                    [occ_id, "nager_date", int(time.time() * 1000), json.dumps(h)]
                )
                loaded += 1
        else:
            # Federal — one occurrence
            r = http_query(
                """INSERT INTO holiday_occurrence
                   (concept_id, country_id, subdivision_code, start_date, end_date, date_role, legal_status, scope_level, event_domain, date_status, release_id, created_at, updated_at)
                   VALUES (?, ?, NULL, ?, ?, 'actual', 'public', 'country', 'civil', 'confirmed', ?, ?, ?) RETURNING id""",
                [concept_id, country_id, h["date"], h["date"], f"nager-date-us-{year}", int(time.time() * 1000), int(time.time() * 1000)]
            )
            if not r["ok"]:
                continue
            occ_id = r["data"][0]["id"]
            filters = nager_to_filters(types, global_=True)
            for f in filters:
                http_query("INSERT OR IGNORE INTO holiday_occurrence_filter (occurrence_id, filter_code) VALUES (?, ?)", [occ_id, f])
            http_query(
                "INSERT OR REPLACE INTO holiday_occurrence_source (occurrence_id, source_key, assertion_role, freshness, raw_payload) VALUES (?, ?, 'asserted', ?, ?)",
                [occ_id, "nager_date", int(time.time() * 1000), json.dumps(h)]
            )
            loaded += 1
    return loaded


def register_sources():
    """Register the holiday sources in holiday_source table."""
    now_ms = int(time.time() * 1000)
    sources = [
        ("openholidays_api", "D", "OpenHolidays API", "EU", "Public,School,Bank,Authorities,Optional,Observance", "json",
         "https://openholidaysapi.org/", "ODbL", "https://opendatacommons.org/licenses/odbl/",
         "Data © OpenHolidays API contributors, licensed under ODbL", 1, 1, 1,
         "Free public API. ~20 EU countries. Provides public, school, bank, authorities, optional, observance holidays.",
         now_ms, now_ms),
        ("nager_date", "D", "Nager.Date", "global", "Public,Bank,School,Authorities,Optional,Observance", "json",
         "https://date.nager.at/api/v3", "MIT-style", "https://github.com/nager/nager.date",
         "Data from Nager.Date (open-source project). Verify license before commercial use.", 1, 1, 1,
         "Free public API. ~110 countries. Type: Public, Bank, School, Authorities, Optional, Observance.",
         now_ms, now_ms),
    ]
    for s in sources:
        r = http_query(
            """INSERT OR REPLACE INTO holiday_source
               (source_key, authority_tier, organization, scope_country, filters, format,
                endpoint_url, license, license_url, attribution, redistribution_allowed,
                commercial_use_allowed, is_active, notes, created_at, updated_at)
               VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
            list(s)
        )
        if not r["ok"]:
            print(f"  Source registration failed: {r['error'][:100]}")


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    print("Step 1: Register sources ...")
    register_sources()
    print("  Sources registered: openholidays_api (D), nager_date (D)")

    total = 0
    for year in [2026, 2027]:
        print(f"\nStep 2.{year}: Load NL + US ...")
        nl_count = load_nl(year)
        us_count = load_us(year)
        print(f"  NL {year}: {nl_count} occurrences loaded")
        print(f"  US {year}: {us_count} occurrences loaded")
        total += nl_count + us_count

    print(f"\nTotal: {total} holiday occurrences loaded")

    # Verify
    r = http_query("SELECT COUNT(*) as n FROM holiday_occurrence")
    if r["ok"]:
        print(f"  DB now has {r['data'][0]['n']} occurrences")
    r = http_query("SELECT country_id, COUNT(*) as n FROM holiday_occurrence GROUP BY country_id")
    if r["ok"]:
        for row in r["data"]:
            print(f"  country_id={row['country_id']}: {row['n']}")


if __name__ == "__main__":
    main()
