#!/usr/bin/env python3
"""
calendarific_parse_to_sql.py — Parse 380 Calendarific JSON files into bulk SQL
for D1, then apply with `wrangler d1 execute --file=`.

Two stages:
  1. Build SQL file (offline, no API calls) → scripts/ingest/calendarific.sql
  2. Apply SQL to D1 (via wrangler subprocess)

Mapping (Calendarific primary_type → our filter codes):
  Federal Holiday / National Holiday           → PUBLIC_NATIONAL
  State Holiday / State Legal / Common State   → PUBLIC_LOCAL
  Restricted Holiday                            → OPTIONAL_HOLIDAY
  Observance                                    → OBS_COMMON
  Worldwide observance                           → OBS_IMPORTANT
  Local observance / Local holiday              → OBS_LOCAL / PUBLIC_LOCAL
  United Nations observance                     → UN_OBSERVANCE
  Christian (Easter/Christmas)                  → CHRISTIAN_MAJOR
  Christian (others)                            → CHRISTIAN_MORE
  Jewish holiday (Rosh/Yom Kippur/Pesach/Sukkot/Shavuot) → JEWISH_MAJOR
  Jewish holiday (others) / Jewish commemoration → JEWISH_MORE
  Muslim (Eid al-Fitr / Eid al-Adha)            → MUSLIM_MAJOR
  Muslim (others)                               → MUSLIM_MORE
  Hindu Holiday / Hinduism (Diwali/Holi)         → HINDU_MAJOR
  Hindu Holiday (others)                        → HINDU_MORE
  Buddhism                                      → BUDDHIST
  Sikh                                          → SIKH
  Season                                        → SEASON
  Clock change/Daylight Saving Time             → CLOCK_CHANGE
  Sporting event                                → SPORTING_EVENT
  Orthodox (Easter/Christmas)                   → ORTHODOX_MAJOR
  Orthodox (others)                             → ORTHODOX_MORE
  Part Day / Half Day                           → HALF_DAY (note: filter may not exist yet)
  Annual Monthly Observance                     → OBS_COMMON

Usage:
  # 1. Build SQL only (offline, no D1 calls)
  python3 scripts/ingest/calendarific_parse_to_sql.py --output scripts/ingest/calendarific.sql

  # 2. Apply to D1 (uses wrangler; reads CLOUDFLARE_API_TOKEN from env)
  python3 scripts/ingest/calendarific_parse_to_sql.py --apply
  # OR: bash scripts/apply-all.sh calendarific.sql
"""
import argparse
import json
import os
import re
import subprocess
import sys
import time
from pathlib import Path

# ---- Paths ----
ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = ROOT / "holiday_data" / "calendarific"
MIGRATIONS_DIR = ROOT / "migrations"
DEFAULT_OUT = ROOT / "scripts" / "ingest" / "calendarific.sql"

# ---- Filter catalog (from migrations/156_holiday_core_schema.sql) ----
# We only use codes that exist in the schema. New codes (SIKH, HALF_DAY)
# are emitted with INSERT OR IGNORE on holiday_filter.
KNOWN_FILTERS = {
    "PUBLIC_NATIONAL", "PUBLIC_LOCAL", "BANK_CLOSURE", "GOVERNMENT_CLOSURE",
    "OPTIONAL_HOLIDAY", "SCHOOL_HOLIDAY", "OBS_COMMON", "OBS_IMPORTANT",
    "OBS_OTHER", "OBS_LOCAL", "WORLD_OBSERVANCE", "SEASON", "SPORTING_EVENT",
    "CHRISTIAN_MAJOR", "CHRISTIAN_MORE", "JEWISH_MAJOR", "JEWISH_MORE",
    "MUSLIM_MAJOR", "MUSLIM_MORE", "HINDU_MAJOR", "HINDU_MORE",
    "BUDDHIST", "ORTHODOX_MAJOR", "ORTHODOX_MORE", "UN_OBSERVANCE",
    "CLOCK_CHANGE",
}
# Codes that may not be in the schema yet — we INSERT OR IGNORE them.
NEW_FILTERS = {"SIKH"}

