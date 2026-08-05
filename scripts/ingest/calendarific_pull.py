#!/usr/bin/env python3
"""
Pull Calendarific holiday data for 190 non-African countries × 2 years (2026, 2027).

Resume-safe: skips (cca2, year) pairs that already have a file.
Respects free tier: max 1,000 calls/day (1 call = 1 country+year).
Respects 429: backs off 60s and retries with exponential backoff.

Usage:
  # Reads CALENDARIFIC_API_KEY from env
  python3 scripts/ingest/calendarific_pull.py

  # Test with first 5 countries
  python3 scripts/ingest/calendarific_pull.py --limit 5

  # Force re-download (overwrite existing files)
  python3 scripts/ingest/calendarific_pull.py --force
"""
import argparse
import json
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

API_KEY = os.environ.get("CALENDARIFIC_API_KEY", "").strip()
BASE_URL = "https://calendarific.com/api/v2/holidays"
ROOT = Path(__file__).resolve().parents[2]
DATA_DIR = ROOT / "holiday_data" / "calendarific"
COUNTRY_LIST = Path("/tmp/non_african_countries.json")

# Skip list (per user request 2026-08-03: skip Africa this month)
SKIP_REGIONS = {"Africa"}

# Polite delay between calls (free tier is 1k/day; let's not hammer)
DELAY_BETWEEN_CALLS_SEC = 0.2  # 5 calls/sec → 380 calls in ~76 sec
MAX_RETRIES = 5
RETRY_BACKOFF_SEC = 60  # Calendarific 429 says "wait a minute"


def fetch_country_year(cca2: str, year: int, force: bool = False) -> dict | None:
    """Fetch holidays for one country/year, save to JSON, return response."""
    out_dir = DATA_DIR / str(year)
    out_dir.mkdir(parents=True, exist_ok=True)
    out_path = out_dir / f"{cca2}.json"

    if out_path.exists() and not force:
        return None  # already have it, skip

    url = f"{BASE_URL}?api_key={API_KEY}&country={cca2}&year={year}"
    last_err = None
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "dateandtime-api-v2-calendarific-pull/1.0"},
            )
            with urllib.request.urlopen(req, timeout=15) as r:
                if r.status == 429:
                    wait = RETRY_BACKOFF_SEC * attempt
                    print(f"  ⏸  429 rate limit on {cca2}/{year} (attempt {attempt}/{MAX_RETRIES}); sleeping {wait}s")
                    time.sleep(wait)
                    continue
                body = json.loads(r.read().decode("utf-8"))
                # Save even on API errors (code != 200) so we don't retry forever
                with open(out_path, "w") as f:
                    json.dump({"cca2": cca2, "year": year, **body}, f, indent=2)
                if body.get("meta", {}).get("code") != 200:
                    print(f"  ⚠️  {cca2}/{year} API error: {body.get('meta')}")
                    return body
                # Some countries (e.g. Antarctica) return response as a list, not a dict
                resp = body.get("response")
                if isinstance(resp, list):
                    # Empty list = country has no holidays
                    holidays = resp
                elif isinstance(resp, dict):
                    holidays = resp.get("holidays", [])
                else:
                    holidays = []
                n = len(holidays)
                print(f"  ✓ {cca2}/{year}: {n} entries")
                return body
        except urllib.error.HTTPError as e:
            if e.code == 429:
                wait = RETRY_BACKOFF_SEC * attempt
                print(f"  ⏸  429 on {cca2}/{year} (attempt {attempt}/{MAX_RETRIES}); sleeping {wait}s")
                time.sleep(wait)
                continue
            last_err = f"HTTP {e.code}: {e.reason}"
            break
        except Exception as e:
            last_err = f"{type(e).__name__}: {e}"
            time.sleep(2 * attempt)  # small backoff for transient errors

    # All retries failed
    err_path = out_dir / f"{cca2}.error.json"
    with open(err_path, "w") as f:
        json.dump({"cca2": cca2, "year": year, "error": last_err}, f, indent=2)
    print(f"  ✗ {cca2}/{year} FAILED: {last_err}")
    return None


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--limit", type=int, default=None, help="Only fetch first N countries (for testing)")
    ap.add_argument("--force", action="store_true", help="Re-fetch even if file exists")
    ap.add_argument("--year", type=int, default=None, help="Only fetch one year (default: both 2026 and 2027)")
    args = ap.parse_args()

    if not API_KEY:
        print("ERROR: CALENDARIFIC_API_KEY not set in env", file=sys.stderr)
        sys.exit(1)

    if not COUNTRY_LIST.exists():
        print(f"ERROR: {COUNTRY_LIST} not found. Run the country list builder first.", file=sys.stderr)
        sys.exit(1)

    countries = json.load(open(COUNTRY_LIST))
    if args.limit:
        countries = countries[: args.limit]

    years = [args.year] if args.year else [2026, 2027]

    total = len(countries) * len(years)
    print(f"Pulling Calendarific data for {len(countries)} countries × {len(years)} year(s) = {total} calls")
    print(f"Output dir: {DATA_DIR}")
    print(f"Delay between calls: {DELAY_BETWEEN_CALLS_SEC}s")
    print()

    started = time.time()
    done = 0
    skipped = 0
    failed = 0
    for c in countries:
        cca2 = c["cca2"]
        region = c.get("region", "Unknown")
        if region in SKIP_REGIONS:
            skipped += 1
            continue
        for year in years:
            out_path = DATA_DIR / str(year) / f"{cca2}.json"
            if out_path.exists() and not args.force:
                skipped += 1
                done += 1
                continue
            res = fetch_country_year(cca2, year, force=args.force)
            if res is None:
                failed += 1
            done += 1
            # Progress
            if done % 10 == 0:
                elapsed = time.time() - started
                rate = done / elapsed if elapsed > 0 else 0
                eta = (total - done) / rate if rate > 0 else 0
                print(f"  -- {done}/{total} done, {skipped} skipped, {failed} failed, {rate:.1f}/s, ETA {eta:.0f}s")
            time.sleep(DELAY_BETWEEN_CALLS_SEC)

    elapsed = time.time() - started
    print()
    print(f"Done in {elapsed:.1f}s")
    print(f"  Total attempted: {total}")
    print(f"  Skipped (already done): {skipped}")
    print(f"  Failed: {failed}")
    print(f"  Successful: {total - skipped - failed}")


if __name__ == "__main__":
    main()
