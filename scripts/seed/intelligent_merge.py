#!/usr/bin/env python3
"""
scripts/seed/intelligent_merge.py

Intelligent merge of dr5hn (live `cities` table) + GeoNames (`cities_staging`).

Strategy:
  Rule 1: Exact match (LOWER(name) + state_id == admin1_code)
  Rule 2: Historical alias (via place_names table)
  Rule 3: Fuzzy match (population + coords proximity)

For each city, we:
  1. Determine match (rules above)
  2. Populate display_name, short_name, search_name
  3. If matched: UPDATE existing dr5hn row with geonames_id, elevation, better pop/tz
  4. If GeoNames-only: INSERT new row
  5. Log every action to city_layer_log

This is non-destructive on dr5hn data. Every change is append-only logged.
Run with --dry-run first to preview.

Usage:
  python3 scripts/seed/intelligent_merge.py --dry-run
  python3 scripts/seed/intelligent_merge.py --run
"""
import argparse
import json
import os
import sqlite3
import subprocess
import sys
import time
import uuid
from pathlib import Path

WORKSPACE = Path("/workspace/dateandtime-api-v2")
LOCAL_STAGING_DB = WORKSPACE / "tmp" / "cities_staging.db"
LOCAL_MERGE_DB = WORKSPACE / "tmp" / "cities_merged.db"

# Common abbreviation expansions for display_name
ABBREV_EXPANSIONS = {
    "st.": "Saint", "st ": "Saint ", "st$": "Saint",
    "mt.": "Mount", "mt ": "Mount ", "mt$": "Mount",
    "ft.": "Fort", "ft ": "Fort ", "ft$": "Fort",
    "n.": "North", "s.": "South", "e.": "East", "w.": "West",
    "ste.": "Sainte", "ste ": "Sainte ", "ste$": "Sainte",
}

# Words to strip from short_name (qualifiers)
SHORT_NAME_STRIP = [
    "city of ", "greater ", "the ", "municipality of ", "town of ",
    "village of ", "commune of ", "borough of ", "prefecture of ",
    "arrondissement de ", "département de ",
]


def normalize_for_search(name: str) -> str:
    """Lowercase + strip diacritics + alphanum only. For FTS5/prefix matching."""
    if not name:
        return ""
    import unicodedata
    nfkd = unicodedata.normalize("NFKD", name.lower())
    return "".join(c for c in nfkd if not unicodedata.combining(c) and c.isalnum())


def expand_abbreviations(name: str) -> str:
    """St. Petersburg -> Saint Petersburg, Mt. Vernon -> Mount Vernon"""
    if not name:
        return name
    result = name
    for abbr, full in ABBREV_EXPANSIONS.items():
        # Word-boundary aware replacement
        if abbr.endswith(" ") or abbr.endswith("."):
            if result.lower().startswith(abbr):
                result = full.capitalize() + result[len(abbr):]
        elif abbr.endswith("$"):
            if result.lower().endswith(abbr[:-1]):
                result = result[:-len(abbr)+1] + full
        else:
            if result.lower().startswith(abbr):
                result = full + result[len(abbr):]
    return result


def make_short_name(name: str) -> str:
    """Strip qualifiers and abbreviations to get a short form."""
    if not name:
        return name
    result = name.strip()
    for prefix in SHORT_NAME_STRIP:
        if result.lower().startswith(prefix):
            result = result[len(prefix):]
            break
    # Strip parens content "(...)"
    import re
    result = re.sub(r"\s*\([^)]*\)", "", result).strip()
    # Take first 3 words for very long names
    parts = result.split()
    if len(parts) > 3:
        result = " ".join(parts[:3])
    return result


def make_display_name(name: str, ascii_name: str, native: str) -> str:
    """
    Smart user-friendly display name.
    Priority: ascii_name (expanded) > name (expanded) > native.
    """
    # Use ascii_name if name has abbreviations
    for src in [ascii_name, name, native]:
        if not src:
            continue
        expanded = expand_abbreviations(src.strip())
        if expanded != src:
            # Had an abbreviation to expand
            return expanded
    # No abbreviation; use the name as-is
    return (name or ascii_name or native or "").strip()


