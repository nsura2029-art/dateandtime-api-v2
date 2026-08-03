#!/usr/bin/env python3
"""
scripts/seed/ghcn_stations.py

M11.8: Download NCEI GHCN-Daily station list (1 file, 11MB).
Returns all global weather stations with lat/lon/elevation/element.

Source: https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt

Format: Fixed-width
  ID (11 chars) | LAT (8) | LON (9) | ELEV (6) | NAME (31) | ... etc
"""
import os
import sys
import urllib.request
import time

STATION_LIST_URL = "https://www.ncei.noaa.gov/pub/data/ghcn/daily/ghcnd-stations.txt"
OUTPUT = "tmp/ghcnd-stations.txt"


def main():
    if os.path.exists(OUTPUT):
        size = os.path.getsize(OUTPUT)
        print(f"  Already have {OUTPUT} ({size:,} bytes)")
        with open(OUTPUT) as f:
            n = sum(1 for _ in f)
        print(f"  {n:,} stations")
        return

    print(f"  Downloading {STATION_LIST_URL} ...")
    start = time.time()
    req = urllib.request.Request(STATION_LIST_URL, headers={"User-Agent": "dateandtime-api-v2/1.0"})
    with urllib.request.urlopen(req, timeout=120) as r:
        data = r.read()
    with open(OUTPUT, "wb") as f:
        f.write(data)
    print(f"  Saved {OUTPUT} ({len(data):,} bytes) in {time.time() - start:.1f}s")


if __name__ == "__main__":
    main()
