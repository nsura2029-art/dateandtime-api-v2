#!/usr/bin/env python3
"""
scripts/seed/acs_tenure_transport_to_sql.py

M11.5.1 expand 2: ACS 5-Year Tenure (B25003) + Transportation to Work (B08301)

Generates a single SQL file with all 14,450 INSERT statements for
us_acs_tenure_attributes and us_acs_transport_attributes, joined via
fips_geoid to our cities.

Then use `wrangler d1 execute --file=` to bulk-insert.

B25003 columns (3 estimates):
  E001: Total occupied housing units
  E002: Owner occupied
  E003: Renter occupied

B08301 columns (21 estimates):
  E001: Total workers 16+
  E002: Car, truck, or van (total)
  E003: Car - drove alone
  E004: 2-person carpool
  E005: 3+ person carpool
  E006: Carpooled (total)
  E007: Public transportation (total)
  E008: Subway/elevated rail
  E009: Long-distance train/commuter rail
  E010: Light rail/streetcar
  E011: Bus
  E012: Taxicab
  E013: Motorcycle
  E014: Bicycle
  E015: Walked
  E016: Other means
  E017: Worked at home
"""
import os
import sys
from datetime import datetime, timezone

TENURE_FILE = "tmp/acsdt5y2022-b25003.dat"
TRANSPORT_FILE = "tmp/acsdt5y2022-b08301.dat"
PLACE_PREFIX = "1600000US"
RELEASE_ID = "acs-5y-2022-b25003-b08301"
OUT_SQL = "tmp/tenure_transport_inserts.sql"


def get_fips_set() -> set:
    """Get all FIPS place codes we have in cities (for filtering ACS data)."""
    import json, urllib.request
    TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")
    if not TOKEN:
        print("  WARNING: CLOUDFLARE_API_TOKEN not set, will load all places")
        return set()

    body = json.dumps({"sql": "SELECT DISTINCT fips_geoid FROM cities WHERE fips_geoid IS NOT NULL AND fips_geoid != ''"}).encode()
    req = urllib.request.Request(
        "https://api.cloudflare.com/client/v4/accounts/f0de6c4b68becd81e60507ecf9410199/d1/database/ab54b1d7-6791-4d29-a94c-c95e6a560b7e/query",
        data=body, method="POST",
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=30) as r:
        resp = json.loads(r.read().decode())
    return {r["fips_geoid"] for r in resp["result"][0]["results"]}


def parse_tenure(path: str, fips_set: set) -> dict:
    """Parse B25003. Returns {fips: (total, owner, renter)}."""
    result = {}
    with open(path, "r", encoding="utf-8") as f:
        f.readline()  # header
        for line in f:
            cols = line.rstrip("\n").split("|")
            if len(cols) < 4:
                continue
            geo_id = cols[0]
            if not geo_id.startswith(PLACE_PREFIX):
                continue
            fips = geo_id[len(PLACE_PREFIX):]
            if fips_set and fips not in fips_set:
                continue
            def col(n):
                v = cols[n]
                if not v or v == "null" or v == "-888888888":
                    return None
                try:
                    return int(v)
                except ValueError:
                    return None
            # B25003 columns: GEO_ID(0) | E001(1) | M001(2) | E002(3) | M002(4) | E003(5) | M003(6)
            total = col(1)
            owner = col(3)
            renter = col(5)
            if total is None:
                continue
            result[fips] = (total, owner or 0, renter or 0)
    return result


def parse_transport(path: str, fips_set: set) -> dict:
    """Parse B08301. Returns {fips: (e001..e021)}.
    Note: B08301 is a cross-tab (transport mode × earnings), so we just store
    all 21 raw estimate columns without trying to compute rollups.
    """
    result = {}
    with open(path, "r", encoding="utf-8") as f:
        f.readline()
        for line in f:
            cols = line.rstrip("\n").split("|")
            if len(cols) < 42:
                continue
            geo_id = cols[0]
            if not geo_id.startswith(PLACE_PREFIX):
                continue
            fips = geo_id[len(PLACE_PREFIX):]
            if fips_set and fips not in fips_set:
                continue
            def col(n):
                v = cols[n]
                if not v or v == "null" or v == "-888888888":
                    return None
                try:
                    return int(v)
                except ValueError:
                    return None
            # E001 at column 1, E002 at col 3, ..., E021 at col 41
            # Pattern: E{n} at column 2n-1
            e_vals = []
            for n in range(1, 22):
                e_vals.append(col(2 * n - 1))
            if e_vals[0] is None:
                continue
            result[fips] = tuple(e_vals)
    return result