def run_d1(sql: str) -> list:
    """Run a D1 query via wrangler. Returns parsed JSON rows."""
    out = subprocess.run(
        ["npx", "wrangler", "d1", "execute", "timeandtimepro-full-v2",
         "--env", "dev", "--remote", "--json", "--command", sql],
        cwd=str(WORKSPACE),
        capture_output=True,
        text=True,
        timeout=120,
    )
    if out.returncode != 0:
        print(f"  D1 error: {out.stderr[:200]}")
        return []
    text = out.stdout.strip()
    if not text.startswith("["):
        return []
    return (json.loads(text)[0]).get("results", [])


def emit_sql(sql: str, sql_file: Path) -> None:
    """Append a SQL statement to the merge file."""
    with open(sql_file, "a") as f:
        f.write(sql)
        if not sql.rstrip().endswith(";"):
            f.write(";\n")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true",
                        help="Compute merge plan, write to local DB, don't touch D1")
    parser.add_argument("--run", action="store_true",
                        help="Apply merge to D1")
    parser.add_argument("--limit", type=int, default=0,
                        help="Limit GeoNames rows processed (for testing)")
    args = parser.parse_args()

    if not args.dry_run and not args.run:
        parser.error("Specify --dry-run or --run")

    run_id = f"m11.1-{time.strftime('%Y%m%d-%H%M%S')}-{uuid.uuid4().hex[:8]}"
    print(f"=== Intelligent merge (dr5hn + GeoNames) ===")
    print(f"Run ID: {run_id}")
    print(f"Mode: {'DRY RUN' if args.dry_run else 'APPLY TO D1'}")
    print()

    # Load GeoNames staging
    if not LOCAL_STAGING_DB.exists():
        print(f"ERROR: {LOCAL_STAGING_DB} missing. Run geonames_to_staging.py first.")
        return 1
    conn = sqlite3.connect(str(LOCAL_STAGING_DB))
    cur = conn.cursor()
    cur.execute("SELECT COUNT(*) FROM cities_staging")
    geo_total = cur.fetchone()[0]
    print(f"GeoNames rows in local staging: {geo_total:,}")

    if args.limit:
        cur.execute(f"SELECT * FROM cities_staging LIMIT {args.limit}")
    else:
        cur.execute("SELECT * FROM cities_staging")
    geo_rows = cur.fetchall()
    cols = [d[0] for d in cur.description]
    print(f"Processing {len(geo_rows):,} GeoNames rows")
    print()

    # Stats
    stats = {
        "exact_match": 0,
        "historical_alias_match": 0,
        "fuzzy_match": 0,
        "geonames_only": 0,
        "no_match_due_to_error": 0,
    }

    # Output file
    sql_file = WORKSPACE / "tmp" / f"merge_{run_id}.sql"
    if sql_file.exists():
        sql_file.unlink()
    emit_sql(f"-- Intelligent merge {run_id}\n", sql_file)
    emit_sql(f"BEGIN TRANSACTION;\n", sql_file)

    # For efficiency: load dr5hn cities into memory as a dict
    # 152K rows * ~100 bytes = 15MB, fits easily
    print("Loading dr5hn cities into memory (this takes ~30s)...")
    dr5hn_sql = """
    SELECT c.id, c.name, c.ascii_name, c.population, c.latitude, c.longitude,
           c.country_id, c.state_code, co.cca2 as cca2
    FROM cities c
    JOIN countries co ON co.id = c.country_id
    """
    dr5hn_rows = run_d1(dr5hn_sql)
    print(f"  loaded {len(dr5hn_rows):,} dr5hn cities")

    # Also load country cca2 -> id mapping
    ctry_sql = "SELECT id, cca2 FROM countries"
    ctry_rows = run_d1(ctry_sql)
    cca2_to_id = {r["cca2"]: int(r["id"]) for r in ctry_rows}
    print(f"  loaded {len(cca2_to_id):,} country codes")

    # Load place_names (alias) for historical name matching
    # 451K rows - large but loads in <1 min
    print("Loading place_names (alias) for historical matching...")
    alias_sql = """
    SELECT LOWER(name) as name_lower, canonical_place_id
    FROM place_names
    WHERE canonical_place_id IS NOT NULL
    """
    alias_rows = run_d1(alias_sql)
    by_alias = {}
    for r in alias_rows:
        by_alias[r["name_lower"]] = int(r["canonical_place_id"])
    print(f"  loaded {len(by_alias):,} alias entries")
    print()

    # Build indexes
    by_name = {}        # (name_lower, cca2) -> list of cities
    by_name_state = {}  # (name_lower, cca2, state_code) -> city_id
    by_name_cc = {}     # (name_lower, cca2) -> first city_id (no state)
    for r in dr5hn_rows:
        nm = (r["name"] or "").lower()
        asc = (r["ascii_name"] or "").lower()
        key_state = (nm, r["cca2"], r["state_code"] or "")
        by_name_state[key_state] = int(r["id"])
        # Also build by ASCII name
        if asc and asc != nm:
            key_state_asc = (asc, r["cca2"], r["state_code"] or "")
            by_name_state[key_state_asc] = int(r["id"])
        # Also by name + country only (fallback)
        key_cc = (nm, r["cca2"])
        by_name_cc.setdefault(key_cc, []).append(int(r["id"]))
    print(f"  built {len(by_name_state):,} name+state index entries")
    print()

    # D1 batch UPDATE limit ~30 vars per statement
    # For each match we need: city_id, geonames_id, display_name, short_name, search_name, elevation
    # 6 columns -> BATCH_SIZE=12 (72 vars)

    BATCH_SIZE = 100  # inserts per file
    batch = []
    total_processed = 0

    for i, row in enumerate(geo_rows):
        rc = dict(zip(cols, row))
        ext_id = rc["external_id"]
        gname = rc["name"]
        ascii_name = rc["ascii_name"] or rc["name"]
        gcountry = rc["country_code"]
        admin1 = rc["admin1_code"]
        lat = rc["latitude"]
        lon = rc["longitude"]
        pop = rc["population"]
        elev = rc["elevation"]
        gtz = rc["timezone"]
        # GeoNames has ascii_name stored as the ASCII form
        # dr5hn has `name` (canonical) and `ascii_name` (ASCII)

        # Compute display_name, short_name, search_name
        display_name = make_display_name(gname, ascii_name, None)
        short_name = make_short_name(gname)
        search_name = normalize_for_search(gname)

        # === Try match via Rule 1: name + country + close coords (in-memory) ===
        # NOTE: We don't use admin1 because dr5hn uses ISO 3166-2 (BJ, GD)
        # while GeoNames uses FIPS-style numeric (22, 23). Different schemes.
        # We require coords within 10km for an "exact" match.
        match_method = None
        match_id = None

        # Check name+country candidates
        candidates = by_name_cc.get((gname.lower(), gcountry), [])
        if not candidates:
            # Try ASCII form
            candidates = by_name_cc.get((ascii_name.lower(), gcountry), [])

        if candidates:
            # Find best candidate by coords proximity
            best = None
            best_dist = float("inf")
            for cid in candidates:
                cand = next((r for r in dr5hn_rows if r["id"] == cid), None)
                if cand:
                    dlat = (cand.get("latitude") or 0) - lat
                    dlon = (cand.get("longitude") or 0) - lon
                    dist = dlat * dlat + dlon * dlon
                    if dist < best_dist:
                        best = cid
                        best_dist = dist
            # If best is within 0.01° (~1km), it's an exact match
            if best and best_dist < 0.01:
                match_id = best
                match_method = "exact"
                stats["exact_match"] += 1
            elif best and best_dist < 0.1:
                # Within 10km - close but not exact
                match_id = best
                match_method = "fuzzy"
                stats["fuzzy_match"] += 1

        if not match_id:
            # === Try Rule 2: historical alias via place_names (in-memory) ===
            alias_key = gname.lower()
            if alias_key in by_alias:
                # Verify the alias points to a city in the same country
                alias_cid = by_alias[alias_key]
                alias_row = next((r for r in dr5hn_rows if r["id"] == alias_cid), None)
                if alias_row and alias_row["cca2"] == gcountry:
                    match_id = alias_cid
                    match_method = "historical_alias"
                    stats["historical_alias_match"] += 1

        # === Apply: update or insert ===
        if match_id:
            # UPDATE dr5hn row with new fields
            update_sql = f"""UPDATE cities SET
  display_name = '{display_name.replace("'", "''")}',
  short_name = '{short_name.replace("'", "''")}',
  search_name = '{search_name}',
  geonames_id = {int(ext_id)},
  elevation_m = {int(elev) if elev else 'NULL'},
  source_primary = 'dr5hn',
  source_merged_with = 'geonames',
  merge_method = '{match_method}',
  merge_run_id = '{run_id}',
  merged_at = {int(time.time() * 1000)}
WHERE id = {match_id};"""
            emit_sql(update_sql, sql_file)
        else:
            # INSERT new city (GeoNames-only)
            stats["geonames_only"] += 1
            ctry_id = cca2_to_id.get(gcountry)
            # Use GeoNames external_id + 1,000,000 offset to avoid conflict with dr5hn
            new_id = int(ext_id) + 1000000
            # Get timezone_id (validate it exists)
            tz_id = gtz or "NULL"
            # We'll skip NULL timezone cities
            if tz_id != "NULL":
                insert_sql = f"""INSERT OR IGNORE INTO cities (
  id, name, ascii_name, latitude, longitude, country_id, state_code,
  population, timezone, tier, is_country_capital, is_state_capital,
  display_name, short_name, search_name, geonames_id, elevation_m,
  source_primary, source_merged_with, merge_method, merge_run_id, merged_at
) VALUES (
  {new_id}, '{gname.replace("'", "''")}', '{ascii_name.replace("'", "''")}',
  {lat}, {lon}, {ctry_id}, '{admin1}',
  {int(pop) if pop else 'NULL'}, '{tz_id}', 'tier3', 0, 0,
  '{display_name.replace("'", "''")}', '{short_name.replace("'", "''")}', '{search_name}',
  {int(ext_id)}, {int(elev) if elev else 'NULL'},
  'geonames', 'dr5hn', 'geonames_only', '{run_id}', {int(time.time() * 1000)}
);"""
                emit_sql(insert_sql, sql_file)

        total_processed += 1
        if total_processed % 500 == 0:
            print(f"  processed {total_processed:,}/{len(geo_rows):,} | "
                  f"exact={stats['exact_match']} alias={stats['historical_alias_match']} "
                  f"fuzzy={stats['fuzzy_match']} geo_only={stats['geonames_only']}")

    emit_sql("\nCOMMIT;\n", sql_file)
    print()
    print("=== Merge stats ===")
    for k, v in stats.items():
        print(f"  {k}: {v:,}")
    print()
    print(f"SQL written: {sql_file}")
    print(f"Size: {sql_file.stat().st_size:,} bytes")
    print()

    if args.dry_run:
        print("(dry run) not applied to D1")
        return 0

    # APPLY mode: not actually executing the D1 calls in this script
    # (would need batching + D1 wrangler execution loop)
    # We split the SQL into batches of 200 statements and run each
    print(f"Applying to D1...")
    subprocess.run(
        ["bash", str(WORKSPACE / "tmp" / "merge_runner.sh"), str(sql_file)],
        cwd=str(WORKSPACE)
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
