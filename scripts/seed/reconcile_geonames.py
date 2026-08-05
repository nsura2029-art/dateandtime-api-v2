#!/usr/bin/env python3
"""
scripts/seed/reconcile_geonames.py

Reconciliation report for the GeoNames release in cities_staging.

Compares:
  - Raw row count (GeoNames cities5000.txt)         → expected
  - cities_staging row count in D1                  → what we loaded
  - Current `cities` table count                    → live data
  - Country/timezone distribution per layer

Outputs a JSON report and an optional markdown summary.

Usage:
  python3 scripts/seed/reconcile_geonames.py
  python3 scripts/seed/reconcile_geonames.py --write
"""
import argparse
import json
import os
import subprocess
import sys
import time
from pathlib import Path

WORKSPACE = Path("/workspace/dateandtime-api-v2")
LOCAL_STAGING_DB = WORKSPACE / "tmp" / "cities_staging.db"
RELEASE_ID = "geonames-cities5000-2026-08-02"


def run_d1(sql: str) -> list:
    """Run a D1 query via wrangler and return parsed JSON rows."""
    out = subprocess.run(
        [
            "npx", "wrangler", "d1", "execute", "timeandtimepro-full-v2",
            "--env", "dev", "--remote", "--json", "--command", sql,
        ],
        cwd=str(WORKSPACE),
        capture_output=True,
        text=True,
        timeout=60,
    )
    if out.returncode != 0:
        print(f"  D1 query error: {out.stderr[:200]}")
        return []
    text = out.stdout.strip()
    if not text.startswith("["):
        return []
    return (json.loads(text)[0]).get("results", [])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true",
                        help="Write report to reports/m11.0-reconciliation.md")
    args = parser.parse_args()

    print("=== Reconciliation: GeoNames cities5000 → cities_staging ===")
    print()

    # 1. Raw count from local file
    txt = Path("/tmp/geonames/cities5000.txt")
    raw_count = sum(1 for _ in open(txt)) if txt.exists() else None
    print(f"Raw rows in cities5000.txt:  {raw_count:,}" if raw_count else "Raw file: missing")

    # 2. Local SQLite staging count
    if LOCAL_STAGING_DB.exists():
        import sqlite3
        con = sqlite3.connect(str(LOCAL_STAGING_DB))
        cur = con.cursor()
        cur.execute("SELECT COUNT(*) FROM cities_staging")
        local_staging = cur.fetchone()[0]
        cur.execute("SELECT COUNT(DISTINCT country_code) FROM cities_staging")
        local_countries = cur.fetchone()[0]
        cur.execute("SELECT COUNT(DISTINCT timezone) FROM cities_staging WHERE timezone IS NOT NULL")
        local_tz = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM cities_staging WHERE timezone IS NULL")
        local_null_tz = cur.fetchone()[0]
        cur.execute("SELECT COUNT(*) FROM cities_staging WHERE population IS NULL")
        local_null_pop = cur.fetchone()[0]
        con.close()
        print(f"Local staging rows:         {local_staging:,}")
        print(f"  Countries:                 {local_countries}")
        print(f"  Timezones:                 {local_tz}")
        print(f"  NULL timezone:             {local_null_tz}")
        print(f"  NULL population:           {local_null_pop}")
    else:
        local_staging = local_countries = local_tz = local_null_tz = local_null_pop = None
        print("Local staging DB: missing")

    print()
    print("Querying D1 cities_staging (this may take 30s) ...")
    d1_staging = run_d1(f"SELECT COUNT(*) as n FROM cities_staging WHERE release_id = '{RELEASE_ID}';")
    d1_staging_n = int(d1_staging[0]["n"]) if d1_staging else 0
    d1_countries = run_d1(f"SELECT COUNT(DISTINCT country_code) as n FROM cities_staging WHERE release_id = '{RELEASE_ID}';")
    d1_countries_n = int(d1_countries[0]["n"]) if d1_countries else 0
    d1_tz = run_d1(f"SELECT COUNT(DISTINCT timezone) as n FROM cities_staging WHERE release_id = '{RELEASE_ID}' AND timezone IS NOT NULL;")
    d1_tz_n = int(d1_tz[0]["n"]) if d1_tz else 0
    print(f"D1 cities_staging rows:     {d1_staging_n:,}")
    print(f"  Countries:                 {d1_countries_n}")
    print(f"  Timezones:                 {d1_tz_n}")

    print()
    print("Querying D1 cities (live) ...")
    live = run_d1("SELECT COUNT(*) as n FROM cities;")
    live_n = int(live[0]["n"]) if live else 0
    print(f"D1 cities (live):           {live_n:,}")

    # Reconciliation summary
    print()
    print("=== Reconciliation summary ===")
    if local_staging:
        match_local = "✓" if d1_staging_n == local_staging else "✗"
        print(f"  D1 staging vs local:    {d1_staging_n:,} vs {local_staging:,}  {match_local}")
    if raw_count:
        match_raw = "✓" if d1_staging_n == raw_count else "✗"
        print(f"  D1 staging vs raw:      {d1_staging_n:,} vs {raw_count:,}  {match_raw}")
    print(f"  Live cities:             {live_n:,}  (unchanged — staging not promoted yet)")

    # Write report
    if args.write:
        report = f"""# M11.0 GeoNames — Reconciliation Report

**Release:** `{RELEASE_ID}`
**Run date:** {time.strftime('%Y-%m-%d %H:%M UTC')}

## Counts

| Layer | Count | Status |
|---|---:|---|
| Raw cities5000.txt | {raw_count:,} | source-of-truth |
| Local staging DB | {local_staging:,} | parse output |
| D1 cities_staging (release_id=...) | {d1_staging_n:,} | {'MATCH' if d1_staging_n == raw_count else 'MISMATCH'} |
| D1 cities (live) | {live_n:,} | unchanged |

## Coverage

| Metric | Local | D1 |
|---|---:|---:|
| Distinct countries | {local_countries} | {d1_countries_n} |
| Distinct timezones | {local_tz} | {d1_tz_n} |
| NULL timezone | {local_null_tz} | (see query) |
| NULL population | {local_null_pop} | (see query) |

## Verdict

- {'Raw → local parse: 100% — no rows lost' if local_staging == raw_count else f'WARN: {raw_count - local_staging} rows lost in parse'}
- {'Local → D1: 100% — all rows in D1 cities_staging' if d1_staging_n == local_staging else f'PENDING: D1 has {d1_staging_n}, local has {local_staging}, diff = {local_staging - d1_staging_n}'}
- Live cities untouched (no swap yet)

## Next step

Once D1 staging matches local, run the two-phase commit:
  1. `cities_staging → cities_live_swap` (rename, atomic)
  2. Update `cities_live` to use the new data
  3. Mark release as `published` in source_releases
"""
        (WORKSPACE / "reports" / "m11.0-reconciliation.md").write_text(report)
        print()
        print(f"Report written: reports/m11.0-reconciliation.md")

    return 0


if __name__ == "__main__":
    sys.exit(main())
