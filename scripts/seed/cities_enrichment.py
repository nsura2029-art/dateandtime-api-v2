#!/usr/bin/env python3
"""
Generate SQL migration files to import dr5hn enrichment data into our cities
table. We have 7 new columns from migration 126:
  - state_code, native, type, level, parent_id, wiki_data_id, flag

Strategy: batched CASE-WHEN UPDATEs. Each batch is 100 cities in a single
multi-column UPDATE statement (within the 100-var D1 limit, since only
the IN (1,2,...) params count as bound variables - CASE WHEN literals don't).

Output: 4 split files (~4MB each) because D1 has a 10MB per-request limit.
"""
import json
import sys
import os
from typing import Iterator

BATCH_SIZE = 100  # cities per UPDATE statement (100 IN-list vars)
NUM_SPLITS = 4    # split into 4 files to stay under 10MB D1 limit

# These are the 7 enrichment fields from dr5hn
ENRICHMENT_FIELDS = [
    "state_code",
    "native",
    "type",
    "level",
    "parent_id",
    "wiki_data_id",
    "flag",
]

# SQL value coercion per field (dr5hn has STRING values for some numeric fields)
def to_sql_value(field: str, value):
    """Convert a dr5hn value to a SQL literal."""
    if value is None:
        return "NULL"
    if field in ("level", "parent_id", "flag"):
        # Numeric - dr5hn has these as strings/null
        try:
            return str(int(value))
        except (ValueError, TypeError):
            return "NULL"
    # String fields
    s = str(value).replace("'", "''")  # escape single quotes
    return f"'{s}'"


def build_batch_update(cities: list[dict]) -> str:
    """Build a single multi-column UPDATE for a batch of cities."""
    if not cities:
        return ""

    lines = [f"-- Batch: {len(cities)} cities (ids {cities[0]['id']}..{cities[-1]['id']})"]
    lines.append("UPDATE cities SET")

    # For each field, build a CASE expression
    field_parts = []
    for field in ENRICHMENT_FIELDS:
        cases = []
        for c in cities:
            v = c.get(field)
            sql_v = to_sql_value(field, v)
            cases.append(f"WHEN {c['id']} THEN {sql_v}")
        case_expr = f"  {field} = CASE id\n    " + "\n    ".join(cases) + "\n  END"
        field_parts.append(case_expr)

    lines.append(",\n".join(field_parts) + "\n")
    lines.append(f"WHERE id IN ({','.join(str(c['id']) for c in cities)});")
    lines.append("")
    return "\n".join(lines)


def main():
    if len(sys.argv) < 3:
        print("Usage: cities_enrichment.py <cities.json> <output_dir>")
        sys.exit(1)

    cities_path = sys.argv[1]
    output_dir = sys.argv[2]
    os.makedirs(output_dir, exist_ok=True)

    print(f"Loading {cities_path}...", file=sys.stderr)
    with open(cities_path) as f:
        cities = json.load(f)
    print(f"  total: {len(cities):,} cities", file=sys.stderr)

    # Sort by id for cleaner SQL output
    cities.sort(key=lambda c: c["id"])

    # Split into NUM_SPLITS files
    chunks = [cities[i::NUM_SPLITS] for i in range(NUM_SPLITS)]
    for idx, chunk in enumerate(chunks):
        if not chunk:
            continue
        chunk.sort(key=lambda c: c["id"])
        out_path = os.path.join(output_dir, f"127_cities_enrichment_pt{idx+1}.sql")
        print(f"Building {out_path} ({len(chunk):,} cities)...", file=sys.stderr)

        with open(out_path, "w") as f:
            f.write(f"""-- Migration 127 (part {idx+1} of {NUM_SPLITS}): Import dr5hn cities enrichment
-- Source: dr5hn countries-states-cities-database
-- Cities: {len(chunk):,} (ids {chunk[0]['id']}..{chunk[-1]['id']})
-- Fields: {', '.join(ENRICHMENT_FIELDS)}
--
-- Overrides our existing 'place_type' with dr5hn's 33-distinct-value 'type'
-- taxonomy (city, adm2, adm3, district, regency, etc.).
-- All UPDATEs are idempotent (CASE-WHEN, same value on re-run).

""")
            for i in range(0, len(chunk), BATCH_SIZE):
                batch = chunk[i:i + BATCH_SIZE]
                f.write(build_batch_update(batch) + "\n")

        size_mb = os.path.getsize(out_path) / (1024 * 1024)
        print(f"  wrote {out_path} ({size_mb:.1f} MB)", file=sys.stderr)

    print(f"\nDone. {NUM_SPLITS} files written to {output_dir}/", file=sys.stderr)


if __name__ == "__main__":
    main()
