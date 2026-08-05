# Schema Evolution

> Every migration we've applied, what it changed, and why. Use this when you need to understand a table or column.

## Current state (M0-M14)

**156 migrations** applied to `timeandtimepro-full-v2` (D1 ID `ab54b1d7-6791-4d29-a94c-c95e6a560b7e`).

**57 tables**, **1 GB** of data, **5,000+ SQL files** (most are city seed files).

## Major schema milestones

| M | Migration | What changed | Why |
|---|---|---|---|
| M0 | 1-10 | Initial tables: cities, countries, timezones, postcodes | Core data model |
| M1 | 11-20 | timezone_polygons + boundary_distance_km | Polygon-based confidence |
| M2 | 21-40 | subregions, admin-1, alternative names | Geographic hierarchy |
| M3 | 41-50 | population, alt_names, place_names | Search ranking |
| M4 | 51-60 | postcodes schema | Postal lookup |
| M5 | 61-70 | city_translations | 19-language support |
| M8 | 71-90 | data_quality_checks, data_quality_issues | Quality metadata |
| M9 | 91-99 | documentation tables | Spec compliance |
| M10 | 100 | drop_all (reserved, unused) | Original destructive plan |
| M11.0 | 101-110 | source_registry, source_releases, cities_staging | Data platform foundation |
| M11.1 | 111-115 | city_layer_log, layer fields on cities | Layer merge |
| M11.1.5 | 116-120 | city_altnames (search) | Alt name search |
| M11.2.x | 121-153 | wikidata_properties, wikidata_altlabels, wikidata_descriptions, wikidata P-codes | Wikidata integration |
| M11.3 | M11.3+ | country_localizations (CLDR) | Country names in 19 languages |
| M11.4 | M11.4+ | country_indicators (World Bank) | Country population |
| M11.5 | M11.5+ | us_census_attributes, us_acs_attributes (B01001, B19013, B15003, B25003, B08301) | US Census + ACS demographics |
| M11.5.1 | M11.5.1 expand 1+2 | Same schema, more ACS tables | 3-way LEFT JOIN |
| M11.6 | 146-147 | eu_lau, eu_urau, eu_city_status | EU LAU + URAU |
| M11.7 | 148-149 | in_census_attributes | Census of India 2011 |
| M11.8 | 154 | climate_real (city_id, month PK + 7 cols) | Real climate (NCEI GSOM) |
| M12 | 155 | admin2_global (geoname_id UNIQUE + cities.admin2_id FK) | Global admin-2 |
| M13 | 156 | holiday_core_schema (8 new tables) | Holidays MVP |
| M14 | 157 | holiday_worldwide_and_categories | Worldwide + state + UN days |

## Tables grouped by domain

### Core (M0)

- `cities` (170,253 rows) — city_id, name, ascii_name, country_code, state_code, timezone, lat, lon, population
- `countries` (250 rows) — cca2, cca3, name, continent, capital
- `timezones` (462 rows) — id, name, utc_offset, dst_offset
- `postcodes` (844,248 rows) — country, postcode, city, admin-1, lat, lon
- `translations` (2,965,561 rows) — lang, name, ascii_name
- `alt_names` (767,023 rows) — search aliases including historical

### Geography (M2, M12)

- `subregions` (4,750 rows) — ISO 3166-2 codes
- `administrative_regions` (52,857 rows) — admin-1 + admin-2
- `cities.admin1_code` (FK) — state/region
- `cities.admin2_id` (FK) — county/district/commune (M12)

### Source platform (M11.0)

- `source_registry` (14+ rows) — every source with tier, license, scope
- `source_releases` (10+ rows) — versioned + SHA-256
- `cities_staging` (69,561 rows) — GeoNames ready to merge
- `city_layer_log` (69,563 rows) — audit trail of layer merges

### Wikidata (M11.2-M11.2.8)

- `wikidata_properties` (5,000 rows) — Q-ids + P-codes (P31, P17, P131, P421)
- `wikidata_altlabels` (148K rows) — alt labels for search
- `wikidata_descriptions` (148K rows) — short descriptions

### Country attributes (M11.3, M11.4)