# ---- Calendarific primary_type → our filter codes ----
def map_primary_type(primary: str, name: str) -> set[str]:
    """Return set of our filter codes for a Calendarific entry."""
    if not primary:
        return {"OBS_COMMON"}
    p = primary.lower()
    n = name.lower()

    # Federal / national
    if p in ("federal holiday", "national holiday"):
        return {"PUBLIC_NATIONAL"}
    # State-level
    if p in ("state holiday", "state legal holiday", "common state holiday"):
        return {"PUBLIC_LOCAL"}
    # State public sector / bank
    if p in ("state public sector holiday", "state bank holiday"):
        return {"PUBLIC_LOCAL", "GOVERNMENT_CLOSURE"}
    # Restricted / optional
    if p == "restricted holiday":
        return {"OPTIONAL_HOLIDAY"}
    # Local / observance
    if p == "local holiday":
        return {"PUBLIC_LOCAL"}
    if p == "local observance":
        return {"OBS_LOCAL"}
    if p == "observance":
        return {"OBS_COMMON"}
    if p == "worldwide observance":
        return {"OBS_IMPORTANT"}
    if p == "annual monthly observance":
        return {"OBS_COMMON"}
    # UN
    if p == "united nations observance":
        return {"UN_OBSERVANCE"}
    # Religious
    if p == "christian":
        # Easter / Christmas / Good Friday → MAJOR
        if any(kw in n for kw in ("easter", "christmas", "good friday", "ascension", "pentecost", "epiphany")):
            return {"CHRISTIAN_MAJOR"}
        return {"CHRISTIAN_MORE"}
    if p == "jewish holiday":
        if any(kw in n for kw in ("rosh hashan", "yom kippur", "pesach", "sukkot", "shavuot", "passover", "hanukkah")):
            return {"JEWISH_MAJOR"}
        return {"JEWISH_MORE"}
    if p == "jewish commemoration":
        return {"JEWISH_MORE"}
    if p == "muslim":
        if any(kw in n for kw in ("eid", "ramadan", "muharram", "milad", "mawlid")):
            return {"MUSLIM_MAJOR"}
        return {"MUSLIM_MORE"}
    if p in ("hindu holiday", "hinduism"):
        if any(kw in n for kw in ("diwali", "holi", "dussehra", "vijayadashami", "navaratri", "rama navami", "krishna janmashtami", "ganesh", "rakhi", "raksha bandhan", "bhai duj", "maha shivaratri", "navratri", "lohri", "makar sankranti", "gudi padwa", "ugadi", "baisakhi", "onam", "pongal", "bihu", "rath yatra", "guru purab", "maha kumbh")):
            return {"HINDU_MAJOR"}
        return {"HINDU_MORE"}
    if p == "buddhism":
        return {"BUDDHIST"}
    if p == "sikh":
        return {"SIKH"}
    if p == "orthodox":
        if any(kw in n for kw in ("easter", "christmas", "epiphany")):
            return {"ORTHODOX_MAJOR"}
        return {"ORTHODOX_MORE"}
    if p == "season":
        return {"SEASON"}
    if p == "clock change/daylight saving time":
        return {"CLOCK_CHANGE"}
    if p == "sporting event":
        return {"SPORTING_EVENT"}
    if p in ("part day holiday", "half day restricted trading day"):
        return {"HALF_DAY_HOLIDAY"}
    return {"OBS_COMMON"}


# ---- Country lookup ----
def load_countries() -> dict:
    """Load countries from our API. Returns {cca2: id}."""
    import urllib.request
    url = "https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/countries?limit=500"
    req = urllib.request.Request(url, headers={"User-Agent": "calendarific-parse/1.0"})
    with urllib.request.urlopen(req, timeout=30) as r:
        data = json.loads(r.read().decode())
    return {c["cca2"]: c["id"] for c in data["data"]["countries"]}


# ---- Subdivision lookup ----
def load_admin1_for_country(cca2: str) -> dict:
    """Returns {state_code: subdivision_code} for a country, e.g. {'TX': 'US-TX'}."""
    # We use a simple pattern: ISO 3166-2 codes = "CC-XXX" where CC is cca2
    # Calendarific gives us 'us-tx' (already ISO format) — we just uppercase to 'US-TX'
    return {}


