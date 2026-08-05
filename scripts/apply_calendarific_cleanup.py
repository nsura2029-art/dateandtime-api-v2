#!/usr/bin/env python3
"""
Apply Calendarific-only cleanup to D1.

Steps:
1. Snapshot current counts (for rollback)
2. Delete non-Calendarific sources from holiday_source
3. Delete holiday_occurrence_source links to those sources
4. Delete orphan occurrences (no source)
5. Delete orphan concepts (no occurrence)
6. Re-derive filter codes from Calendarific's "type" field

The script is idempotent — running it twice is safe.
"""

import os
import sys
import json
import urllib.request
from collections import Counter

# Add lib to path
sys.path.insert(0, 'lib')
from calendarific_to_m14 import (
    CF_TYPE_TO_FILTER, get_tradition_filter, derive_filters
)

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
        data=payload, method="POST", headers=HEADERS,
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            resp = json.loads(r.read().decode())
            inner = (resp.get("result") or [{}])[0]
            return {
                "ok": resp.get("success") and inner.get("success", False),
                "data": inner.get("results", []),
                "error": (inner.get("errors", [{}])[0].get("message", "") if not inner.get("success") else ""),
                "meta": inner.get("meta", {}),
            }
    except Exception as e:
        return {"ok": False, "data": [], "error": str(e)}


def run_sql(sql: str) -> dict:
    """Run a SQL file via wrangler's --file= equivalent (D1 HTTP query)."""
    return http_query(sql)


