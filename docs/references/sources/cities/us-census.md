# US Census + ACS Data Sources

> Sources for the 14,450 US cities with full demographic profile.

## US Census Bureau (M11.5)

- **Source:** https://www.census.gov/data.html
- **Tier:** A
- **License:** Public Domain
- **Coverage:** 14,459 US cities (places, county subdivisions, counties)
- **What we extract:**
  - State, county, FIPS code
  - Population (vintage tracking 2010-2023)
  - Housing units, land area, water area
- **Loader:** `scripts/seed/us_census_to_d1.py`
- **Migration:** `migrations/149_us_census_attributes.sql`

## US Census ACS 5-Year (M11.5.1)

- **Source:** https://www.census.gov/programs-surveys/acs
- **Tier:** A
- **License:** Public Domain
- **Coverage:** 14,450 US cities
- **What we extract:**

| Table | Field | Description |
|---|---|---|
| B01001 | Sex by Age | 49 columns (B01001_E001-E049) |
| B19013 | Median Income | Median household income in past 12 months |
| B15003 | Educational Attainment | 25 columns (E001-E025) |
| B25003 | Tenure | Owner vs renter occupied (2 cols) |
| B08301 | Transportation | 10 columns (means of transportation to work) |

- **Loader:** `scripts/seed/us_acs_to_d1.py`
- **Migration:** `migrations/150_us_acs_attributes.sql` + 151 + 152

## Performance optimization

For /cities/{id} detail with 7 attribute blocks (Wikidata + US Census + 5 ACS tables),
we do a **3-way LEFT JOIN** to fetch all attributes in 1 query (600-900ms vs 1500-2100ms).

```sql
SELECT c.*, uc.*, ua1.*, ua2.*, ua3.*, ua4.*, wp.*
FROM cities c
LEFT JOIN us_census_attributes uc ON uc.city_id = c.id
LEFT JOIN us_acs_attributes ua1 ON ua1.city_id = c.id   -- B01001
LEFT JOIN us_acs_income_education ua2 ON ua2.city_id = c.id  -- B19013 + B15003
LEFT JOIN us_acs_tenure_transport ua3 ON ua3.city_id = c.id   -- B25003 + B08301
LEFT JOIN wikidata_properties wp ON wp.qid = c.wikidata_qid
WHERE c.id = ?
```

## Gotchas

- **ACS columns:** `B01001_E{n}` is at column `2n-1` in the CSV (1-indexed, after GEO_ID)
- **"1600000US" prefix:** 9-char prefix on GEO_ID for places
- **`qid` is not UNIQUE** in wikidata_properties — use `INSERT OR REPLACE`
- **BATCH_ROWS=11** for 7-col inserts (11 × 7 = 77 vars, under 100 limit)
- **D1 vs HTTP API:** `wrangler d1 execute --file=` is 10x faster than HTTP API
- **Performance threshold:** 500ms → 3000ms is realistic for 7+ blocks

## Deferred (post-MVP)

- M11.5.1 step 2: Full PCA town-level data (DCHB) — 1-2 week effort
- ACS Subject Tables (S0101, S1501, etc.) — 5+ more demographic profiles
- 5-year vintage tracking (currently we have only 2023)
- Census tract-level data (60K tracts in US, much higher granularity)

## See also

- `reports/m11.5-us-census-result.md`
- `reports/m11.5.1-acs-result.md`
- `reports/m11.5.1-expand-result.md`
- `tests/m11.5-us-census.test.ts`
- `tests/m11.5.1-acs.test.ts`
- `tests/m11.5.1-income-education.test.ts`
- `tests/m11.5.1-tenure-transport.test.ts`
