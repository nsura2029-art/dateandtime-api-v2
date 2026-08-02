#!/usr/bin/env python3
"""
Generate SQL migration files to import dr5hn translations.csv.

2,965,565 rows from /tmp/dr5hn/translations.csv. Split into N files of ~5-7MB
each (D1 has 10MB per-request limit).

Schema (migration 130):
  place_id INTEGER NOT NULL
  place_type TEXT NOT NULL  -- city|state|country|subregion|region
  language TEXT NOT NULL    -- ISO 639-1: ja, es, ar, etc.
  translation TEXT NOT NULL
  PRIMARY KEY (place_id, place_type, language)

Strategy:
- BATCH_SIZE = 20 (4 cols × 20 = 80 vars, safe under 100-var limit)
- 2,965,565 / 20 = 148,278 INSERT statements
- Split into 30 files of ~4,943 statements each = ~5-6MB per file
- All idempotent (INSERT OR IGNORE)

Note: We DON'T add FK to the translations table because place_id can
reference different tables based on place_type. We validate via index queries
post-import instead.
"""
import csv
import os
import sys

BATCH_SIZE = 20  # rows per INSERT (4 cols × 20 = 80 vars, under 100 limit)
NUM_SPLITS = 30  # ~99K rows per file = ~5-6 MB each


def to_sql_value(value: str | None) -> str:
    """Convert dr5hn value to SQL literal."""
    if value is None:
        return "NULL"
    s = str(value).replace("'", "''")  # escape single quotes
    return f"'{s}'"


def build_batch_inserts(batch: list[dict]) -> str:
    """Build INSERT statement for a batch of translations."""
    if not batch:
        return ""
    fields = ["place_id", "place_type", "language", "translation"]
    field_list = ", ".join(fields)
    rows = []
    for t in batch:
        place_id = t.get("place_id", "").strip()
        place_type = t.get("place_type", "").strip()
        language = t.get("language", "").strip()
        translation = t.get("translation", "").strip()
        if not (place_id and place_type and language and translation):
            continue
        vals = [
            place_id,  # integer literal
            to_sql_value(place_type),
            to_sql_value(language),
            to_sql_value(translation),
        ]
        rows.append(f"  ({', '.join(vals)})")
    if not rows:
        return ""
    return f"INSERT OR IGNORE INTO translations ({field_list}) VALUES\n" + ",\n".join(rows) + ";"


def main():
    if len(sys.argv) < 3:
        print("Usage: translations_import.py <translations.csv> <output_dir>")
        sys.exit(1)

    src = sys.argv[1]
    out_dir = sys.argv[2]
    os.makedirs(out_dir, exist_ok=True)

    print(f"Loading {src}...", file=sys.stderr)
    rows = []
    with open(src, encoding="utf-8") as f:
        reader = csv.DictReader(f)
        for row in reader:
            rows.append(row)
    print(f"  total: {len(rows):,} translations", file=sys.stderr)

    # Sort by (place_type, place_id) for cleaner SQL and locality
    rows.sort(key=lambda r: (r["place_type"], int(r["place_id"]), r["language"]))

    # Split into NUM_SPLITS files (round-robin for better distribution)
    chunks = [rows[i::NUM_SPLITS] for i in range(NUM_SPLITS)]

    for idx, chunk in enumerate(chunks):
        if not chunk:
            continue
        out_path = os.path.join(out_dir, f"131_translations_pt{idx+1:02d}.sql")
        with open(out_path, "w", encoding="utf-8") as f:
            first = chunk[0]
            last = chunk[-1]
            f.write(f"""-- Migration 131 (part {idx+1:02d} of {NUM_SPLITS}): Import dr5hn translations
-- Source: dr5hn translations.csv ({len(rows):,} rows total)
-- This part: {len(chunk):,} rows
-- Type range: {first['place_type']} (id {first['place_id']}) to {last['place_type']} (id {last['place_id']})
-- All idempotent (INSERT OR IGNORE).
-- BATCH_SIZE = {BATCH_SIZE} (4 cols × {BATCH_SIZE} = {BATCH_SIZE*4} vars, under 100-var limit)

""")
            for i in range(0, len(chunk), BATCH_SIZE):
                batch = chunk[i:i + BATCH_SIZE]
                stmt = build_batch_inserts(batch)
                if stmt:
                    f.write(stmt + "\n\n")
        size_mb = os.path.getsize(out_path) / (1024 * 1024)
        print(f"  wrote {out_path} ({size_mb:.1f} MB, {len(chunk):,} rows)", file=sys.stderr)

    print(f"\nDone. {NUM_SPLITS} files written to {out_dir}/", file=sys.stderr)


if __name__ == "__main__":
    main()