# ---- Parse all JSON files ----
def parse_all_files() -> tuple[list, list, set]:
    """
    Returns:
      - concepts: list of (name_en, name_local, tradition, description) tuples (deduped)
      - occurrences: list of (concept_name, country_id, subdivision_code, start_date, end_date,
                                 date_role, legal_status, scope_level, event_domain, date_status,
                                 raw_json) tuples
      - new_filters: set of new filter codes to insert
    """
    concepts = {}  # name_en → (name_local, tradition, description)
    occurrences = []
    new_filters = set()
    seen_filters_per_occ = set()  # (concept_name, country_id, start_date, subdiv) → filters

    files = sorted(DATA_DIR.glob("2026/*.json")) + sorted(DATA_DIR.glob("2027/*.json"))
    print(f"Reading {len(files)} JSON files from {DATA_DIR}...")
    for f in files:
        year = int(f.parent.name)
        cca2 = f.stem
        try:
            d = json.load(open(f))
        except Exception as e:
            print(f"  ⚠️  Failed to read {f}: {e}")
            continue
        holidays = d.get("response", {}).get("holidays", []) if isinstance(d.get("response"), dict) else []
        for h in holidays:
            name = h.get("name", "").strip()
            if not name:
                continue
            date_iso = h.get("date", {}).get("iso", "")
            if not date_iso:
                continue
            # Concept (dedup by name_en)
            if name not in concepts:
                desc = h.get("description", "")[:500] if h.get("description") else None
                # Determine tradition from primary_type
                pt = h.get("primary_type", "")
                tradition = None
                if pt in ("Christian",):
                    tradition = "christian"
                elif pt in ("Jewish holiday", "Jewish commemoration"):
                    tradition = "jewish"
                elif pt in ("Muslim",):
                    tradition = "muslim"
                elif pt in ("Hindu Holiday", "Hinduism"):
                    tradition = "hindu"
                elif pt in ("Buddhism",):
                    tradition = "buddhist"
                elif pt in ("Sikh",):
                    tradition = "sikh"
                elif pt in ("Orthodox",):
                    tradition = "orthodox"
                concepts[name] = (None, tradition, desc)
            # Map filters
            pt = h.get("primary_type", "")
            filters = map_primary_type(pt, name)
            new_filters.update(filters - KNOWN_FILTERS)
            # Country lookup
            country_id = COUNTRY_MAP.get(cca2)
            if not country_id:
                # Need to look up by ISO numeric or by querying again
                # Calendarific returns 'us', 'in' — we have 'US', 'IN'
                country_id = COUNTRY_MAP.get(cca2.upper())
            if not country_id:
                continue
            # State subdivisions
            states = h.get("states") or []
            if states and isinstance(states, list) and isinstance(states[0], dict):
                # One occurrence per state
                for s in states:
                    subdiv_iso = s.get("iso", "")  # e.g., "us-tx"
                    if not subdiv_iso:
                        continue
                    # Normalize to ISO 3166-2: US-TX
                    subdiv_code = subdiv_iso.upper()
                    key = (name, country_id, date_iso, subdiv_code)
                    if key in seen_filters_per_occ:
                        continue
                    seen_filters_per_occ.add(key)
                    occurrences.append({
                        "concept_name": name,
                        "country_id": country_id,
                        "subdivision_code": subdiv_code,
                        "start_date": date_iso,
                        "end_date": date_iso,
                        "date_role": "actual",
                        "legal_status": "public" if "PUBLIC" in str(filters) else ("observance" if pt and "observance" in pt.lower() else "de_facto"),
                        "scope_level": "subdivision",
                        "event_domain": h.get("type", [""])[0].lower() if h.get("type") else "civil",
                        "date_status": "confirmed",
                        "filters": list(filters),
                        "raw_json": json.dumps(h),
                    })
            else:
                # National-level
                key = (name, country_id, date_iso, None)
                if key in seen_filters_per_occ:
                    continue
                seen_filters_per_occ.add(key)
                occurrences.append({
                    "concept_name": name,
                    "country_id": country_id,
                    "subdivision_code": None,
                    "start_date": date_iso,
                    "end_date": date_iso,
                    "date_role": "actual",
                    "legal_status": "public" if "PUBLIC" in str(filters) else ("observance" if pt and "observance" in pt.lower() else "de_facto"),
                    "scope_level": "country",
                    "event_domain": h.get("type", [""])[0].lower() if h.get("type") else "civil",
                    "date_status": "confirmed",
                    "filters": list(filters),
                    "raw_json": json.dumps(h),
                })
    return list(concepts.items()), occurrences, new_filters


