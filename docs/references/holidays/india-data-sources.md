# India Holiday Data Sources — Research

**Date:** 2026-08-03
**Owner:** Mavis (dateandtime-api-v2)

## Tier A — Controlling

### 1. Department of Personnel and Training (DoPT)
- **URL:** https://dopt.gov.in/
- **Coverage:** Central government holidays (gazetted holidays + restricted holidays)
- **Status:** ⚠️ Limited public access, government site is slow
- **Notes:** 2026 list not yet published at the time of research. Will need to be loaded later in the year or via secondary sources.

### 2. State Gazettes
- **Coverage:** State-specific gazetted holidays (each of 28 states + 8 UTs)
- **Status:** ⚠️ Per-state, manual
- **Notes:** Each state has its own calendar. We use Nager.Date for the national holidays + computed + Hebcal for Jewish + UN list.

## Tier B / D — Practical Sources

### 1. Nager.Date (India)
- **URL:** https://date.nager.at/api/v3/PublicHolidays/2026/IN
- **Status:** ✅ Free JSON
- **What it provides:** ~20-30 national Indian holidays (Republic Day, Independence Day, Gandhi Jayanti, Diwali national observance, etc.)
- **License:** MIT
- **Notes:** For India has 14 holidays for 2026 (mostly national gazetted + a few important religious ones). Doesn't cover state-level or all religious festivals.

### 2. Wikipedia: Indian Festivals
- **URL:** https://en.wikipedia.org/wiki/List_of_Hindu_festivals
- **Status:** ✅ Free
- **Notes:** Comprehensive list of Hindu festivals. Used as cross-check.

### 3. India.gov.in Holidays
- **URL:** https://india.gov.in/calendar
- **Status:** ⚠️ Public but limited
- **Notes:** The official government calendar.

## Tier C — Computed

### 1. Indian national holidays (rule-based)
- Republic Day: Jan 26
- Independence Day: Aug 15
- Gandhi Jayanti: Oct 2
- These are fixed dates, no computation needed.

### 2. Hindu festivals (computed from panchang)
- Requires Tithi (lunar day) computation
- Defer to Phase 2 (DrikPanchang integration)

### 3. Muslim holidays (computed from Hijri calendar)
- Eid al-Fitr, Eid al-Adha, etc.
- Defer to Phase 2

## Tier D — Religious

### 1. Hebcal (Jewish holidays for India)
- Jewish community in India (Bene Israel, Cochin Jews)
- Yom Kippur, Rosh Hashana, etc.
- Loaded via Hebcal API for all countries

## What we plan to load for India (M14)

| Category | Source | Count estimate |
|----------|--------|---------------:|
| National gazetted holidays | Nager.Date | ~14 |
| Jewish holidays | Hebcal | 18 |
| Christian holidays (Christmas, Good Friday) | Nager.Date + computed | 4 |
| Muslim holidays (Eid al-Fitr, Eid al-Adha) | Nager.Date if has, else defer | 2-4 |
| Sikh holidays (Guru Nanak Jayanti, etc.) | Nager.Date | 2-3 |
| Buddhist holidays (Buddha Purnima) | Nager.Date | 1 |
| UN observances (observed in India) | UN list | ~50-100 |
| Worldwide observances (Mother's Day, etc.) | Rule-based | 5-10 |
| Seasons | Computed | 4 |
| **TOTAL** | | **~100-150** |

## Filtering Notes

- India's variance endpoint should show these filters:
  - `PUBLIC_NATIONAL` (gazetted)
  - `OPTIONAL_HOLIDAY` (restricted)
  - `CHRISTIAN_MAJOR`, `CHRISTIAN_MORE`
  - `HINDU_MAJOR`, `HINDU_MORE`
  - `MUSLIM_MAJOR`, `MUSLIM_MORE`
  - `SIKH_MAJOR` (need to add)
  - `BUDDHIST` (need to verify)
  - `JEWISH_MAJOR`, `JEWISH_MORE`
  - `UN_OBSERVANCE`
  - `WORLD_OBSERVANCE`
  - `SEASON`
  - `CLOCK_CHANGE`
- Estimated: 12-15 filters (vs US=18, NL=4)
