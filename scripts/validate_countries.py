#!/usr/bin/env python3
"""
M14 Country Validation — compare Calendarific data against our API for:
- US (already validated)
- IN (already validated, 24/24 from user reference list)
- CA (Canada) — Nager.Date control, see what Calendarific adds
- MX (Mexico) — no prior baseline, all new
- AU (Australia) — state-level PUBLIC_LOCAL
- DE (Germany) — DE has 9 public + 2-4 varying by state
- FR (France) — France has Fetes
- GB (UK) — already known baseline
- ES (Spain) — regional variations
- IT (Italy) — patron saint days per city

Each country outputs:
- Total holidays in DB
- Sample 20 holidays from 2026
- Filter breakdown
- Source breakdown
"""
import json
import urllib.request
import sys
from collections import Counter

COUNTRIES = {
    "US": "United States",
    "IN": "India",
    "CA": "Canada",
    "MX": "Mexico",
    "AU": "Australia",
    "DE": "Germany",
    "FR": "France",
    "GB": "United Kingdom",
    "ES": "Spain",
    "IT": "Italy",
}

API = "https://dt-api-v2-dev.nsura2029.workers.dev"


def fetch(country, year=2026, limit=500):
    url = f"{API}/api/v1/holidays?country={country}&year={year}&limit={limit}"
    req = urllib.request.Request(url, headers={"User-Agent": "M14-validate/1.0"})
    try:
        with urllib.request.urlopen(req, timeout=20) as r:
            return json.loads(r.read().decode())
    except Exception as e:
        return {"error": str(e)}


def main(only=None):
    if only:
        targets = [c for c in COUNTRIES if c in only.upper().split(",")]
    else:
        targets = list(COUNTRIES.keys())

    for cca2 in targets:
        name = COUNTRIES[cca2]
        print("=" * 80)
        print(f"🌍 {cca2} — {name} (2026)")
        print("=" * 80)
        data = fetch(cca2)
        if "error" in data:
            print(f"  ❌ Fetch error: {data['error']}")
            continue
        holidays = data["data"]["holidays"]
        total = data["data"]["total"]
        print(f"Total: {total} (showing {len(holidays)})")

        # Source breakdown
        sources = Counter()
        for h in holidays:
            for s in h.get("sources", []):
                sources[s if isinstance(s, str) else s.get("sourceKey", s.get("source_key", "?"))] += 1
        print(f"Sources: {dict(sources.most_common(10))}")

        # Filter breakdown
        filters = Counter()
        for h in holidays:
            for f in h.get("filters", []):
                filters[f] += 1
        print(f"Filters (top 10): {dict(filters.most_common(10))}")

        # State-level breakdown
        subdiv = Counter()
        for h in holidays:
            subdiv[h.get("subdivisionCode") or "national"] += 1
        if len(subdiv) > 1:
            print(f"State coverage: {len(subdiv)} (top 10: {dict(subdiv.most_common(10))})")

        # Sample 20
        print(f"\nSample 20 (sorted by date):")
        for h in sorted(holidays, key=lambda x: (x["startDate"], x.get("subdivisionCode") or ""))[:20]:
            sub = h.get("subdivisionCode") or "—"
            fcodes = ",".join(
                f for f in h.get("filters", [])
                if f not in ("OBS_IMPORTANT", "UN_OBSERVANCE", "OBS_COMMON", "OBS_OTHER", "OBS_LOCAL", "WORLD_OBSERVANCE")
            )
            sources_str = ",".join(s if isinstance(s, str) else s.get("sourceKey", "?") for s in h.get("sources", []))
            print(f"  {h['startDate']}  {h.get('conceptName','?')[:40]:<40}  {sub:<8}  {fcodes[:30]:<30}  {sources_str[:30]}")
        print()


if __name__ == "__main__":
    if len(sys.argv) > 1:
        main(sys.argv[1])
    else:
        main()