def build_sql(concepts: list, occurrences: list, new_filters: set, source_key: str = "calendarific_api") -> str:
    """Build bulk SQL with batched INSERTs to respect D1 100-var limit."""
    sql_parts = []
    sql_parts.append(f"-- Generated by calendarific_parse_to_sql.py on {time.strftime('%Y-%m-%d %H:%M:%S')}")
    sql_parts.append(f"-- Concepts: {len(concepts)}, Occurrences: {len(occurrences)}, New filters: {sorted(new_filters)}")
    sql_parts.append("")

    # 1. Insert new filters (if any) — INSERT OR IGNORE
    for f in sorted(new_filters):
        # Try to map to existing filter columns
        legal = "public" if f in ("PUBLIC_NATIONAL", "PUBLIC_LOCAL") else ("optional" if f == "OPTIONAL_HOLIDAY" else "observance")
        scope = "subdivision" if f == "PUBLIC_LOCAL" else "country"
        tradition = (
            "christian" if f in ("CHRISTIAN_MAJOR", "CHRISTIAN_MORE") else
            "jewish" if f in ("JEWISH_MAJOR", "JEWISH_MORE") else
            "muslim" if f in ("MUSLIM_MAJOR", "MUSLIM_MORE") else
            "hindu" if f in ("HINDU_MAJOR", "HINDU_MORE") else
            "buddhist" if f == "BUDDHIST" else
            "sikh" if f == "SIKH" else
            "orthodox" if f in ("ORTHODOX_MAJOR", "ORTHODOX_MORE") else
            None
        )
        trad_sql = "NULL" if tradition is None else f"'{tradition}'"
        label = f.replace("_", " ").title()
        ts = int(time.time() * 1000)
        sql_parts.append(
            f"INSERT OR IGNORE INTO holiday_filter (code, label_en, atomic_legal_status, atomic_scope_level, atomic_tradition, default_state, default_selected, display_order, created_at) "
            f"VALUES ('{f}', '{label}', '{legal}', '{scope}', {trad_sql}, 'unsupported', 0, 100, {ts});"
        )
    if new_filters:
        sql_parts.append("")

    # 2. Insert concepts — batch 25 (2 cols × 25 = 50 vars, plus extras = ~80 vars)
    sql_parts.append(f"-- holiday_concept inserts ({len(concepts)} concepts)")
    BATCH = 25
    for i in range(0, len(concepts), BATCH):
        batch = concepts[i:i+BATCH]
        values = []
        for name_en, (name_local, tradition, desc) in batch:
            nl = "NULL" if not name_local else f"'{name_local.replace(chr(39), chr(39)+chr(39))}'"
            tr = "NULL" if not tradition else f"'{tradition}'"
            d = "NULL" if not desc else f"'{desc.replace(chr(39), chr(39)+chr(39))}'"
            values.append(f"('{name_en.replace(chr(39), chr(39)+chr(39))}', {nl}, {tr}, {d}, 'calendarific', {int(time.time()*1000)})")
        sql_parts.append("INSERT OR IGNORE INTO holiday_concept (name_en, name_local, tradition, description, release_id, created_at) VALUES " + ", ".join(values) + ";")
    sql_parts.append("")

    # 3. Insert occurrences — batch 7 (12 cols × 7 = 84 vars)
    sql_parts.append(f"-- holiday_occurrence inserts ({len(occurrences)} occurrences)")
    BATCH = 7
    for i in range(0, len(occurrences), BATCH):
        batch = occurrences[i:i+BATCH]
        values = []
        for o in batch:
            subdiv = "NULL" if not o["subdivision_code"] else f"'{o['subdivision_code']}'"
            end = "NULL" if not o["end_date"] or o["end_date"] == o["start_date"] else f"'{o['end_date']}'"
            event_domain = o["event_domain"][:50] if o["event_domain"] else "civil"
            values.append(
                f"((SELECT id FROM holiday_concept WHERE name_en = '{o['concept_name'].replace(chr(39), chr(39)+chr(39))}' LIMIT 1), "
                f"{o['country_id']}, {subdiv}, '{o['start_date']}', {end}, "
                f"'{o['date_role']}', '{o['legal_status']}', '{o['scope_level']}', '{event_domain}', "
                f"'{o['date_status']}', 'calendarific-2026-2027', {int(time.time()*1000)}, {int(time.time()*1000)})"
            )
        sql_parts.append(
            "INSERT INTO holiday_occurrence "
            "(concept_id, country_id, subdivision_code, start_date, end_date, date_role, legal_status, scope_level, event_domain, date_status, release_id, created_at, updated_at) "
            "VALUES " + ", ".join(values) + ";"
        )
    sql_parts.append("")

    # 4. Insert occurrence_filter — batch 50 (2 cols × 50 = 100 vars)
    # We need to look up the occurrence_id (was just inserted). Use a temp table approach.
    # Simpler: build the same INSERT but with a subquery to find the occurrence
    sql_parts.append(f"-- holiday_occurrence_filter inserts")
    BATCH = 50
    flat = []
    for o in occurrences:
        for f in o["filters"]:
            flat.append((o, f))
    for i in range(0, len(flat), BATCH):
        batch = flat[i:i+BATCH]
        values = []
        for o, f in batch:
            subdiv = "NULL" if not o["subdivision_code"] else f"'{o['subdivision_code']}'"
            occ_subq = (
                f"(SELECT ho.id FROM holiday_occurrence ho "
                f"JOIN holiday_concept hc ON hc.id = ho.concept_id "
                f"WHERE hc.name_en = '{o['concept_name'].replace(chr(39), chr(39)+chr(39))}' "
                f"AND ho.country_id = {o['country_id']} "
                f"AND ho.start_date = '{o['start_date']}' "
                f"AND ({('ho.subdivision_code = ' + subdiv) if subdiv != 'NULL' else 'ho.subdivision_code IS NULL'}) "
                f"ORDER BY ho.id DESC LIMIT 1)"
            )
            values.append(f"({occ_subq}, '{f}')")
        sql_parts.append("INSERT OR IGNORE INTO holiday_occurrence_filter (occurrence_id, filter_code) VALUES " + ", ".join(values) + ";")
    sql_parts.append("")

    # 5. Insert occurrence_source — batch 20 (5 cols × 20 = 100 vars)
    sql_parts.append(f"-- holiday_occurrence_source inserts")
    BATCH = 20
    for i in range(0, len(occurrences), BATCH):
        batch = occurrences[i:i+BATCH]
        values = []
        for o in batch:
            subdiv = "NULL" if not o["subdivision_code"] else f"'{o['subdivision_code']}'"
            occ_subq = (
                f"(SELECT ho.id FROM holiday_occurrence ho "
                f"JOIN holiday_concept hc ON hc.id = ho.concept_id "
                f"WHERE hc.name_en = '{o['concept_name'].replace(chr(39), chr(39)+chr(39))}' "
                f"AND ho.country_id = {o['country_id']} "
                f"AND ho.start_date = '{o['start_date']}' "
                f"AND ({('ho.subdivision_code = ' + subdiv) if subdiv != 'NULL' else 'ho.subdivision_code IS NULL'}) "
                f"ORDER BY ho.id DESC LIMIT 1)"
            )
            raw = o["raw_json"].replace(chr(39), chr(39)+chr(39))
            if len(raw) > 10000:
                raw = raw[:10000]
            values.append(f"({occ_subq}, '{source_key}', 'asserted', {int(time.time()*1000)}, '{raw}')")
        sql_parts.append(
            "INSERT OR REPLACE INTO holiday_occurrence_source (occurrence_id, source_key, assertion_role, freshness, raw_payload) "
            "VALUES " + ", ".join(values) + ";"
        )

    return "\n".join(sql_parts)