def main():
    print("Step 1: Get FIPS place codes from cities ...")
    fips_set = get_fips_set()
    if fips_set:
        print(f"  Got {len(fips_set):,} FIPS place codes")

    print("\nStep 2: Parse ACS files ...")
    tenure = parse_tenure(TENURE_FILE, fips_set)
    print(f"  Tenure: {len(tenure):,} records")
    transport = parse_transport(TRANSPORT_FILE, fips_set)
    print(f"  Transport: {len(transport):,} records")

    print("\nStep 3: Generate SQL ...")
    now_ms = int(datetime.now(timezone.utc).timestamp() * 1000)

    # Tenure: 9 cols, BATCH = 11 (11 * 9 = 99 vars)
    TENURE_BATCH = 11
    # Transport: 26 cols (e001..e021, 3 rollups, acs_year, release_id, fetched_at), BATCH = 3 (3*26=78 vars)
    TRANSPORT_BATCH = 3

    n_tenure = 0
    n_transport = 0
    n_stmts = 0

    with open(OUT_SQL, "w", encoding="utf-8") as f:
        f.write(f"-- M11.5.1 expand 2: Tenure + Transport INSERTs\n")
        f.write(f"-- {len(tenure):,} tenure + {len(transport):,} transport records\n")
        f.write(f"-- Generated {datetime.now(timezone.utc).isoformat()}\n\n")

        # Tenure batch
        tenure_items = list(tenure.items())
        for i in range(0, len(tenure_items), TENURE_BATCH):
            chunk = tenure_items[i:i + TENURE_BATCH]
            values = []
            for fips, (total, owner, renter) in chunk:
                owner_pct = round(owner * 100 * 10 / total) / 10 if total > 0 else None
                renter_pct = round(renter * 100 * 10 / total) / 10 if total > 0 else None
                owner_s = "null" if owner_pct is None else f"{owner_pct}"
                renter_s = "null" if renter_pct is None else f"{renter_pct}"
                values.append(
                    f"('{fips}',{total},{owner},{renter},{owner_s},{renter_s},2022,'{RELEASE_ID}',{now_ms})"
                )
            f.write("INSERT OR REPLACE INTO us_acs_tenure_attributes "
                    "(fips_geoid, total_occupied, owner_occupied, renter_occupied, "
                    "owner_occupied_pct, renter_occupied_pct, acs_year, release_id, fetched_at) VALUES\n  "
                    + ",\n  ".join(values) + ";\n")
            n_tenure += len(chunk)
            n_stmts += 1

        # Transport batch (26 cols, BATCH=3)
        transport_items = list(transport.items())
        for i in range(0, len(transport_items), TRANSPORT_BATCH):
            chunk = transport_items[i:i + TRANSPORT_BATCH]
            values = []
            for fips, e_vals in chunk:
                e_strs = ["null" if v is None else str(v) for v in e_vals]
                # Best-guess rollups: e002 (car/van), e010 (likely public transit), e021 (likely worked at home)
                car_or_van = e_vals[1] if e_vals[1] is not None else None
                public_transport = e_vals[9] if e_vals[9] is not None else None
                worked_at_home = e_vals[20] if e_vals[20] is not None else None
                car_s = "null" if car_or_van is None else str(car_or_van)
                pt_s = "null" if public_transport is None else str(public_transport)
                wah_s = "null" if worked_at_home is None else str(worked_at_home)
                values.append(
                    f"('{fips}',{','.join(e_strs)},"
                    f"{car_s},{pt_s},{wah_s},2022,'{RELEASE_ID}',{now_ms})"
                )
            f.write("INSERT OR REPLACE INTO us_acs_transport_attributes "
                    "(fips_geoid, e001, e002, e003, e004, e005, e006, e007, e008, e009, e010, "
                    "e011, e012, e013, e014, e015, e016, e017, e018, e019, e020, e021, "
                    "car_or_van, public_transport_guess, worked_at_home_guess, "
                    "acs_year, release_id, fetched_at) VALUES\n  "
                    + ",\n  ".join(values) + ";\n")
            n_transport += len(chunk)
            n_stmts += 1

    print(f"  Wrote {n_stmts:,} INSERT statements to {OUT_SQL}")
    print(f"  Tenure: {n_tenure:,} records")
    print(f"  Transport: {n_transport:,} records")


if __name__ == "__main__":
    main()
