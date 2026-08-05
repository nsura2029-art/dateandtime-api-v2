#!/usr/bin/env python3
"""
scripts/seed/holiday_enrich.py

M14: Holiday enrichment engine.
Adds:
- Computed (Easter, US federal, seasons, DST, US observances)
- Hebcal (Jewish holidays for all countries)
- UN days (worldwide, 178 items)
- Nager.Date (India, NZ upgrade)

For each country in the priority list (US, NL, IN, NZ, UK), runs all applicable
enrichment sources. Idempotent: uses concept (name_en, country_id) dedup.

Run:
  python3 scripts/seed/holiday_enrich.py            # all countries
  python3 scripts/seed/holiday_enrich.py US IN      # specific countries
  python3 scripts/seed/holiday_enrich.py --year 2027

Env: CLOUDFLARE_API_TOKEN must be set.
"""
import os
import sys
import json
import time
import urllib.request
from datetime import datetime, date

# Add parent to path so we can import enrichment modules
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))

from holiday_enrichment.computed import (
    generate_us_federal, generate_us_observances, generate_seasons,
    generate_dst_us, generate_us_easter_based, generate_in_national,
    generate_nl_easter_based, generate_gb_bank_holidays, easter_sunday
)
from holiday_enrichment.un_days import UN_DAYS, get_un_days_for_year

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")


def http_query(sql, params=None, expect_result=True):
    body = {"sql": sql}
    if params is not None:
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
            if not expect_result:
                return resp
            inner = (resp.get("result") or [{}])[0]
            return {
                "ok": resp.get("success") and inner.get("success", False),
                "data": inner.get("results", []),
                "error": (inner.get("errors", [{}])[0].get("message", "") if not inner.get("success") else ""),
            }
    except urllib.error.HTTPError as e:
        body = e.read().decode()
        return {"ok": False, "data": [], "error": f"HTTP {e.code}: {body[:200]}"}
    except Exception as e:
        return {"ok": False, "data": [], "error": str(e)}


def get_country_id(cca2):
    r = http_query("SELECT id, name FROM countries WHERE cca2 = ?", [cca2])
    if r["ok"] and r["data"]:
        return r["data"][0]["id"]
    return None


def get_or_create_concept(name_en, name_local=None, tradition=None, description=None,
                          wikidata_qid=None, release_id=None, origin='manual', worldwide=0):
    r = http_query("SELECT id FROM holiday_concept WHERE name_en = ?", [name_en])
    if r["ok"] and r["data"]:
        return r["data"][0]["id"]
    now = int(time.time() * 1000)
    r = http_query("""INSERT INTO holiday_concept
                      (name_en, name_local, tradition, description, wikidata_qid, release_id, worldwide, origin, created_at)
                      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING id""",
                   [name_en, name_local, tradition, description, wikidata_qid, release_id, worldwide, origin, now])
    if not r["ok"]:
        print(f"  ERROR creating concept '{name_en}': {r['error']}")
        return None
    return r["data"][0]["id"]


