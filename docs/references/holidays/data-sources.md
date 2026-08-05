# Holiday Data Sources — Research Reference

**Date:** 2026-08-03
**Status:** Living document. Update as new sources are evaluated.
**Owners:** Mavis (dateandtime-api-v2)

This document tracks every data source considered for the holiday enrichment engine (M14).
It feeds the enrichment pipeline at `scripts/seed/holiday_enrichment/`.

---

## Source Tier System (per spec section 7)

| Tier | Definition | Trust |
|------|------------|-------|
| **A** | Law, gazette, government ministry, central bank, official exchange, UN resolution | Controlling truth |
| **B** | Official calendar, agency ICS, official religious authority | Controlling unless superseded |
| **C** | Licensed specialist provider such as Timeanddate | Accelerator/cross-check, license-dependent |
| **D** | Approved open provider such as OpenHolidays or Nager.Date | Accelerator/cross-check |
| **E** | Institutional (employer group, industry body) | Scope-limited |
| **F** | Community (Wikipedia, calendars.usholiday.com) | Cross-check only |

---

## Tier A — Official / Controlling

### 1. Employment New Zealand
- **URL:** https://www.employment.govt.nz/leave-and-holidays/public-holidays/public-holidays-and-anniversary-dates
- **Coverage:** NZ only
- **Status:** ✅ Accessible, tier A
- **Format:** HTML tables (2 tables: 2026 public holidays + 2026 anniversary dates; same for 2027)
- **What it provides:**
  - 12 national public holidays with actual + observed dates
  - 12 regional anniversary days with actual + observed dates
  - Canonical rules (e.g., "King's Birthday = 1st Monday in June")
- **Notes:** Far better than the user's CSV (which only has observed Mondays). The official page has BOTH actual and observed as separate fields. Used for NZ.
- **Saved in:** `docs/references/holidays/nz-employment-nz-2026-2027.md`

### 2. 5 U.S.C. § 6103 (US Federal)
- **URL:** https://www.law.cornell.edu/uscode/text/5/6103
- **Coverage:** US federal holidays (11 per year)
- **Status:** ✅ Public, tier A
- **What it provides:** Statutory definition of US federal holidays. We compute the dates from the canonical rules.
- **Notes:** For full federal coverage we need a downstream OPM page, but the rules are simple enough to compute. Used for US federal holidays via `computed_federal_us` source.

### 3. US State Statutes (50+)
- **Coverage:** US state-level holidays
- **Status:** ⚠️ Manual, tier A
- **Notes:** Each state has its own statute. For MVP we use Wikipedia and Nager.Date as accelerators. Full integration is Phase 4+ of M14.

### 4. Holidays Act 2003 (NZ)
- **URL:** https://www.legislation.govt.nz/act/public/2003/0126/
- **Status:** ❌ Cloudflare-protected from us
- **Notes:** Mirrored by Employment New Zealand in plain English, so the gov page is enough.

---

## Tier B — Official / Operational

### 1. United Nations — International Days and Weeks
- **URL:** https://www.un.org/en/observances/list-days-weeks
- **Status:** ✅ Partially accessible (HTML loads 248KB)
- **Format:** HTML list of ~190+ international days/weeks
- **What it provides:** Canonical list of UN-observed days (International Day of Peace, World Water Day, etc.)
- **License:** Public Domain
- **Notes:** Tier B per spec. We scrape this and store in `holiday_un_day` table. Some days have resolved dates (e.g., International Day of Peace = Sep 21), others are floating (e.g., "first Sunday of October" for World Habitat Day).

### 2. GOV.UK Bank Holidays
- **URL:** https://www.gov.uk/bank-holidays.json
- **Status:** ✅ Free JSON
- **Coverage:** England&Wales, Scotland, Northern Ireland (separate jurisdictions)
- **What it provides:** 8-10 bank holidays per jurisdiction per year
- **License:** Open Government Licence v3.0
- **Notes:** Easy to integrate. Best next golden country after US/NL/NZ/India.

---

## Tier C — Computed

### 1. Astronomical Seasons (equinox/solstice)
- **Method:** Julian Day + Meeus astronomical algorithm (5 lines of code)
- **What it provides:** 4 events per year (March Equinox, June Solstice, September Equinox, December Solstice)
- **Source key:** `computed_season`
- **Notes:** USNO is the canonical source but we can compute this ourselves in code. No external dependency.

### 2. US Federal Holidays (computed)
- **Method:** 5 U.S.C. § 6103 rules + nth-weekday formula
- **What it provides:** 11 federal holidays per year
- **Source key:** `computed_federal_us`
- **Notes:** Better than scraping OPM (which is blocked for us). The rules are:
  - New Year's Day: Jan 1 (Mon shift)
  - MLK Day: 3rd Mon Jan
  - Presidents Day: 3rd Mon Feb
  - Memorial Day: last Mon May
  - Juneteenth: Jun 19
  - Independence Day: Jul 4
  - Labor Day: 1st Mon Sep
  - Columbus Day: 2nd Mon Oct
  - Veterans Day: Nov 11
  - Thanksgiving: 4th Thu Nov
  - Christmas: Dec 25