def snapshot_count(table: str, where: str = "") -> int:
    """Get current row count for a table."""
    sql = f"SELECT COUNT(*) as cnt FROM {table} {where}"
    r = http_query(sql)
    if r["ok"] and r["data"]:
        return r["data"][0].get("cnt", 0)
    return -1


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        return 1

    print("=" * 60)
    print("STEP 0: Snapshot current state")
    print("=" * 60)

    # Snapshot
    sources = http_query("SELECT code, COUNT(*) as cnt FROM holiday_source GROUP BY code")
    print(f"holiday_source: {sources.get('data', [])}")

    occ_sources = http_query("""
        SELECT hs.code, COUNT(*) as cnt
        FROM holiday_occurrence_source hos
        JOIN holiday_source hs ON hs.id = hos.source_id
        GROUP BY hs.code
    """)
    print(f"holiday_occurrence_source by source:")
    for row in occ_sources.get("data", []):
        print(f"  {row.get('code', '?'):25} {row.get('cnt', 0):>5}")

    occ_count = snapshot_count("holiday_occurrence")
    concept_count = snapshot_count("holiday_concept")
    filter_count = snapshot_count("holiday_occurrence_filter")
    print(f"holiday_occurrence: {occ_count}")
    print(f"holiday_concept: {concept_count}")
    print(f"holiday_occurrence_filter: {filter_count}")

    print()
    print("=" * 60)
    print("STEP 1: Delete non-Calendarific sources from registry")
    print("=" * 60)

    # Find IDs of sources to remove
    sources_to_remove = http_query("""
        SELECT id, code FROM holiday_source
        WHERE code IN ('nager_date', 'un_official', 'hebcal', 'computed_federal_us')
    """)
    remove_ids = [row.get("id") for row in sources_to_remove.get("data", [])]
    print(f"Sources to remove: {[r.get('code') for r in sources_to_remove.get('data', [])]}")

    if not remove_ids:
        print("No sources to remove — already clean")
    else:
        # Delete source links first
        placeholders = ",".join(["?"] * len(remove_ids))
        del_links = http_query(
            f"DELETE FROM holiday_occurrence_source WHERE source_id IN ({placeholders})",
            remove_ids
        )
        print(f"Deleted {del_links.get('meta', {}).get('changes', 0)} holiday_occurrence_source links")

        # Delete source registry entries
        del_sources = http_query(
            f"DELETE FROM holiday_source WHERE id IN ({placeholders})",
            remove_ids
        )
        print(f"Deleted {del_sources.get('meta', {}).get('changes', 0)} holiday_source entries")

    print()
    print("=" * 60)
    print("STEP 2: Delete orphan occurrences (no source links)")
    print("=" * 60)

    del_occ = http_query("""
        DELETE FROM holiday_occurrence
        WHERE id NOT IN (SELECT DISTINCT occurrence_id FROM holiday_occurrence_source)
    """)
    print(f"Deleted {del_occ.get('meta', {}).get('changes', 0)} orphan occurrences")

    print()
    print("=" * 60)
    print("STEP 3: Delete orphan concepts (no occurrences)")
    print("=" * 60)

    del_concepts = http_query("""
        DELETE FROM holiday_concept
        WHERE id NOT IN (SELECT DISTINCT concept_id FROM holiday_occurrence)
    """)
    print(f"Deleted {del_concepts.get('meta', {}).get('changes', 0)} orphan concepts")

    print()
    print("=" * 60)
    print("STEP 4: Clear and re-derive filter codes")
    print("=" * 60)

    # Delete all existing filter assignments
    del_filters = http_query("DELETE FROM holiday_occurrence_filter")
    print(f"Cleared {del_filters.get('meta', {}).get('changes', 0)} existing filter assignments")

    # Get all remaining occurrences with their concept names AND occurrence-level fields
    # holiday_occurrence has: legal_status, event_domain, prominence, scope_level
    all_occs = http_query("""
        SELECT ho.id, ho.legal_status, ho.event_domain, ho.prominence, ho.scope_level,
               hc.name_en, hc.tradition
        FROM holiday_occurrence ho
        JOIN holiday_concept hc ON hc.id = ho.concept_id
    """)
    occs_data = all_occs.get("data", [])
    print(f"Total remaining occurrences: {len(occs_data)}")

    if not occs_data:
        print("No occurrences to process")
        return 0

    # Map event_domain values to Calendarific type names (for derive_filters)
    EVENT_DOMAIN_TO_CF = {
        "civil": "Observance",
        "religious": "Observance",
        "national holiday": "National holiday",
        "local holiday": "Local holiday",
        "common local holiday": "Common local holiday",
        "observance": "Observance",
        "local observance": "Local observance",
        "optional holiday": "Optional holiday",
        "half day": "Half-day holiday",
        "de facto holiday": "De facto holiday",
        "flag day": "Flag day",
        "united nations observance": "United Nations observance",
        "worldwide observance": "Worldwide observance",
        "season": "Season",
        "clock change/daylight saving time": "Clock change/Daylight Saving Time",
        "christian": "Christian",
        "muslim": "Muslim",
        "hinduism": "Hinduism",
        "hebrew": "Hebrew",
        "jewish": "Hebrew",
        "orthodox": "Orthodox",
        "sporting event": "Sporting event",
        "time_zone": "Clock change/Daylight Saving Time",
        "un": "United Nations observance",
        "worldwide": "Worldwide observance",
    }

    # Map legal_status to Calendarific type
    LEGAL_STATUS_TO_CF = {
        "public": "National holiday",
        "de_facto": "De facto holiday",
        "optional": "Optional holiday",
        "observance": "Observance",
        "half_day": "Half-day holiday",
        "working_day_override": "Observance",  # special working day
    }

    # Build filter assignments
    filter_assignments = []
    for row in occs_data:
        occ_id = row.get("id")
        name = row.get("name_en", "")
        tradition = row.get("tradition", "")
        legal_status = row.get("legal_status", "")
        event_domain = row.get("event_domain", "")

        # Determine Calendarific type
        cf_type = None
        # Try event_domain first (more specific)
        if event_domain:
            cf_type = EVENT_DOMAIN_TO_CF.get(event_domain.lower())
        # Fall back to legal_status
        if not cf_type and legal_status:
            cf_type = LEGAL_STATUS_TO_CF.get(legal_status.lower())
        # Default
        if not cf_type:
            cf_type = "Observance"

        filters = derive_filters(name, cf_type)
        for f in filters:
            filter_assignments.append((occ_id, f))

    print(f"Computed {len(filter_assignments)} filter assignments")

    # Use SQL INSERT OR REPLACE to do it all in one shot via SQL file
    # Generate SQL file
    os.makedirs("tmp", exist_ok=True)
    sql_path = "tmp/rederive_filters.sql"
    BATCH = 16  # 2-col inserts: 16 rows × 2 = 32 vars (safe)
    with open(sql_path, "w") as f:
        f.write("-- Re-derived filter codes from Calendarific data\n")
        f.write("-- Generated by apply_calendarific_cleanup.py\n\n")
        # Group by (occ_id, filter_code) to dedupe
        seen = set()
        unique_assignments = []
        for occ_id, fc in filter_assignments:
            key = (occ_id, fc)
            if key not in seen:
                seen.add(key)
                unique_assignments.append((occ_id, fc))
        f.write(f"-- Total unique assignments: {len(unique_assignments)}\n\n")
        for i in range(0, len(unique_assignments), BATCH):
            batch = unique_assignments[i:i + BATCH]
            placeholders = ",".join(["(?,?)"] * len(batch))
            f.write(f"INSERT OR IGNORE INTO holiday_occurrence_filter (occurrence_id, filter_code) VALUES {placeholders};\n")
    print(f"Wrote {len(unique_assignments)} unique assignments to {sql_path}")

    print(f"\nRun via: npx wrangler d1 execute timeandtimepro-full-v2 --file={sql_path} --env dev --remote")
    print("(Do this separately — too many rows for HTTP API direct insert)")

    # Insert filter assignments in batches
    BATCH = 16  # 2-col inserts: 16 rows × 2 = 32 vars (safe)
    inserted = 0
    for i in range(0, len(filter_assignments), BATCH):
        batch = filter_assignments[i:i + BATCH]
        placeholders = ",".join(["(?,?)"] * len(batch))
        flat_params = []
        for occ_id, f in batch:
            flat_params.extend([occ_id, f])
        sql = f"INSERT INTO holiday_occurrence_filter (occurrence_id, filter_code) VALUES {placeholders}"
        r = http_query(sql, flat_params)
        if r["ok"]:
            inserted += len(batch)
        else:
            print(f"  ERROR at batch {i}: {r.get('error', '')[:200]}")
            if i < 100:  # Show first few errors
                continue
            else:
                break

    print(f"Inserted {inserted} filter assignments")

    print()
    print("=" * 60)
    print("STEP 5: Final verification")
    print("=" * 60)

    # Final counts
    final_sources = http_query("SELECT code, COUNT(*) as cnt FROM holiday_source GROUP BY code")
    print(f"holiday_source after cleanup:")
    for row in final_sources.get("data", []):
        print(f"  {row.get('code', '?'):25} {row.get('cnt', 0):>3}")

    final_occ = snapshot_count("holiday_occurrence")
    final_concept = snapshot_count("holiday_concept")
    final_filter = snapshot_count("holiday_occurrence_filter")
    print(f"holiday_occurrence: {final_occ} (was {occ_count})")
    print(f"holiday_concept: {final_concept} (was {concept_count})")
    print(f"holiday_occurrence_filter: {final_filter} (was {filter_count})")

    # Filter code distribution
    final_filters = http_query("""
        SELECT filter_code, COUNT(*) as cnt
        FROM holiday_occurrence_filter
        GROUP BY filter_code
        ORDER BY cnt DESC
    """)
    print(f"Filter code distribution (top 15):")
    for row in final_filters.get("data", [])[:15]:
        print(f"  {row.get('filter_code', '?'):25} {row.get('cnt', 0):>5}")

    print()
    print("=" * 60)
    print("DONE — Calendarific-only cleanup complete")
    print("=" * 60)
    return 0


if __name__ == "__main__":
    sys.exit(main())
