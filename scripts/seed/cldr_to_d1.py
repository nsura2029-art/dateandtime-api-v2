#!/usr/bin/env python3
"""
scripts/seed/cldr_to_d1.py

M11.3: Load Unicode CLDR country/territory names into the country_names table.

Source: Unicode CLDR 48.2 (https://cldr.unicode.org/) — cldr-common-48.2.zip
After extraction: tmp/cldr-extract/common/main/<lang>.xml

Schema per <territory> element:
  - type="US"  (alpha-2 ISO 3166-1)
  - alt="short" or alt="variant" (optional)
  - text content = localized name

Strategy:
  - Only alpha-2 territory codes (skip numeric UN M.49 region codes)
  - Skip "alt=variant" entries (e.g. "Hong Kong SAR China")
  - Keep "alt=short" as separate short_name column
  - For each (country_id, language), store:
    - name = main entry
    - short_name = "alt=short" entry (if present)
  - Map countries.cca2 → countries.id (CCA2 is the link)

Target: 20 languages × ~250 countries = ~5,000 rows.

SQL approach (D1 HTTP API, same pattern as M11.2.x):
  - 9 columns: country_id, language, name, short_name, source, release_id
  - 5 binds per row: 250/5 = 50 rows per statement = 50*5 = 250 vars
  - Use CASE WHEN to batch 50 rows in one UPDATE-like INSERT
  - Actually, INSERT...SELECT with CASE WHEN doesn't work. Use multi-row VALUES.
  - But D1 rejects params + multi-statement. So:
    - 1 INSERT per HTTP call (5 binds × 1 row)
  - Parallel: 16 workers
  - Estimated time: 5,000 rows / (16 * 20 rows/s) = ~16s
"""
import os
import sys
import json
import time
import zipfile
import urllib.request
import xml.etree.ElementTree as ET
from datetime import datetime, timezone
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, as_completed

ACCOUNT = "f0de6c4b68becd81e60507ecf9410199"
DB_ID = "ab54b1d7-6791-4d29-a94c-c95e6a560b7e"
TOKEN = os.environ.get("CLOUDFLARE_API_TOKEN", "")

CLDR_URL = "https://unicode.org/Public/cldr/48.2/cldr-common-48.2.zip"
CLDR_VERSION = "cldr-48.2"
RELEASE_ID = f"cldr-territories-2026-08-02"

# Top 20 languages by traffic
TARGET_LANGUAGES = [
    "en", "es", "fr", "de", "zh", "ja", "ko", "ru", "ar", "hi",
    "pt", "it", "tr", "nl", "pl", "sv", "uk", "he", "fa", "th",
]


def http_query(sql: str, params: list = None) -> dict:
    url = f"https://api.cloudflare.com/client/v4/accounts/{ACCOUNT}/d1/database/{DB_ID}/query"
    body = {"sql": sql}
    if params:
        body["params"] = params
    payload = json.dumps(body).encode()
    req = urllib.request.Request(
        url, data=payload, method="POST",
        headers={"Authorization": f"Bearer {TOKEN}", "Content-Type": "application/json"},
    )
    try:
        with urllib.request.urlopen(req, timeout=120) as r:
            resp = json.loads(r.read().decode())
            inner = (resp.get("result") or [{}])[0]
            return {
                "ok": resp.get("success") and inner.get("success", False),
                "data": inner.get("results", []),
                "meta": inner.get("meta", {}),
                "error": (inner.get("errors", [{}])[0].get("message", "") if not inner.get("success") else ""),
            }
    except Exception as e:
        return {"ok": False, "data": [], "meta": {}, "error": str(e)}


def download_cldr(extract_dir: Path) -> Path:
    """Download and extract CLDR common XML. Returns path to common/main/"""
    zip_path = extract_dir / "cldr-common-48.2.zip"
    extract_path = extract_dir / "cldr-extract"
    main_path = extract_path / "common" / "main"
    if main_path.exists():
        print(f"  Already extracted at {main_path}")
        return main_path
    extract_dir.mkdir(parents=True, exist_ok=True)
    if not zip_path.exists():
        print(f"  Downloading {CLDR_URL} ...")
        urllib.request.urlretrieve(CLDR_URL, zip_path)
        print(f"  Downloaded {zip_path.stat().st_size / 1024 / 1024:.1f} MB")
    print(f"  Extracting ...")
    with zipfile.ZipFile(zip_path) as zf:
        zf.extractall(extract_path)
    print(f"  Extracted to {extract_path}")
    return main_path


