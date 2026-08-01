#!/usr/bin/env python3
"""
Generate SQL migration files to import dr5hn postcodes.

844,248 rows from /tmp/dr5hn/postcodes.json. Split into N files of ~5-7MB
each (D1 has 10MB per-request limit).

Strategy:
- Use INSERT OR IGNORE INTO postcodes VALUES (...), (...), (...)
- Batch 100 rows per INSERT
- 844,248 / 100 = 8,443 statements per file
- Split into 20 files of ~422 statements each (6.4MB each)
- nearest_city_id is NULL initially; populated by M4.5 polygon script

Note: city_id is always NULL in dr5hn data, so we don't insert it.
"""
import json
import os
import sys

BATCH_SIZE = 100  # rows per INSERT
NUM_SPLITS = 20   # ~42K rows per file = 5-6 MB each


def to_sql_value(value, field=None):
    """Convert dr5hn value to SQL literal."""
    if value is None:
        return "NULL"
    if field in ("id", "country_id", "state_id", "city_id"):
        try:
            return str(int(value))
        except (ValueError, TypeError):
            return "NULL"
    if field in ("latitude", "longitude"):
        try:
            return str(float(value))
        except (ValueError, TypeError):
            return "NULL"
    # String
    s = str(value).replace("'", "''")  # escape
    return f"'{s}'"


def build_batch_inserts(batch: list[dict]) -> str:
    """Build INSERT statement for a batch of postcodes."""
    if not batch:
        return ""
    # Field list (without city_id since dr5hn always has it NULL; we use nearest_city_id)
    fields = [
        "id", "code", "country_id", "country_code", "state_id", "state_code",
        "locality_name", "type", "latitude", "longitude", "source", "wiki_data_id",
    ]
    field_list = ", ".join(fields)
    rows = []
    for p in batch:
        vals = [to_sql_value(p.get(f), f) for f in fields]
        rows.append(f"  ({', '.join(vals)})")
    return f"INSERT OR IGNORE INTO postcodes ({field_list}) VALUES\n" + ",\n".join(rows) + ";"


def main():
    if len(sys.argv) < 3:
        print("Usage: postcodes_import.py <postcodes.json> <output_dir>")
        sys.exit(1)

    src = sys.argv[1]
    out_dir = sys.argv[2]
    os.makedirs(out_dir, exist_ok=True)

    print(f"Loading {src}...", file=sys.stderr)
    with open(src) as f:
        data = json.load(f)
    print(f"  total: {len(data):,} postcodes", file=sys.stderr)

    # Sort by id for cleaner SQL
    data.sort(key=lambda p: p["id"])

    # Split into NUM_SPLITS files
    chunks = [data[i::NUM_SPLITS] for i in range(NUM_SPLITS)]

    for idx, chunk in enumerate(chunks):
        if not chunk:
            continue
        out_path = os.path.join(out_dir, f"129_postcodes_pt{idx+1:02d}.sql")
        with open(out_path, "w") as f:
            f.write(f"""-- Migration 129 (part {idx+1:02d} of {NUM_SPLITS}): Import dr5hn postcodes
-- Source: dr5hn postcodes.json ({len(data):,} rows total)
-- This part: {len(chunk):,} rows (ids {chunk[0]['id']}..{chunk[-1]['id']})
-- All idempotent (INSERT OR IGNORE).

""")
            for i in range(0, len(chunk), BATCH_SIZE):
                batch = chunk[i:i + BATCH_SIZE]
                f.write(build_batch_inserts(batch) + "\n\n")
        size_mb = os.path.getsize(out_path) / (1024 * 1024)
        print(f"  wrote {out_path} ({size_mb:.1f} MB, {len(chunk):,} rows)", file=sys.stderr)

    # Also generate migration 129a (drop the unused city_id index if it exists)
    with open("migrations/129a_postcodes_index_cleanup.sql", "w") as f:
        f.write("""-- Migration 129a: Drop unused city_id index (always NULL in dr5hn data)
-- city_id is always NULL in dr5hn postcodes, so the index is unused.
-- nearest_city_id (from migration 128) has its own index.

DROP INDEX IF EXISTS idx_postcodes_city;

INSERT OR IGNORE INTO migrations (version, description) VALUES
  ('129_postcodes_import', 'Import dr5hn postcodes.json (844,248 rows in 20 parts)'),
  ('129a_postcodes_index_cleanup', 'Drop unused city_id index (always NULL)');
""")

    print(f"\nDone. {NUM_SPLITS} files written to {out_dir}/", file=sys.stderr)


if __name__ == "__main__":
    main()