- `country_localizations` (5,000 rows) — 250 countries × 19 langs
- `country_indicators` (216 rows) — World Bank pop + economic

### Per-city attributes (M11.5-M11.8)

- `us_census_attributes` (14,459 rows) — state, county, FIPS, pop vintage
- `us_acs_attributes` (14,450 rows) — Sex by Age (B01001)
- `us_acs_income_education` — Income (B19013) + Education (B15003)
- `us_acs_tenure_transport` — Tenure (B25003) + Transport (B08301)
- `eu_lau` (41,571 rows) — EU Local Administrative Unit
- `eu_urau` (597 rows) — Urban centres + FUA
- `in_census_attributes` (963 rows) — Census of India 2011
- `climate_real` (87,808 rows) — NCEI monthly climate

### Holidays (M13, M14)

- `holiday_filter` (36 rows) — catalog of all filter codes
- `holiday_concept` (~30 rows) — abstract "what" (e.g., 'Christmas Day')
- `holiday_occurrence` (1,827 rows for 2026) — concrete dates
- `holiday_occurrence_filter` — M2N
- `holiday_source` (8 rows) — per-source metadata
- `holiday_occurrence_source` — which sources contribute
- `holiday_revision` — change tracking
- `country_filter_policy` (22 rows) — the variance table
- `holiday_feedback` — user reports
- `holiday_occurrence_state` (M14) — per-state mentions
- `holiday_un_day` (225 rows) — UN day registry
- `holiday_country_un_day` — which countries observe each UN day

## Gotchas (read before schema work)

### D1 100-var limit

D1 HTTP API has a ~100-variable per-prepared-statement limit. For multi-row INSERT:

| Cols | BATCH_ROWS | Vars |
|---|---:|---:|
| 4-5 | 20+ | 80-100 |
| 6 | 16 | 96 |
| 7 | 14 | 98 |
| 9 | 11 | 99 |
| 11 | 9 | 99 |
| 12 | 8 | 96 |
| 14 | 7 | 98 |
| 15 | 4-6 | 60-90 |

For 9 placeholders but 12-column table: "9 values for 11 columns" means count your placeholders, not your params.

### D1 NULL handling

`IS ?` with parameterized NULL doesn't work reliably. Use explicit clauses:
```sql
WHERE (country_id = ? OR (country_id IS NULL AND ? IS NULL))
-- Or better:
WHERE (country_id = ? OR country_id IS NULL)
```

### Recreate-table pattern (D1)

SQLite can't `ALTER COLUMN`. To make a column nullable or change type:
1. `PRAGMA foreign_keys = OFF;`
2. `CREATE TABLE new_X (...);`
3. `INSERT INTO new_X SELECT ... FROM X;`
4. `DROP TABLE X;`
5. `ALTER TABLE new_X RENAME TO X;`
6. Recreate indexes
7. `PRAGMA foreign_keys = ON;`

### Bulk loading

- **`wrangler d1 execute --file=...sql` is 10x faster than HTTP API** (10s vs 16 min for 14K rows)
- Always use `INSERT OR IGNORE` for UNIQUE conflicts, or `INSERT OR REPLACE` for full-row replace
- For 100K+ rows: use Python to generate SQL files, then wrangler to load

### Migrations 100-156

All migrations are applied via:
```bash
npx wrangler d1 execute timeandtimepro-full-v2 --file=migrations/NNN_name.sql --remote
```

Each migration is idempotent (uses `CREATE TABLE IF NOT EXISTS`, `INSERT OR IGNORE`).

## Adding a new table (checklist)

1. **Create migration** in `migrations/NNN_<description>.sql`
2. **Add to `migrations/AGENTS.md`** schema section
3. **Add to `schema-evolution.md`** (this file)
4. **Add tests** for new queries/endpoints
5. **Update OpenAPI schema** in `docs/api/openapi.json`
6. **Update Postman collection** via `npm run sync:readme`
7. **Update CHANGELOG.md** with the change

## Migration index

```bash
ls migrations/ | sort -n
```

Latest: **157** (`157_holiday_worldwide_and_categories.sql`).
