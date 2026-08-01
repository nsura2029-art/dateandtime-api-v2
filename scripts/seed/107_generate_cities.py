#!/usr/bin/env python3
"""
Generate cities seed (152,970 rows from dr5hn) as per-country SQL files.

Output:
  - migrations/cities/{cca2}.sql — one file per country (250 files)
  - migrations/cities/run-all.sh — wrapper script to apply all 250 files

Why per-country:
  - 152,970 cities = ~23MB of SQL (too big for one file)
  - 250 files × ~90KB each = manageable
  - User can re-run individual countries if one fails
  - Easy to see which countries are missing

Usage:
  python3 scripts/seed/107_generate_cities.py
  bash migrations/cities/run-all.sh
"""
import json
import urllib.request
import os
from pathlib import Path
from collections import defaultdict

DOWNLOAD_URL = (
    "https://raw.githubusercontent.com/dr5hn/countries-states-cities-database/"
    "master/json/countries+states+cities.json"
)
TMP_FILE = "/tmp/countries-states-cities.json"
OUTPUT_DIR = Path("migrations/cities")


def escape_sql(s):
    if s is None:
        return 'NULL'
    return "'" + str(s).replace("'", "''") + "'"


# Load state → timezone map for better per-city timezone accuracy
STATE_TZ_MAP = {}
try:
    with open('scripts/seed/state-tz-map.json') as f:
        STATE_TZ_MAP = json.load(f)
    print(f"  Loaded state→tz map for {len([k for k in STATE_TZ_MAP if not k.startswith('_')])} countries")
except FileNotFoundError:
    print("  No state-tz-map.json found, using country-level timezones only")


