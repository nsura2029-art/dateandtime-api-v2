# Data Sources Master Index

> Every external data source we use, with tier, license, scope, and what we extract.
> Use this when deciding whether to add a new source, evaluating alternatives, or auditing provenance.

## Source tier system (per spec section 7)

| Tier | Definition | Trust | Examples |
|---|---|---|---|
| **A** | Law, gazette, government ministry, central bank, official exchange, UN resolution | Controlling truth | US Census ACS, Employment NZ, OPM |
| **B** | Official calendar, agency ICS, official religious authority | Controlling unless superseded | UN resolutions, Hebcal, Catholic calendar |
| **C** | Licensed specialist provider (Timeanddate) | Accelerator/cross-check, license-dependent | (deferred — we don't license) |
| **D** | Approved open provider (OpenHolidays, Nager.Date) | Accelerator/cross-check | Nager.Date, OpenHolidays, Hebcal, GeoNames |
| **E** | Institutional (employer group, industry body) | Scope-limited | (not used yet) |
| **F** | Community (Wikipedia, calendars.usholiday.com) | Cross-check only | Wikipedia |

## Cities (timezone + population + location)

| Source | Tier | License | Scope | What we extract |
|---|---|---|---|---|
| **dr5hn/timezone-boundary-builder** | A | ODbL | Global polygon | 152,970 cities with timezone polygons (M1) |
| **GeoNames cities1000.txt** | D | CC-BY | 149K cities | Names, alt names, country, admin-1, lat/lon, population |
| **GeoNames cities15000.txt** | D | CC-BY | 33K cities | Adds 17,283 GeoNames-only cities (post-M12) |
| **GeoNames admin2Codes.txt** | D | CC-BY | 47K regions | Counties, districts, communes |
| **IANA zoneinfo** | A | Public Domain | 462 zones | Timezone database for DST rules (M11.6.1) |

## Country attributes

| Source | Tier | License | Scope | What we extract |
|---|---|---|---|---|
| **Unicode CLDR** | A | Unicode License | 250 countries | Localized country names in 19 languages (M11.3) |
| **World Bank Indicators** | A | CC-BY | 217 countries | Country population (2024), economic indicators (M11.4) |
| **UN M49 region codes** | A | Public Domain | 250 countries | Continent/region hierarchy |

## Per-city attributes

| Source | Tier | License | Scope | What we extract |
|---|---|---|---|---|
| **US Census Bureau** | A | Public Domain | 14,459 US cities | State, county, FIPS, population (M11.5) |
| **US Census ACS 5-Year** | A | Public Domain | 14,450 US cities | Demographics: sex/age, income, education, tenure, transport (M11.5.1) |
| **Eurostat LAU** | A | CC-BY | 41,571 EU cities | Local Administrative Unit codes (M11.6) |
| **Eurostat URAU** | A | CC-BY | 597 EU cities | Urban centres + Functional Urban Areas (M11.6) |
| **Census of India 2011** | A | Public Domain | 963 IN cities | Population, state, district (M11.7) |
| **NCEI GSOM** | A | Public Domain | 10,559 cities | Real monthly climate (TMAX, TMIN, PRCP) (M11.8) |
| **Wikidata SPARQL** | D | CC0 | 148,331 cities | Q-ids, P-codes, descriptions, alt labels (M11.2-M11.2.8) |

## Postcodes

| Source | Tier | License | Scope | What we extract |
|---|---|---|---|---|
| **GeoNames postalCodes** | D | CC-BY | 844K postcodes | Country, admin-1, city, lat/lon (M4) |

## Translations

| Source | Tier | License | Scope | What we extract |
|---|---|---|---|---|
| **GeoNames alternateNamesV2** | D | CC-BY | 2,965,561 rows | City name translations in 19 languages (M5) |

## Holidays

| Source | Tier | License | Scope | What we extract |
|---|---|---|---|---|
| **OpenHolidays API** | D | ODbL | 36 EU countries | NL public holidays (M13) |
| **Nager.Date** | D | MIT | 202 countries | US + NL + NZ + IN + GB public holidays (M13, M14) |
| **Employment New Zealand** | A | Crown Copyright | NZ | Official NZ public holidays with actual + observed dates (M14) |
| **5 U.S.C. § 6103** | A | Public Domain | US | Federal holiday rules (M14) |
| **Hebcal** | D | MIT | Global | 18 Jewish holidays per country (M14) |
| **United Nations** | B | Public Domain | Global | 178 international days (M14) |
| **Computed (Meeus)** | C | Internal | Global | 4 seasons per year, US DST (M14) |
| **Computed (Computus)** | C | Internal | Global | Easter, Good Friday, Easter Monday, Ascension, Pentecost (M14) |
| **Bank of England + HM Treasury** | A | Crown Copyright | UK | UK bank holidays (M14) |

## What we are NOT using (and why)

| Source | Why not |
|---|---|
| **Timeanddate.com** | Per spec section 2.1, no scraping. Paid API too expensive for MVP. |
| **Calendarific** | $49+/mo. Defer until revenue. |
| **Holiday API** | $9+/mo. Defer until revenue. |
| **Wikidata for holidays** | Sparse. 0 NZ public holidays tagged with P31/P17. |
| **OPM (Office of Personnel Management)** | 403 from our IP. Use 5 USC § 6103 + computed rules instead. |
| **legislation.govt.nz** | Cloudflare-protected. Employment NZ has the same data in plain English. |
| **Hebcal full (~150 items)** | We filter to major + minor + modern Jewish holidays (18-20 per year per country). |
| **Vatican (Catholic)** | 404 from our IP. We use computed Easter-based rules instead. |
| **DrikPanchang (Hindu)** | 404 from our IP. Stored as disabled source for future activation. |

## Adding a new source (checklist)

1. **Find tier** — is it official (A/B), open (D), or community (F)?
2. **Verify license** — ODbL, CC-BY, MIT, public domain, or paid?
3. **Check scope** — country, region, or global?
4. **Add to `holiday_source` or `source_registry`** with tier, license, attribution
5. **Stage if it's bulk data** — `cities_staging` or similar
6. **Write the loader script** in `scripts/seed/<source_name>.py`
7. **Add tests** in `tests/<source>.test.ts`
8. **Add a doc reference** in `docs/references/sources/`
9. **Update `data-sources-master.md`** with the new entry
10. **Run the loader via wrangler d1 execute --file=** for speed (10x faster than HTTP API)