def insert_occurrence(occ, source_key='manual', raw_payload=None):
    """Insert one holiday_occurrence row + filters + source link. Idempotent."""
    # Resolve concept
    concept_id = get_or_create_concept(
        occ["concept_name"],
        tradition=occ.get("concept_tradition"),
        origin=occ.get("concept_origin", "manual"),
        worldwide=occ.get("concept_worldwide", 0),
    )
    if not concept_id:
        return None

    now = int(time.time() * 1000)
    # Check if occurrence already exists. D1/SQLite doesn't support `IS ?` with params.
    sub = occ.get("subdivision_code")
    country = occ.get("country_id")
    if country is None:
        country_clause = "country_id IS NULL"
        country_params = []
    else:
        country_clause = "country_id = ?"
        country_params = [country]
    if sub is None:
        sub_clause = "subdivision_code IS NULL"
        sub_params = []
    else:
        sub_clause = "subdivision_code = ?"
        sub_params = [sub]
    r = http_query(f"""SELECT id FROM holiday_occurrence
                       WHERE concept_id = ? AND {country_clause} AND {sub_clause}
                       AND start_date = ? AND date_role = ?""",
                   [concept_id] + country_params + sub_params + [occ["start_date"], occ.get("date_role", "actual")])
    if r["ok"] and r["data"]:
        return r["data"][0]["id"]

    # Insert
    r = http_query("""INSERT INTO holiday_occurrence
                      (concept_id, country_id, subdivision_code, locality_name, start_date, end_date,
                       observed_date, date_role, legal_status, scope_level, event_domain, prominence,
                       date_status, tentative_reason, is_working_day, notes,
                       worldwide, category, origin, release_id, created_at, updated_at)
                      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) RETURNING id""",
                   [concept_id, occ.get("country_id"), occ.get("subdivision_code"), occ.get("localality_name"),
                    occ["start_date"], occ.get("end_date"), occ.get("observed_date"),
                    occ.get("date_role", "actual"), occ.get("legal_status"), occ.get("scope_level", "country"),
                    occ.get("event_domain", "civil"), occ.get("prominence", "standard"),
                    occ.get("date_status", "confirmed"), occ.get("tentative_reason"), occ.get("is_working_day"),
                    occ.get("notes"), occ.get("worldwide", 0), occ.get("category", "public_holiday"),
                    occ.get("origin", "manual"), f"holiday-enrich-{int(time.time())}", now, now])
    if not r["ok"]:
        print(f"  ERROR inserting occurrence: {r['error']}")
        return None
    occ_id = r["data"][0]["id"]

    # Insert filters
    for f in occ.get("filters", []):
        http_query("INSERT OR IGNORE INTO holiday_occurrence_filter (occurrence_id, filter_code) VALUES (?, ?)",
                   [occ_id, f])

    # Insert source link
    payload_str = json.dumps(raw_payload) if raw_payload else json.dumps(occ)
    http_query("""INSERT OR REPLACE INTO holiday_occurrence_source
                  (occurrence_id, source_key, assertion_role, freshness, raw_payload)
                  VALUES (?, ?, ?, ?, ?)""",
               [occ_id, source_key, occ.get("assertion_role", "calculated"),
                now, payload_str])

    return occ_id


def insert_un_day(date_str, name_en, agency, description):
    """Insert a UN day into holiday_un_day (one row per day, applies every year).
    Returns the un_day_id.
    """
    r = http_query("SELECT id FROM holiday_un_day WHERE name_en = ? AND date_observed = ?",
                   [name_en, date_str])
    if r["ok"] and r["data"]:
        return r["data"][0]["id"]
    now = int(time.time() * 1000)
    r = http_query("""INSERT INTO holiday_un_day (name_en, name_short, date_observed, agency, description, created_at)
                      VALUES (?, ?, ?, ?, ?, ?) RETURNING id""",
                   [name_en, name_en, date_str, agency, description, now])
    if not r["ok"]:
        print(f"  ERROR inserting UN day '{name_en}': {r['error']}")
        return None
    return r["data"][0]["id"]


def insert_un_occurrence(un_day_id, year, country_id=None, country_code=None):
    """For a specific country (or worldwide), create a holiday_occurrence for the UN day in that year.
    If country_id is None, creates a worldwide occurrence (country_id NULL).
    """
    # Get the UN day
    r = http_query("SELECT * FROM holiday_un_day WHERE id = ?", [un_day_id])
    if not r["ok"] or not r["data"]:
        return None
    un_day = r["data"][0]
    # Compute actual date for this year
    month, day = un_day["date_observed"].split("-")
    actual_date = date(year, int(month), int(day)).isoformat()

    # Create the occurrence
    occ = {
        "concept_name": un_day["name_en"],
        "concept_tradition": "observance",
        "concept_origin": "un_official",
        "concept_worldwide": 1 if country_id is None else 0,
        "country_id": country_id,
        "subdivision_code": None,
        "start_date": actual_date,
        "date_role": "actual",
        "legal_status": "observance",
        "scope_level": "global" if country_id is None else "country",
        "event_domain": "UN" if "UN" in (un_day.get("agency") or "") else "worldwide",
        "prominence": "common",
        "date_status": "official_announced",
        "origin": "un_official",
        "category": "international" if country_id is None else "observance",
        "worldwide": 1 if country_id is None else 0,
        "filters": ["UN_OBSERVANCE"] if country_id is None else ["UN_OBSERVANCE", "OBS_IMPORTANT"],
    }
    return insert_occurrence(occ, source_key='un_official', raw_payload={"un_day_id": un_day_id, "year": year})


