# Cities Data Sources

> Sources for the 170,253 cities in our database.

## dr5hn/timezone-boundary-builder (M1)

- **Source:** https://github.com/dr5hn/timezone-boundary-builder
- **Tier:** A (open data, used by many production systems)
- **License:** ODbL
- **What we use:** cities15000 part — 152,970 cities with timezone polygons
- **Format:** GeoJSON → CSV conversion
- **What we extract:** name, ascii_name, country_code, state_code, tz_id, lat, lon, population
- **Quality:** High for US, lower for non-US (no native timezone boundaries)
- **Why primary:** US-focused data is excellent, polygons give high confidence

## GeoNames cities1000 (M11.0)

- **Source:** https://download.geonames.org/export/dump/cities1000.zip
- **Tier:** D
- **License:** CC-BY
- **What we use:** 149K cities (population > 1000 OR is capital OR has admin seat)
- **Format:** Tab-separated CSV
- **What we extract:** geonameId, name, ascii_name, country, admin1, admin2, lat, lon, population, timezone
- **Quality:** Global, lower for individual US cities
- **Why secondary:** Global coverage where dr5hn is weak

## GeoNames cities15000 (M12)

- **Source:** https://download.geonames.org/export/dump/cities15000.zip
- **Tier:** D
- **License:** CC-BY
- **What we use:** 33K more cities (population > 15000 OR is capital)
- **Format:** Tab-separated CSV
- **Result:** 17,283 new cities (post-M12)
- **What we extract:** same as cities1000

## Layer merge (M11.1)

We don't `INSERT` GeoNames directly into `cities`. Instead:

1. Load GeoNames into `cities_staging` (M11.0)
2. Run `intelligent_merge.py` (M11.1) which uses 3-tier strategy:
   - **Exact 1km** — same coordinates → dr5hn wins, GeoNames added as alt name
   - **Fuzzy 10km** — within 10km → GeoNames added as alt name
   - **Historical alias** — old name → new name → GeoNames added as alt name
3. Result: 170,253 cities total, 17,283 GeoNames-only + 152,970 dr5hn (with overlap collapsed)

## Country code sources

| Purpose | Source | Notes |
|---|---|---|
| ISO 3166-1 alpha-2/3 | GeoNames `countryInfo.txt` | cca2, cca3, fips, iso |
| Continent | GeoNames | AF, AN, AS, EU, NA, OC, SA |
| Region | UN M49 | Africa, Americas, Asia, Europe, Oceania |
| Languages | GeoNames + Unicode CLDR | Comma-separated ISO 639 codes |
| Capital | GeoNames | City name (not ID) |
| Population | World Bank Indicators 2024 | M11.4 |
| Area | GeoNames | km² |

## Admin-1 source

- **dr5hn:** ISO 3166-2 codes (US-FL, etc.) — used in `cities.state_code`
- **GeoNames admin1Codes.txt:** Full admin-1 list
- **M11.0 unified:** All admin-1 in `administrative_regions` table

## Admin-2 source (M12)

- **GeoNames admin2Codes.txt:** 2.4MB file
- 47,549 admin-2 regions across 189 countries
- 56,293 cities mapped (33% of 170K)
- Mapped via cities1000.txt's `admin2 code` column

## Other city enrichment sources

See per-source docs:
- [us-census.md](us-census.md) — US state/county + ACS demographics
- [eurostat.md](eurostat.md) — EU LAU + URAU
- [census-india.md](census-india.md) — Census of India 2011
- [ncei-gsom.md](ncei-gsom.md) — Real climate data
- [wikidata.md](../wikidata.md) — Q-ids, P-codes, descriptions
