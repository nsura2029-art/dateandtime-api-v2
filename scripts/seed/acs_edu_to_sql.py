#!/usr/bin/env python3
"""
scripts/seed/acs_edu_to_sql.py

Generate a single SQL file with all 14,450 INSERT statements for us_acs_education_attributes.
Then use wrangler d1 execute --file= to bulk-insert.

Each statement is 8 rows (12 cols × 8 = 96 vars, under D1's 100-var limit).
"""
import os
import sys
import json
from datetime import datetime, timezone

EDUCATION_FILE = "tmp/acsdt5y2022-b15003.dat"
PLACE_PREFIX = "1600000US"
RELEASE_ID = "acs-5y-2022-b19013-b15003"
OUT_SQL = "tmp/edu_inserts.sql"


def parse_education(path: str) -> dict:
    """Parse B15003 file. Returns {fips: {fields...}}."""
    result = {}
    with open(path, "r", encoding="utf-8") as f:
        f.readline()  # header
        for line in f:
            cols = line.rstrip("\n").split("|")
            if len(cols) < 50:
                continue
            geo_id = cols[0]
            if not geo_id.startswith(PLACE_PREFIX):
                continue
            fips = geo_id[len(PLACE_PREFIX):]
            def col(n):
                v = cols[2 * n - 1]
                if not v or v == "null" or v == "-888888888":
                    return None
                try:
                    return int(v)
                except ValueError:
                    return None
            e001 = col(1)
            if e001 is None:
                continue
            less_than_hs = sum(filter(None, [col(i) for i in range(2, 17)]))
            hs_or_ged = sum(filter(None, [col(17), col(18)]))
            some_college = sum(filter(None, [col(19), col(20)]))
            assoc = col(21)
            bachelor = col(22)
            grad = sum(filter(None, [col(23), col(24), col(25)]))
            bach_higher = (assoc or 0) + (bachelor or 0) + grad
            result[fips] = (
                e001, less_than_hs, hs_or_ged, some_college, assoc, bachelor, grad, bach_higher
            )
    return result


def main():
    print("Step 1: Parse B15003 ...")
    records = parse_education(EDUCATION_FILE)
    print(f"  Got {len(records):,} place records")

    print("Step 2: Generate SQL ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)
    items = list(records.items())
    BATCH = 8  # 12 cols × 8 rows = 96 vars, safe

    with open(OUT_SQL, "w", encoding="utf-8") as f:
        f.write(f"-- M11.5.1 expand: Education INSERTs (B15003)\n")
        f.write(f"-- {len(records):,} place records, generated {datetime.now(timezone.utc).isoformat()}\n\n")
        n_stmts = 0
        for i in range(0, len(items), BATCH):
            chunk = items[i:i + BATCH]
            values = []
            for fips, (e001, lth, hsg, sc, ad, bd, gd, bho) in chunk:
                values.append(
                    f"('{fips}',{e001},{lth},{hsg},{sc},{ad},{bd},{gd},{bho},2022,'{RELEASE_ID}',{now_ms})"
                )
            f.write("INSERT OR REPLACE INTO us_acs_education_attributes "
                    "(fips_geoid, population_25_plus, less_than_hs, hs_or_ged, some_college, "
                    "associate_degree, bachelor_degree, graduate_degree, bachelor_or_higher, "
                    "acs_year, release_id, fetched_at) VALUES\n  "
                    + ",\n  ".join(values)
                    + ";\n")
            n_stmts += 1
    print(f"  Wrote {n_stmts:,} INSERT statements to {OUT_SQL}")


if __name__ == "__main__":
    main()