# =============================================================================
# Hebcal integration
# =============================================================================
def fetch_hebcal(year):
    """Fetch Jewish holidays from Hebcal API.
    Only includes: major holidays, minor holidays, modern holidays, minor fast days.
    Excludes: weekly parashat, rosh chodesh, candle lighting, shabbat times, yahrzeit.
    """
    import urllib.request
    url = (f"https://www.hebcal.com/hebcal?v=1&cfg=json&year={year}"
           f"&maj=on&min=on&mod=on&mf=on&c=off&nx=off&ss=off&geo=none&i=off&s=off&d=off")
    req = urllib.request.Request(url, headers={"User-Agent": "dateandtime-api-v2/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            data = json.loads(r.read().decode())
            return data.get("items", [])
    except Exception as e:
        print(f"  ERROR fetching Hebcal: {e}")
        return []


# Map Hebcal's flags to our filter codes
def hebcal_filters_for_item(item):
    """Determine the filter codes for a Hebcal item."""
    name = item.get("title", "")
    # Yom Tov (work-prohibited) → JEWISH_MAJOR
    if item.get("yomtov"):
        return ["JEWISH_MAJOR"]
    # Modern Israeli holidays (Yom HaShoah, Yom Ha'atzmaut, etc.) → JEWISH_MORE
    if "yom ha" in name.lower() or "lag ba" in name.lower() or "tu bishvat" in name.lower():
        return ["JEWISH_MORE"]
    # Minor holidays (minor fasts, modern) → JEWISH_MORE
    if item.get("category") == "minor" or "fast" in (item.get("title", "").lower()):
        return ["JEWISH_MORE"]
    # Modern category (Israel-specific) → JEWISH_MORE
    if item.get("category") == "modern":
        return ["JEWISH_MORE"]
    # Major holidays (Pesach, Sukkot etc. that span multiple days) → JEWISH_MAJOR
    if item.get("subcat") == "modern":
        return ["JEWISH_MORE"]
    # Default fallback
    return ["JEWISH_MORE"]


def insert_hebcal_item(item, country_id, country_code):
    """Insert one Hebcal Jewish holiday as a holiday_occurrence for the country.
    Only inserts major + minor + modern + minor-fast Jewish holidays. Skips
    roshchodesh, parashat, candle lighting, etc.
    """
    cat = item.get("category")
    # Strict filter: only these categories
    if cat not in ("holiday", "minor", "modern", "fast"):
        return None
    name = item.get("title", "").strip()
    if not name:
        return None
    filters = hebcal_filters_for_item(item)
    occ = {
        "concept_name": name,
        "concept_tradition": "jewish",
        "concept_origin": "hebcal",
        "country_id": country_id,
        "subdivision_code": None,
        "start_date": item.get("date", "")[:10] if item.get("date") else None,
        "date_role": "actual",
        "legal_status": "observance",
        "scope_level": "country",
        "event_domain": "religious",
        "prominence": "major" if item.get("yomtov") else "common",
        "date_status": "calculated",
        "origin": "hebcal",
        "category": "religious" if item.get("yomtov") else "observance",
        "filters": filters,
    }
    if not occ["start_date"]:
        return None
    return insert_occurrence(occ, source_key='hebcal', raw_payload=item)


# =============================================================================
# Nager.Date integration (for countries not in our priority list)
# =============================================================================
def fetch_nager(cca2, year):
    """Fetch holidays from Nager.Date API."""
    import urllib.request
    url = f"https://date.nager.at/api/v3/PublicHolidays/{year}/{cca2}"
    req = urllib.request.Request(url, headers={"User-Agent": "dateandtime-api-v2/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        print(f"  ERROR fetching Nager {cca2} {year}: {e}")
        return []


NAGER_TYPE_TO_FILTERS = {
    "Public": ["PUBLIC_NATIONAL"],
    "Bank": ["BANK_CLOSURE"],
    "School": ["SCHOOL_HOLIDAY"],
    "Authorities": ["GOVERNMENT_CLOSURE"],
    "Optional": ["OPTIONAL_HOLIDAY"],
    "Observance": ["OBS_IMPORTANT"],
}


def insert_nager_item(holiday, country_id):
    """Insert one Nager.Date holiday."""
    name = holiday.get("name", "").strip()
    if not name:
        return None
    types = holiday.get("types", ["Public"])
    t = types[0] if types else "Public"
    filters = NAGER_TYPE_TO_FILTERS.get(t, ["PUBLIC_NATIONAL"])
    if filters == ["PUBLIC_NATIONAL"] and not holiday.get("global", True):
        filters = ["PUBLIC_LOCAL"]

    # Subdivision: Nager.Date sometimes has counties[]
    subdivs = holiday.get("counties") or [None]

    occ_ids = []
    for subdiv in subdivs:
        occ = {
            "concept_name": name,
            "concept_local": holiday.get("localName", "").strip() or None,
            "concept_tradition": None,
            "concept_origin": "nager_date",
            "country_id": country_id,
            "subdivision_code": subdiv,
            "start_date": holiday.get("date"),
            "date_role": "actual",
            "legal_status": "public" if filters[0] == "PUBLIC_NATIONAL" else "de_facto",
            "scope_level": "subdivision" if subdiv else "country",
            "event_domain": "civil",
            "prominence": "standard",
            "date_status": "confirmed",
            "origin": "nager_date",
            "category": "public_holiday",
            "filters": filters,
        }
        occ_id = insert_occurrence(occ, source_key='nager_date', raw_payload=holiday)
        if occ_id:
            occ_ids.append(occ_id)
    return occ_ids


# =============================================================================
# Main orchestrator
# =============================================================================
def enrich_country(cca2, year, country_id, options):
    """Run all enrichment for one country."""
    print(f"\n=== Enriching {cca2} for {year} ===")
    counts = {"computed": 0, "hebcal": 0, "nager": 0, "un": 0, "seasons": 0}

    # Seasons (worldwide, country_id=NULL)
    if cca2 in ("US", "NL", "IN", "NZ", "GB"):  # Only run once for the first country
        if cca2 == "US":  # Only run seasons once
            print("  - Seasons (worldwide)")
            for occ in generate_seasons(year):  # worldwide (country_id=None)
                insert_occurrence(occ, source_key='computed_season')
                counts["seasons"] += 1
    if cca2 == "US":
        print("  - US federal holidays")
        for occ in generate_us_federal(year, country_id):
            insert_occurrence(occ, source_key='computed_federal_us')
            counts["computed"] += 1
        print(f"  - US Easter-based")
        for occ in generate_us_easter_based(year, country_id):
            insert_occurrence(occ, source_key='computed_easter')
            counts["computed"] += 1
        print("  - US observances")
        for occ in generate_us_observances(year, country_id):
            insert_occurrence(occ, source_key='computed_federal_us')
            counts["computed"] += 1
        print("  - US DST")
        for occ in generate_dst_us(year, country_id):
            insert_occurrence(occ, source_key='computed_dst')
            counts["computed"] += 1

    elif cca2 == "NL":
        print("  - NL Easter-based")
        for occ in generate_nl_easter_based(year, country_id):
            insert_occurrence(occ, source_key='computed_easter')
            counts["computed"] += 1

    elif cca2 in ("GB", "UK"):
        print("  - GB bank holidays")
        for occ in generate_gb_bank_holidays(year, country_id):
            insert_occurrence(occ, source_key='computed_gb')
            counts["computed"] += 1

    elif cca2 == "IN":
        print("  - IN national holidays")
        for occ in generate_in_national(year, country_id):
            insert_occurrence(occ, source_key='nager_date')
            counts["computed"] += 1

    # Hebcal (Jewish holidays) — for all countries
    if options.get("hebcal", True):
        print(f"  - Hebcal Jewish holidays for {cca2}")
        hebcal_items = fetch_hebcal(year)
        for item in hebcal_items:
            insert_hebcal_item(item, country_id, cca2)
            counts["hebcal"] += 1

    # Nager.Date — for IN (NL and US already loaded)
    if options.get("nager", True) and cca2 in ("IN", "NZ", "UK"):
        print(f"  - Nager.Date for {cca2}")
        nager_items = fetch_nager(cca2, year)
        for item in nager_items:
            insert_nager_item(item, country_id)
            counts["nager"] += 1

    print(f"  Total: {counts}")
    return counts


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    # Parse args
    args = sys.argv[1:]
    countries = []
    year = 2026
    skip_hebcal = False
    skip_nager = False
    for a in args:
        if a.startswith("--year="):
            year = int(a.split("=")[1])
        elif a == "--no-hebcal":
            skip_hebcal = True
        elif a == "--no-nager":
            skip_nager = True
        elif a.upper() in ("US", "NL", "IN", "NZ", "UK", "GB"):
            countries.append(a.upper())
    if not countries:
        countries = ["US", "IN", "NZ", "UK", "NL"]  # default: all

    # Get country IDs
    country_ids = {}
    for cca2 in countries:
        # UK = GB in our table
        lookup_cca2 = "GB" if cca2 == "UK" else cca2
        cid = get_country_id(lookup_cca2)
        if cid is None:
            print(f"ERROR: Country {cca2} (lookup: {lookup_cca2}) not in countries table")
            sys.exit(1)
        country_ids[cca2] = cid

    # 1. Insert UN days into holiday_un_day (idempotent, one-time)
    print("\n=== Seeding holiday_un_day table ===")
    for mm_dd, name, agency, desc in UN_DAYS:
        insert_un_day(f"{year}-{mm_dd[:2]}-{mm_dd[3:]}" if False else f"{mm_dd}", name, agency, desc)
    # Insert with MM-DD format
    print(f"  {len(UN_DAYS)} UN days seeded")

    # 2. Create worldwide occurrences for UN days (one per year, country_id NULL)
    print(f"\n=== Creating worldwide UN occurrences for {year} ===")
    r = http_query("SELECT id, date_observed, name_en FROM holiday_un_day")
    if r["ok"]:
        un_days = r["data"]
        for ud in un_days:
            month, day = ud["date_observed"].split("-")
            actual_date = date(year, int(month), int(day)).isoformat()
            insert_un_occurrence(ud["id"], year, country_id=None)

    # 3. Per-country enrichment
    options = {"hebcal": not skip_hebcal, "nager": not skip_nager}
    total = {"computed": 0, "hebcal": 0, "nager": 0, "un": 0, "seasons": 0}
    for cca2 in countries:
        counts = enrich_country(cca2, year, country_ids[cca2], options)
        for k, v in counts.items():
            total[k] += v

    # 4. After per-country Hebcal, also add the UN days for each country (per-country UN observance)
    print(f"\n=== Adding UN observance for each country ===")
    r = http_query("SELECT id, date_observed, name_en FROM holiday_un_day")
    if r["ok"]:
        un_days = r["data"]
        for cca2 in countries:
            cid = country_ids[cca2]
            for ud in un_days:
                insert_un_occurrence(ud["id"], year, country_id=cid, country_code=cca2)
            total["un"] += len(un_days)
            print(f"  {cca2}: {len(un_days)} UN days added")

    print(f"\n=== TOTAL ===")
    for k, v in total.items():
        print(f"  {k}: {v}")


if __name__ == "__main__":
    main()