def apply_sql(sql_path: Path, env: str = "dev"):
    """Apply SQL file to D1 via wrangler."""
    db_name = "timeandtimepro-full-v2"
    cmd = [
        "npx", "wrangler", "d1", "execute", db_name,
        f"--env={env}", "--remote",
        f"--file={sql_path}",
    ]
    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, capture_output=True, text=True, env={**os.environ, "FORCE_COLOR": "0"})
    print("STDOUT:", result.stdout[-2000:])
    if result.returncode != 0:
        print("STDERR:", result.stderr[-2000:])
        return False
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--output", type=Path, default=DEFAULT_OUT, help="Output SQL file path")
    ap.add_argument("--apply", action="store_true", help="Apply the SQL to D1 via wrangler after generation")
    ap.add_argument("--env", default="dev", help="Wrangler env (dev or prod)")
    ap.add_argument("--limit", type=int, default=None, help="Only process first N files (for testing)")
    args = ap.parse_args()

    global COUNTRY_MAP
    print("Loading country map from dev API...")
    COUNTRY_MAP = load_countries()
    print(f"  Loaded {len(COUNTRY_MAP)} countries")

    concepts, occurrences, new_filters = parse_all_files()
    if args.limit:
        occurrences = occurrences[: args.limit]
    print()
    print(f"  Concepts (unique):      {len(concepts)}")
    print(f"  Occurrences:            {len(occurrences)}")
    print(f"  New filter codes:       {sorted(new_filters) or '(none)'}")

    sql = build_sql(concepts, occurrences, new_filters)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(sql)
    print(f"\nSQL written to {args.output} ({len(sql):,} bytes)")

    if args.apply:
        print()
        apply_sql(args.output, env=args.env)


if __name__ == "__main__":
    main()