def main():
    # Download
    print("=== Downloading dr5hn source data ===")
    if not os.path.exists(TMP_FILE):
        print(f"  Downloading {DOWNLOAD_URL}...")
        urllib.request.urlretrieve(DOWNLOAD_URL, TMP_FILE)
    print(f"  → {TMP_FILE}")

    # Load
    with open(TMP_FILE) as f:
        data = json.load(f)
    print(f"  Countries in file: {len(data)}")

    # Build country map and state name → id map per country
    country_by_id = {c['id']: c for c in data}
    state_name_to_id = {}  # (country_id, state_name) -> state_id
    for c in data:
        for s in c.get('states', []):
            state_name_to_id[(c['id'], s.get('name'))] = s['id']

    # Collect cities per country
    cities_by_country = defaultdict(list)
    total_cities = 0
    for c in data:
        country_id = c['id']
        for state in c.get('states', []):
            state_code = state.get('iso2')  # e.g. 'AK', 'AL' for US states
            state_tz = state.get('timezone')  # state-level default
            for city in state.get('cities', []):
                cities_by_country[country_id].append({
                    'id': city['id'],
                    'name': city.get('name'),
                    'country_id': country_id,
                    'state_id': state['id'],
                    '_state_code': state_code,  # for state-level tz lookup (internal)
                    'latitude': city.get('latitude'),
                    'longitude': city.get('longitude'),
                    'timezone': city.get('timezone') or state_tz,  # city tz > state tz > country default
                    'population': None,
                    'feature_code': None,
                })
                total_cities += 1

    # Now find timezones for cities by re-walking data with timezone info
    # (The countries+cities.json has timezone inside city object, but
    # the structure is `cities` as list of names. Let me re-fetch.)
    # Use the simpler countries+cities.json to get timezone per city name+country
    print(f"  Total cities: {total_cities}")

    cities_simple_url = (
        "https://raw.githubusercontent.com/dr5hn/countries-states-cities-database/"
        "master/json/countries+cities.json"
    )
    cities_simple_tmp = "/tmp/countries-cities.json"
    if not os.path.exists(cities_simple_tmp):
        print(f"  Downloading {cities_simple_url}...")
        urllib.request.urlretrieve(cities_simple_url, cities_simple_tmp)
    with open(cities_simple_tmp) as f:
        cities_simple = json.load(f)

    # This file has only city NAMES (no timezones, no lat/lon).
    # So we can't use it for timezones. Timezone data is only in countries+states+cities.json
    # which we've already loaded.

    # Re-walk: look at city timezones from the bigger file
    # Actually, dr5hn's countries+states+cities.json has timezones only on the country level.
    # Individual cities don't have a timezone field in dr5hn.
    # We'll default to the country's first canonical_timezone.
    # EXCEPT for countries with a state→tz map (US, CA, AU, BR, MX, RU)
    # where we use the state-level timezone.

    for c in data:
        country_id = c['id']
        cca2 = c.get('iso2')
        # Get default timezone from country
        country_tz = None
        timezones = c.get('timezones', [])
        if timezones and isinstance(timezones, list):
            country_tz = timezones[0].get('zoneName') if isinstance(timezones[0], dict) else None

        # State-level timezone map for this country
        country_state_tz = STATE_TZ_MAP.get(cca2, {})

        for city in cities_by_country.get(country_id, []):
            # Try state-level map first (e.g. US states → timezones)
            state_code = city.get('_state_code')
            if state_code and state_code in country_state_tz:
                city['timezone'] = country_state_tz[state_code]
            elif not city.get('timezone'):
                city['timezone'] = country_tz

    # Make output dir
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Build country map (cca2 -> dr5hn_id)
    country_id_to_cca2 = {c['id']: c.get('iso2') for c in data}
    cca2_to_country_id = {cca2: cid for cid, cca2 in country_id_to_cca2.items()}

    BATCH = 8  # 12 columns × 8 = 96 vars (under D1 100 limit)

    # Write per-country files
    file_list = []
    for cca2, country_id in sorted(cca2_to_country_id.items()):
        cities = cities_by_country.get(country_id, [])
        if not cities:
            continue

        country_name = country_by_id[country_id].get('name', cca2)

        chunks = [cities[i:i+BATCH] for i in range(0, len(cities), BATCH)]

        parts = [
            f"-- Cities for {cca2} ({country_name}): {len(cities)} cities from dr5hn",
            f"-- Generated by: scripts/seed/107_generate_cities.py",
            "",
            "INSERT INTO cities (id, name, country_id, state_id, latitude, longitude, timezone, population, feature_code, place_type, source_id, source_version) VALUES",
        ]
        for chunk in chunks:
            rows = []
            for city in chunk:
                row = f"""  ({city['id']}, {escape_sql(city['name'])}, {city['country_id']}, {city['state_id']}, {city['latitude'] or 'NULL'}, {city['longitude'] or 'NULL'}, {escape_sql(city['timezone'])}, {city['population'] or 'NULL'}, {escape_sql(city['feature_code'])}, 'city', 'dr5hn:{city['id']}', 'dr5hn-2026-07-29')"""
                rows.append(row)
            parts.append(",\n".join(rows) + ";")
        parts.append("")  # trailing newline

        out_file = OUTPUT_DIR / f"{cca2}.sql"
        out_file.write_text("\n".join(parts))
        file_list.append((cca2, len(cities), str(out_file)))

    # Write run-all.sh
    run_all = ["#!/usr/bin/env bash", "# Apply all 250 country-city seed files in order.", "# Usage: bash migrations/cities/run-all.sh", "", "set -e", ""]
    for cca2, count, path in file_list:
        run_all.append(f'# {cca2}: {count} cities')
        run_all.append(f'wrangler d1 execute timeandtimepro-full --env dev --remote --file="{path}"')
    run_all.append("")
    run_all.append('echo "✅ All cities seeded."')
    Path(OUTPUT_DIR / "run-all.sh").write_text("\n".join(run_all))
    os.chmod(OUTPUT_DIR / "run-all.sh", 0o755)

    print(f"\n=== Generated {len(file_list)} country files in {OUTPUT_DIR}/ ===")
    for cca2, count, path in file_list[:10]:
        print(f"  {cca2}: {count} cities → {path}")
    print(f"  ... ({len(file_list) - 10} more)")
    print(f"\n  Total cities: {sum(c for _, c, _ in file_list)}")
    print(f"  Wrapper: {OUTPUT_DIR}/run-all.sh")


if __name__ == '__main__':
    main()
