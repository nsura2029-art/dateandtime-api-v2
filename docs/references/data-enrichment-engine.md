# Data Enrichment Engine

> How we go from raw external sources to the merged canonical DB. Read this before adding a new enrichment source.

## Architecture

```
Raw Source (file or API)
        ↓
Downloader (Python script, R2 archive)
        ↓
Staging table (cities_staging, etc.)
        ↓
Reconciler (intelligent_merge.py)
        ↓
Canonical tables (cities, holiday_occurrence, etc.)
        ↓
Layer fields (source_primary, source_merged_with, origin)
```

## Why a layered approach?

**Problem:** We have 2+ sources for the same data (e.g., dr5hn and GeoNames both have
US cities). Just `INSERT` from GeoNames would conflict with dr5hn. Just `INSERT` from
dr5hn would miss 17K GeoNames-only cities (mostly non-US).

**Solution:** Layer model. dr5hn is the primary layer (US-focused, high quality).
GeoNames is the secondary layer (global, lower quality for US). We merge intelligently:
- Same coordinates (within 1km) → dr5hn wins, GeoNames is logged as alt name
- Within 10km fuzzy → GeoNames is added as alt name
- Historical alias match → GeoNames is added as alt name

## Pattern: 4 steps to add enrichment

### Step 1: Define the source

Add a row to `source_registry` (or `holiday_source` for holiday sources):

```sql
INSERT INTO source_registry
  (source_key, tier, organization, scope_country, license, license_url,
   attribution, format, endpoint_url, is_active)
VALUES
  ('my_new_source', 'A', 'My Org', 'US', 'Public Domain', 'https://...',
   'My Org', 'csv', 'https://...', 1);
```

### Step 2: Download + stage

Write a Python script in `scripts/seed/<source_name>.py` that:
1. Downloads the raw file (or calls the API)
2. Saves to R2 (`wrangler r2 object put ...`)
3. Loads into a staging table (e.g., `cities_staging`, `holiday_un_day`)
4. Records the release in `source_releases` with SHA-256

### Step 3: Reconcile

If the source overlaps with existing canonical data, write a reconciler that
applies the layer model. For 1:1 mappings (e.g., country attributes), this is
just a column-level update. For 1:many (e.g., a new Wikidata field for some cities),
use a JOIN.

### Step 4: Test + commit

1. Add tests in `tests/<source>.test.ts`
2. Update OpenAPI schema if a new endpoint exposes the new data
3. Update CHANGELOG.md
4. Update `docs/references/sources/<source>.md` (or add a new one)

## Existing enrichment scripts

| Source | Script | Loads into |
|---|---|---|
| dr5hn | (initial, M1) | cities (US-focused) |
| GeoNames cities1000 | `scripts/seed/cities15000.py` | cities_staging |
| GeoNames cities15000 | `scripts/seed/cities15000.py` | cities (17,283 new) |
| GeoNames admin2 | `scripts/seed/admin2_global_to_d1.py` | administrative_regions |
| GeoNames altNames | (initial) | alt_names |
| GeoNames postcodes | (initial) | postcodes |
| IANA zoneinfo | `scripts/seed/dst_transitions.py` | dst_transitions |
| NCEI stations | `scripts/seed/ghcn_stations.py` | climate_real (staging) |
| NCEI per-city | `scripts/seed/ghcn_station_to_city.py` | climate_real |
| Wikidata (Q-ids) | `scripts/seed/wikidata_to_d1.py` | wikidata_properties |
| Wikidata (P-codes) | `scripts/seed/wikidata_props_to_d1.py` | wikidata_properties |
| CLDR | `scripts/seed/cldr_to_d1.py` | country_localizations |
| World Bank | `scripts/seed/worldbank_to_d1.py` | country_indicators |
| US Census | `scripts/seed/us_census_to_d1.py` | us_census_attributes |
| US ACS | `scripts/seed/us_acs_to_d1.py` | us_acs_attributes |
| Eurostat LAU | `scripts/seed/eurostat_lau_to_d1.py` | eu_lau |
| Eurostat URAU | `scripts/seed/eurostat_urau_to_d1.py` | eu_urau |
| Census of India | `scripts/seed/census_india_to_d1.py` | in_census_attributes |
| OpenHolidays | `scripts/seed/holiday_nl_us_to_d1.py` | holiday_occurrence |
| Nager.Date | `scripts/seed/holiday_nl_us_to_d1.py` | holiday_occurrence |
| Hebcal | `scripts/seed/holiday_enrich.py` | holiday_occurrence |
| UN days | `scripts/seed/holiday_enrich.py` | holiday_un_day |
| Computed rules | `scripts/seed/holiday_enrich.py` | holiday_occurrence |

## M14: Holiday enrichment engine

The most recent example. Pipeline:

1. **Tier 1 — Computed** (`holiday_enrichment/computed.py`)
   - US federal (5 U.S.C. § 6103)
   - Easter-related (Computus algorithm)
   - Seasons (Meeus astronomical algorithm — accurate to 1 day)
   - DST changes (US, with offsets)
   - US observances (Mother's Day, Father's Day, etc.)
   - GB bank holidays
   - IN national holidays

2. **Tier 2 — Hebcal**
   - Per country: 18 Jewish holidays/year
   - Free, MIT-licensed JSON API
   - Filter to `category IN ('holiday', 'minor', 'modern', 'fast')` only

3. **Tier 2 — UN days**
   - 178 international days from `holiday_un_day` table
   - 1 row per day, applies to every year
   - Loaded into worldwide (country_id=NULL) AND per-country for each priority country

4. **Nager.Date**
   - For countries not covered by Tier 1 (e.g., IN)

### Idempotency

The enrichment engine is idempotent:
- Concepts dedup by `name_en`
- Occurrences dedup by `(concept_id, country_id, subdivision_code, start_date, date_role)`
- D1 doesn't support `IS ?` with NULL parameters, so we use explicit clauses

### Batch loading

For 100K+ rows: use Python to generate SQL files, then:
```bash
npx wrangler d1 execute timeandtimepro-full-v2 --file=<generated>.sql --remote
```

This is 10x faster than the HTTP API (10s vs 16 min for 14K rows).

## Performance tips

- **D1 100-var limit:** For multi-row INSERT, BATCH_ROWS = floor(99 / cols)
- **Use indexes:** All `cities` queries use `idx_cities_country`, `idx_cities_tz`, etc.
- **LEFT JOINs:** For per-country queries that include worldwide events
- **N+1 query avoidance:** When returning N holidays, batch the filter/source queries
  (1 + 2 queries instead of 1 + 2N)

## Common gotchas

- **Hebcal `parashat` category** — weekly torah portion, not a holiday. Skip.
- **Hebcal `roshchodesh`** — new month observance, not a holiday. Skip.
- **Nager.Date `counties` array** — one occurrence per state. Inflates count.
- **Computed Easter + observed shift** — if a holiday falls on Saturday, OPM rule is
  to observe on Friday. Make sure your `observed_shift()` function follows this.
- **Meeus astronomical** — high-precision algorithm is ~30 lines of code with
  periodic terms. Don't use simple day-of-year averages.

## See also

- `docs/references/data-sources-master.md` — all sources
- `docs/references/schema-evolution.md` — schema changes
- `scripts/seed/holiday_enrichment/` — the engine
- `reports/` — milestone reports (m11.0 through m13)
