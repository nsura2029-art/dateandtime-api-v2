# scripts/seed/ — Python seed scripts

## Purpose

One-time or repeat data imports for the D1 database. Ported from the legacy `cloudflare/datetime-api/seed/` directory.

## Ownership

| File | Owns |
|---|---|
| `cities15000.py` | Import GeoNames cities15000.txt → `cities` table |
| `holidays.py` | Import Nager.Date public holidays → `holidays` table |
| `climate_seasons.py` | Compute lat/lon-based climate → `climate_summaries`, `seasons` |
| `dst_transitions.py` | Compute DST transitions via `zoneinfo` → `dst_transitions` |
| `seed_onthisday.py` | Import curated Wikipedia onthisday events → `onthisday` |

Future: `religion_holidays.py`, `holidays_expanded.py`, `climate_seasons_fast.py`.

## Local Contracts

### Python version

Python 3.11+ (uses `zoneinfo` from stdlib). See `requirements.txt` for the few external deps (likely just `requests` for HTTP).

### Output

Each script writes to the D1 via the Cloudflare HTTP API (not via wrangler), batched in groups of ≤100 variables per statement (D1's per-prepared-statement limit).

### Idempotency

Use `INSERT OR IGNORE` or `INSERT OR REPLACE` where the table has a unique key. Re-runs should be no-ops.

## Work Guidance

### Adding a new seed script

1. Pick the source data (GeoNames, Nager.Date, Wikipedia, etc.).
2. Write the fetcher/parser in Python.
3. Batch into D1-friendly sizes (≤100 vars per INSERT).
4. Document the source in `src/lib/data_sources.md` (or equivalent).
5. Test against the dev D1 before running against prod.
6. Add the run command to `package.json` as `seed:<source>`.

### Re-running a seed

Most seeds are idempotent. If not, the script should print a warning before truncating.

## Verification

```bash
# Install deps (one time)
pip install -r requirements.txt

# Run against local D1 (via wrangler)
npx wrangler d1 execute timeandtimepro-full --local --command "SELECT COUNT(*) FROM cities"
# Should be 0 initially

python scripts/seed/cities15000.py
# Should print progress + final row count

npx wrangler d1 execute timeandtimepro-full --local --command "SELECT COUNT(*) FROM cities"
# Should be ~33,945
```

## Child DOX Index

No children.
