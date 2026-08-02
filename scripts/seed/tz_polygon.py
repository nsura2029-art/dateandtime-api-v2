#!/usr/bin/env python3
"""
Resolve canonical IANA timezones for ALL cities in D1 via timezone polygon
lookup (timezone-boundary-builder data via the `timezonefinder` library).

This is the SPEC-MANDATED method: coordinates → polygon → IANA TZ.
Country/state/administrative-region is never used as the primary source.

Usage:
    python3 scripts/seed/tz_polygon.py [--output tmp/city_tz.csv]

Outputs CSV: city_id,lat,lon,polygon_tz,canonical_tz,current_tz
"""
import argparse
import csv
import json
import subprocess
import sys
from timezonefinder import TimezoneFinder


# Canonical IANA aliases (timezonefinder returns these legacy IDs sometimes;
# spec section 8.1 mandates we store canonical IDs).
CANONICALIZE = {
    # US legacy zones
    "US/Eastern": "America/New_York",
    "US/Central": "America/Chicago",
    "US/Mountain": "America/Denver",
    "US/Pacific": "America/Los_Angeles",
    "US/Alaska": "America/Anchorage",
    "US/Aleutian": "America/Adak",
    "US/Arizona": "America/Phoenix",
    "US/Hawaii": "Pacific/Honolulu",
    "US/Indiana-Starke": "America/Indiana/Knox",
    "US/Michigan": "America/Detroit",
    "US/Samoa": "Pacific/Pago_Pago",
    # Asia legacy
    "Asia/Calcutta": "Asia/Kolkata",
    "Asia/Rangoon": "Asia/Yangon",
    "Asia/Saigon": "Asia/Ho_Chi_Minh",
    "Asia/Katmandu": "Asia/Kathmandu",
    "Asia/Tel_Aviv": "Asia/Jerusalem",
    # Russia legacy
    "Europe/Moscow": "Europe/Moscow",  # canonical
    # Canada legacy
    "Canada/Atlantic": "America/Halifax",
    "Canada/Central": "America/Winnipeg",
    "Canada/Eastern": "America/Toronto",
    "Canada/Mountain": "America/Edmonton",
    "Canada/Newfoundland": "America/St_Johns",
    "Canada/Pacific": "America/Vancouver",
    "Canada/Saskatchewan": "America/Regina",
    "Canada/Yukon": "America/Whitehorse",
    # Mexico legacy
    "Mexico/BajaNorte": "America/Tijuana",
    "Mexico/BajaSur": "America/Mazatlan",
    "Mexico/General": "America/Mexico_City",
    # Brazil legacy
    "Brazil/Acre": "America/Rio_Branco",
    "Brazil/DeNoronha": "America/Noronha",
    "Brazil/East": "America/Sao_Paulo",
    "Brazil/West": "America/Manaus",
    # Chile legacy
    "Chile/Continental": "America/Santiago",
    "Chile/EasterIsland": "Pacific/Easter",
    # Etc
    "EST": "America/New_York",
    "EST5EDT": "America/New_York",
    "CST6CDT": "America/Chicago",
    "MST7MDT": "America/Denver",
    "PST8PDT": "America/Los_Angeles",
    "HST": "Pacific/Honolulu",
    # Pacific
    "Pacific/Saipan": "Pacific/Guam",  # per spec 9.3 - canonicalize to Pacific/Guam
}


def canonicalize(tz: str | None) -> str | None:
    if tz is None:
        return None
    return CANONICALIZE.get(tz, tz)


def fetch_all_cities() -> list[dict]:
    """Fetch all cities from D1 in chunks. Returns list of {id, lat, lon, current_tz}."""
    print("Fetching all cities from D1 (chunked)...", file=sys.stderr)
    cities: list[dict] = []
    offset = 0
    chunk = 5000
    while True:
        result = subprocess.run(
            [
                "npx", "wrangler", "d1", "execute", "timeandtimepro-full-v2",
                "--env", "dev", "--remote", "--json",
                "--command",
                f"SELECT id, latitude, longitude, timezone FROM cities LIMIT {chunk} OFFSET {offset};",
            ],
            capture_output=True, text=True, timeout=120, cwd="/workspace/dateandtime-api-v2",
        )
        text = result.stdout.strip()
        batch = []
        try:
            if text.startswith("["):
                data = json.loads(text)
                batch = data[0].get("results", [])
            else:
                idx = text.find('"results": [')
                if idx == -1:
                    break
                end = text.find("]", idx + len('"results": ['))
                end2 = text.find("]", end + 1)
                array_text = text[idx + len('"results": '):end2 + 1]
                data = json.loads(array_text)
                batch = data if isinstance(data, list) else []
        except Exception as e:
            print(f"  parse error: {e}", file=sys.stderr)
            break
        if not batch:
            break
        cities.extend(batch)
        offset += chunk
        if offset % 20000 == 0:
            print(f"  ...{offset:,} fetched", file=sys.stderr)
        if len(batch) < chunk:
            break
    print(f"  total: {len(cities):,}", file=sys.stderr)
    return cities


def resolve_timezones(cities: list[dict]) -> list[dict]:
    """Use timezonefinder to resolve each city's IANA timezone from lat/lon."""
    print("Initializing timezonefinder (loads ~50MB polygon data)...", file=sys.stderr)
    tf = TimezoneFinder()
    print("Resolving timezones via polygons...", file=sys.stderr)

    out = []
    n = len(cities)
    for i, c in enumerate(cities):
        lat = c.get("latitude")
        lon = c.get("longitude")
        polygon_tz = None
        if lat is not None and lon is not None and -90 <= lat <= 90 and -180 <= lon <= 180:
            polygon_tz = tf.timezone_at(lng=lon, lat=lat)
        out.append({
            "city_id": c["id"],
            "lat": lat,
            "lon": lon,
            "polygon_tz": polygon_tz,
            "canonical_tz": canonicalize(polygon_tz),
            "current_tz": c.get("timezone"),
        })
        if (i + 1) % 20000 == 0:
            print(f"  ...{i+1:,}/{n:,} resolved", file=sys.stderr)
    print(f"  done: {n:,}", file=sys.stderr)
    return out


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--output", default="tmp/city_tz.csv")
    args = parser.parse_args()

    cities = fetch_all_cities()
    resolved = resolve_timezones(cities)

    # Write CSV
    with open(args.output, "w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=["city_id", "lat", "lon", "polygon_tz", "canonical_tz", "current_tz"])
        w.writeheader()
        w.writerows(resolved)
    print(f"\nWrote {args.output}", file=sys.stderr)

    # Quick stats
    n = len(resolved)
    null_coord = sum(1 for r in resolved if r["lat"] is None or r["lon"] is None)
    no_polygon = sum(1 for r in resolved if r["lat"] is not None and r["polygon_tz"] is None)
    mismatch = sum(1 for r in resolved if r["canonical_tz"] and r["current_tz"] and r["canonical_tz"] != r["current_tz"])
    alias_canonicalized = sum(1 for r in resolved if r["polygon_tz"] and r["polygon_tz"] != r["canonical_tz"])

    print(f"\nStats ({n:,} cities):", file=sys.stderr)
    print(f"  NULL coords (unresolved): {null_coord:,}", file=sys.stderr)
    print(f"  No polygon match: {no_polygon:,}", file=sys.stderr)
    print(f"  Mismatch (current != polygon): {mismatch:,}", file=sys.stderr)
    print(f"  Alias canonicalized: {alias_canonicalized:,}", file=sys.stderr)


if __name__ == "__main__":
    main()