def parse_territories(xml_path: Path) -> dict:
    """Parse a CLDR XML file and return {cca2: {'name': ..., 'short': ...}}.
    Only alpha-2 codes are kept (numeric M.49 are skipped).
    """
    tree = ET.parse(xml_path)
    root = tree.getroot()
    territories = root.find("localeDisplayNames/territories")
    if territories is None:
        return {}
    result = {}
    for t in territories:
        code = t.get("type", "")
        if len(code) != 2 or not code.isalpha():
            continue  # skip numeric M.49 (142 = Asia etc.)
        alt = t.get("alt", "")
        if alt == "variant":
            continue  # skip e.g. "Hong Kong SAR China"
        if alt == "":
            result[code] = {"name": t.text, "short": None}
        elif alt == "short":
            if code in result:
                result[code]["short"] = t.text
            else:
                result[code] = {"name": None, "short": t.text}
    return result


def get_country_ids() -> dict:
    """Return {cca2: country_id} mapping from D1."""
    res = http_query("SELECT id, cca2 FROM countries")
    if not res["ok"]:
        raise RuntimeError(f"countries fetch failed: {res['error']}")
    return {row["cca2"]: row["id"] for row in res["data"]}


def main():
    if not TOKEN:
        print("ERROR: CLOUDFLARE_API_TOKEN not set")
        sys.exit(1)

    extract_dir = Path("tmp")
    print("Step 1: Downloading/Extracting CLDR 48.2 ...")
    main_path = download_cldr(extract_dir)
    if not main_path.exists():
        print(f"ERROR: {main_path} does not exist")
        sys.exit(1)

    print(f"\nStep 2: Getting country_id mapping from D1 ...")
    cca2_to_id = get_country_ids()
    print(f"  Got {len(cca2_to_id)} countries")

    print(f"\nStep 3: Parsing {len(TARGET_LANGUAGES)} CLDR XML files ...")
    all_rows = []  # list of (country_id, language, name, short_name)
    for lang in TARGET_LANGUAGES:
        xml_path = main_path / f"{lang}.xml"
        if not xml_path.exists():
            print(f"  WARNING: {xml_path} not found, skipping")
            continue
        territories = parse_territories(xml_path)
        matched = 0
        for cca2, info in territories.items():
            if cca2 not in cca2_to_id:
                continue
            if not info["name"]:
                # Only short variant, no main entry — skip
                continue
            country_id = cca2_to_id[cca2]
            all_rows.append((
                country_id, lang, info["name"], info["short"],
            ))
            matched += 1
        print(f"  {lang}: {len(territories)} territories, {matched} matched to our countries")

    print(f"\nTotal rows to insert: {len(all_rows):,}")

    print(f"\nStep 4: Inserting into country_names (release_id={RELEASE_ID}) ...")
    print(f"  1 INSERT per HTTP call (5 binds), 16 parallel workers")

    def apply_row(row: tuple) -> int:
        country_id, lang, name, short = row
        sql = """INSERT OR REPLACE INTO country_names
                 (country_id, language, name, short_name, source, release_id)
                 VALUES (?, ?, ?, ?, 'cldr', ?)"""
        params = [country_id, lang, name, short, RELEASE_ID]
        res = http_query(sql, params)
        if res["ok"]:
            return res.get("meta", {}).get("changes", 0)
        return 0

    success = 0
    total_changes = 0
    start = time.time()
    last_log = start

    with ThreadPoolExecutor(max_workers=16) as executor:
        futures = {executor.submit(apply_row, row): row for row in all_rows}
        for future in as_completed(futures):
            changes = future.result()
            success += 1
            total_changes += changes
            now = time.time()
            if now - last_log > 2:
                elapsed = now - start
                rate = success / elapsed if elapsed > 0 else 0
                eta = (len(all_rows) - success) / rate if rate > 0 else 0
                print(f"  {success:,}/{len(all_rows):,} ({rate:.0f} rows/s, ETA {eta:.0f}s)", flush=True)
                last_log = now

    elapsed = time.time() - start
    print(f"\nDone. {success:,} rows in {elapsed:.1f}s")
    print(f"  Total changes: {total_changes:,}")

    print(f"\nStep 5: Verify with D1 ...")
    res = http_query("SELECT COUNT(*) as n FROM country_names WHERE release_id = ?", [RELEASE_ID])
    if res["ok"]:
        print(f"  country_names rows for {RELEASE_ID}: {res['data'][0]['n']:,}")


if __name__ == "__main__":
    main()
