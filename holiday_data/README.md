# Calendarific holiday data

Raw JSON pulls from the Calendarific API, organized by year and country.

## Layout

```
holiday_data/calendarific/
├── 2026/
│   ├── US.json
│   ├── NL.json
│   ├── IN.json
│   └── ... (190 countries)
└── 2027/
    ├── US.json
    ├── NL.json
    ├── IN.json
    └── ... (190 countries)
```

## Coverage

- **190 non-African countries** × **2 years** (2026, 2027) = **380 files**
- 6 territories returned empty data and are saved as valid empty responses:
  - AQ Antarctica, GS South Georgia, NU Niue, PN Pitcairn, PS Palestine, UM US Minor Outlying Islands
- Total entries: **6,509 in 2026**, **6,374 in 2027** (multi-state rows included; unique (date, name) is ~5,500)

## Per-country holiday counts (2026)

| Country | Holidays | Notable additions vs our DB |
|---|---:|---|
| US | 635 | 70 State + 52 State Observance + 7 State Legal + 15 Local + 21 Christian + 18 Jewish + 8 Muslim + 7 Hindu + 6 Orthodox + 4 Season + 2 Clock + 7 Sporting |
| IN | 71 | 17 Gazetted (was 9) + 33 Restricted + 14 Observance + 4 Season (BUG-7 fix) + 2 Hinduism + 1 Christian |
| AU | 130 | 6 National + 20 State + 12 Common State + 4 Season + 2 Clock + 1 Half Day + 1 Part Day |
| GB | 93 | Multi-region UK |
| JP | 34 | |
| DE | 111 | |
| FR | 27 | |
| NL | 24 | |
| ... | ... | |

## File format

Each `{CCA2}.json` file has the structure:

```json
{
  "cca2": "US",
  "year": 2026,
  "meta": { "code": 200 },
  "response": {
    "holidays": [
      {
        "name": "New Year's Day",
        "description": "...",
        "country": { "id": "us", "name": "United States" },
        "date": { "iso": "2026-01-01", "datetime": { "year": 2026, "month": 1, "day": 1 } },
        "type": ["Local holiday"],
        "primary_type": "State Holiday",
        "canonical_url": "https://calendarific.com/holiday/us/new-year-day",
        "urlid": "us/new-year-day",
        "locations": "TX",
        "states": [
          { "id": 48, "abbrev": "TX", "name": "Texas", "exception": null, "iso": "us-tx" }
        ]
      }
    ]
  }
}
```

For territories with no data, the response is normalized to `{"holidays": []}`.

## How to refresh

```bash
# Re-fetch all (overwrites existing)
CALENDARIFIC_API_KEY=$KEY python3 scripts/ingest/calendarific_pull.py --force

# Resume-safe (skips already-fetched)
CALENDARIFIC_API_KEY=$KEY python3 scripts/ingest/calendarific_pull.py
```

## Next steps

- [ ] Build `scripts/ingest/calendarific_parse.py` — map Calendarific fields → our schema
- [ ] Build `scripts/ingest/calendarific_load.py` — load parsed records into D1
- [ ] Next month: ingest Africa (60 countries × 2 years = 120 calls)

## Source metadata

| Field | Value |
|---|---|
| Source | Calendarific API |
| URL | https://calendarific.com/api/v2/holidays |
| Authority tier | D (open provider, accelerator) — NOT controlling per the spec |
| License | Free tier: 1,000 req/day, 429 on overage. Paid plans: monthly limits + alerts |
| Free quota used (this run) | 408 calls |
| Free quota remaining | 592 (within today's 1,000 cap) |
| Last fetched | 2026-08-04 |