### 3. Easter-related holidays
- **Method:** Computus algorithm (Gregorian)
- **What it provides:** Easter Sunday + Good Friday, Holy Saturday, Easter Monday, Ascension, Pentecost, Mardi Gras, Ash Wednesday
- **Source key:** `computed_easter`

### 4. US Observances (rule-based)
- **Method:** 1-2 line formula per holiday
- **What it provides:** Mother's Day (2nd Sun May), Father's Day (3rd Sun Jun), Thanksgiving (4th Thu Nov), etc.

---

## Tier D — Open Providers

### 1. Nager.Date
- **URL:** https://date.nager.at/api/v3
- **Coverage:** 202 countries
- **Status:** ✅ Free, no auth
- **Format:** JSON
- **What it provides:** Public holidays per country, including state-level for some (e.g., US)
- **License:** MIT-style
- **Notes:** Cross-check source. For NZ has 23/40 entries; for US has 84/571 entries. Use as accelerator, not as truth.

### 2. OpenHolidays
- **URL:** https://openholidaysapi.org
- **Coverage:** 36 countries (EU + a few non-EU)
- **Status:** ✅ Free, ODbL
- **What it provides:** Public holidays + school holidays
- **Notes:** 100% subset of Nager.Date for our priority countries. Used for NL currently.

### 3. Hebcal (Jewish holidays)
- **URL:** https://www.hebcal.com/hebcal
- **Status:** ✅ Free JSON, MIT-licensed
- **Coverage:** Global Jewish holidays (~150 items/year)
- **What it provides:** Yom Kippur, Rosh Hashana, Passover, Hanukkah, etc. with Hebrew dates
- **Notes:** Tier D per spec. Excellent for Jewish holidays worldwide. Used in enrichment engine for all countries.

### 4. DrikPanchang (Hindu panchang)
- **URL:** https://www.drikpanchang.com
- **Status:** ⚠️ 404 on public access, may need API key
- **License:** CC-BY
- **What it provides:** Hindu panchang (Tithi, Nakshatra, Yoga, Karana, festivals)
- **Notes:** Disabled until API access is established. Stored in `holiday_source` table for future activation.

### 5. IslamicFinder
- **URL:** https://www.islamicfinder.org/islamic-calendar/2026/
- **Status:** ✅ HTML accessible
- **What it provides:** Islamic holidays (Eid al-Fitr, Eid al-Adha, Ramadan, etc.)
- **Notes:** Per-country moon sighting makes this complex. Defer to Phase 2 for proper Hijri calendar integration.

### 6. Wikipedia: International Observances
- **URL:** https://en.wikipedia.org/wiki/Lists_of_holidays
- **Status:** ✅ Accessible (204KB)
- **What it provides:** Religion-organized list of all observances worldwide
- **License:** CC-BY-SA
- **Notes:** Used as cross-check / fallback source for obscure holidays.

---

## Tier E — Institutional

### 1. Wikipedia: Federal holidays in the United States
- **URL:** https://en.wikipedia.org/wiki/Federal_holidays_in_the_United_States
- **Status:** ✅ Accessible (360KB)
- **What it provides:** US federal holiday list with detailed history and rule changes over time
- **Notes:** Cross-check source for US.

### 2. Wikipedia: State holidays (United States)
- **URL:** https://en.wikipedia.org/wiki/State_holidays_(United_States)
- **Status:** ⚠️ Rate-limited
- **Notes:** Used in research, batch-load when needed.

---

## Source Coverage Summary

| Country | Tier A | Tier B | Tier C | Tier D | Tier E | Total |
|---------|--------|--------|--------|--------|--------|-------|
| **US** | 5 USC § 6103 | — | Computed federal | Nager.Date | Wikipedia | 84→500+ |
| **NL** | Government.nl | — | Computed Easter | OpenHolidays, Nager.Date | Wikipedia | 22+ |
| **NZ** | Employment NZ | — | Computed Easter | Nager.Date | Wikipedia | 23→40 |
| **IN** | DoPT + state gazettes | — | Computed | Nager.Date, Hebcal | Wikipedia | 0→50+ |
| **UK** | GOV.UK | — | Computed Easter | Nager.Date | Wikipedia | 0→28 |
| **Global UN days** | UN resolutions | UN.org | — | — | Wikipedia | 0→190+ |

---

## What we are NOT using (and why)

| Source | Why not |
|--------|---------|
| **Timeanddate** | Per spec section 2.1, no scraping. Paid API too expensive. |
| **Calendarific** | $49+/mo. Defer until revenue. |
| **Holiday API** | $9+/mo. Defer until revenue. |
| **Wikidata for holidays** | Sparse. 0 NZ public holidays tagged with P31/P17. Not worth the effort. |
| **OPM direct** | 403 Forbidden from our IP. Use 5 USC § 6103 + computed rules instead. |
| **legislation.govt.nz** | Cloudflare-protected. Employment NZ has the same data in plain English. |

---

## See also

- `docs/references/holidays/nz-employment-nz-2026-2027.md` — NZ data dump
- `docs/references/holidays/us-csv-2026.md` — US 2026 authoritative list
- `docs/references/holidays/india-nager-research.md` — India data sources
- `docs/references/holidays/un-international-days.md` — UN days compilation
- `migrations/157_holiday_worldwide_and_categories.sql` — schema for the enrichment engine
- `scripts/seed/holiday_enrichment/` — the enrichment engine itself
