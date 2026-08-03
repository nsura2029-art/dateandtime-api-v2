# References Index

> Living index of all reference docs in this repo. Read this to find the right doc for your question.

## Master docs

| Doc | What it covers |
|---|---|
| [data-platform-journey.md](data-platform-journey.md) | M0 → M14 milestone-by-milestone narrative: what we built, why, and what we learned |
| [data-sources-master.md](data-sources-master.md) | Every data source we use, with tier, license, scope, and what we extract |
| [schema-evolution.md](schema-evolution.md) | DB migration-by-migration: what tables, what columns, when, why |
| [api-endpoints.md](api-endpoints.md) | Every API endpoint with method, params, sample response |
| [timezone-architecture.md](timezone-architecture.md) | How timezones, DST, and city lookup work |
| [regions-countries-cities.md](regions-countries-cities.md) | Geographic data model: world → continent → country → admin-1 → admin-2 → city |
| [data-enrichment-engine.md](data-enrichment-engine.md) | The enrichment pipeline: how we go from raw sources to the merged canonical DB |

## By domain

### Cities (timezone, region, sub-region, country)

- [regions-countries-cities.md](regions-countries-cities.md) — geographic hierarchy
- [timezone-architecture.md](timezone-architecture.md) — timezone + DST
- [sources/cities/](sources/cities/) — dr5hn + GeoNames + cities15000 (170K cities)
- [sources/admin-2/](sources/admin-2/) — GeoNames admin-2 codes (47K regions)

### Country attributes (population, languages, names)

- [sources/countries/cldr.md](sources/countries/cldr.md) — Unicode CLDR
- [sources/countries/worldbank.md](sources/countries/worldbank.md) — World Bank Indicators
- [sources/countries/un-m49.md](sources/countries/un-m49.md) — UN M49 region codes

### Cities enrichment (per-city attributes)

- [sources/cities/us-census.md](sources/cities/us-census.md) — US Census Bureau + ACS
- [sources/cities/eurostat.md](sources/cities/eurostat.md) — Eurostat LAU + URAU
- [sources/cities/census-india.md](sources/cities/census-india.md) — Census of India 2011
- [sources/cities/ncei-gsom.md](sources/cities/ncei-gsom.md) — Real climate data (NCEI GSOM)

### Wikidata cross-reference

- [sources/wikidata.md](sources/wikidata.md) — Q-ids, P-codes, descriptions, alt labels

### Holidays

- [holidays/data-sources.md](holidays/data-sources.md) — Tier A-D holiday sources
- [holidays/nz-employment-nz-2026-2027.md](holidays/nz-employment-nz-2026-2027.md) — NZ data dump
- [holidays/us-csv-2026.md](holidays/us-csv-2026.md) — US 2026 authoritative list
- [holidays/india-data-sources.md](holidays/india-data-sources.md) — India research
- [holidays/un-international-days.md](holidays/un-international-days.md) — UN days list

## Maintenance

- Update the master docs whenever a milestone ships
- Update `data-sources-master.md` whenever a new source is added
- Update `schema-evolution.md` whenever a new migration lands
- Keep all research in `docs/references/` so future sessions can find context
