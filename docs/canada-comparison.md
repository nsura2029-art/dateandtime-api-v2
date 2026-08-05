# Canada Holiday Data: Calendarific vs timeanddate.com

## TL;DR

Calendarific has **184 holidays** for Canada 2026 across **107 unique concepts** and **13 provinces/territories**. timeanddate.com shows only the curated **Statutory + Observance** subset (about 30 holidays in the screenshot).

**Calendarific wins for breadth, timeanddate wins for clarity of "is this a day off?"**

## What Calendarific has that timeanddate DOESN'T show

### 1. All religious observances (not in timeanddate UI)

| Calendarific has | timeanddate UI |
|---|---|
| Epiphany, Carnival, Ash Wednesday, Palm Sunday, Maundy Thursday, Holy Saturday, Pentecost, Corpus Christi, Trinity Sunday, Ascension Day | (most hidden) |
| All 17 Jewish holidays (Tu B'Shevat, Purim, Passover, Lag B'Omer, Shavuot, Tisha B'Av, Yom HaShoah, Yom HaAtzmaut, etc.) | (none) |
| All 6 Orthodox holidays (Christmas, Easter, etc.) | (none) |
| 8 Muslim holidays (Isra/Mi'raj, Ramadan, Eid, Muharram, Ashura, Milad) | (none) |
| Buddhist (none in our data — but supported) | (none) |

### 2. All 4 seasons (equinoxes/solstices)
- March Equinox, June Solstice, September Equinox, December Solstice

### 3. Both clock changes
- DST starts (Mar 8) + DST ends (Nov 1)

### 4. Cultural observances
- Groundhog Day, Valentine's Day, Lunar New Year, St David's Day, Commonwealth Day, Tartan Day, Mother's Day, Father's Day, Gold Cup Parade, etc.

### 5. Provincial naming variations
The August long weekend is famous for having different names in each province:

| Province | Aug 3 2026 Name |
|---|---|
| AB, ON, MB, NS, NT, NU, PE, SK | Civic/Provincial Day |
| BC | British Columbia Day |
| NB | New Brunswick Day |
| SK | Saskatchewan Day |
| NS (some areas) | Natal Day |
| AB (some areas) | Heritage Day |
| NL | The Royal St John's Regatta (Regatta Day, not same day) |
| MB (some) | Terry Fox Day |

Calendarific gives all 8+ variants. timeanddate shows only "Civic Holiday" generically.

## What timeanddate has that we label differently

### Statutory vs Observance

timeanddate uses **2 buckets**: `Statutory` and `Observance`. Our schema uses 3:
- `PUBLIC_NATIONAL` = Federal statutory (5 in CA)
- `PUBLIC_LOCAL` = Provincial statutory (~14-20 in CA, varies)
- `OBS_*` = Observances

Examples:
| Holiday | timeanddate | Our schema |
|---|---|---|
| Canada Day | Statutory | `PUBLIC_NATIONAL` |
| Civic Holiday (Aug 3) | Statutory | `PUBLIC_LOCAL` (in 8 provinces) |
| Saint Jean-Baptiste (Jun 24, QC) | Statutory | `PUBLIC_LOCAL` (QC only) |
| Remembrance Day (Nov 11) | Statutory (fed) | `PUBLIC_NATIONAL` (federal) + `PUBLIC_LOCAL` (provincial) |
| National Day for Truth & Reconciliation (Sep 30) | Statutory (fed) / Observance (most) | `PUBLIC_NATIONAL` (federal gov) + `OBS_*` (most employers) |
| Boxing Day (Dec 26) | Statutory (some) / Observance (most) | `OPTIONAL_HOLIDAY` (most provinces) |
| National Indigenous Peoples Day (Jun 21) | Observance | `OBS_COMMON` |

## Recommended Canada Filter Policy

### 21 filters visible in timeanddate-style UI for Canada:

| Filter Code | Count 2026 | Mapped to timeanddate |
|---|---|---|
| `PUBLIC_NATIONAL` | 11 (5 federal + 6 widely-observed) | Federal/National Holidays |
| `PUBLIC_LOCAL` | 31 (provincial) | Local Holidays |
| `PUBLIC_COMMON_LOCAL` | 8 (Family Day in 5 provinces, Thanksgiving in some) | Common Local Holidays |
| `OPTIONAL_HOLIDAY` | 5 (Boxing Day, etc.) | Optional Holidays |
| `OBS_IMPORTANT` | 7 (National Indigenous Peoples Day, etc.) | Important Observances |
| `OBS_COMMON` | 25 (Valentine's, Mother's Day, etc.) | Common Observances |
| `OBS_LOCAL` | 6 (Heritage Day, Natal Day, etc.) | Local Observances |
| `SEASON` | 4 | Seasons |
| `CLOCK_CHANGE` | 2 | Clock Change Dates |
| `CHRISTIAN_MAJOR` | 5 (Christmas, Easter, etc.) | Major Christian |
| `CHRISTIAN_MORE` | 12 (Ash Wed, etc.) | More Christian |
| `JEWISH_MAJOR` | 8 (Passover, Yom Kippur implied, etc.) | Major Jewish |
| `JEWISH_MORE` | 9 (Tu B'Shevat, Purim, etc.) | More Jewish |
| `MUSLIM_MAJOR` | 5 (Eid al-Fitr, Eid al-Adha, etc.) | Major Muslim |
| `MUSLIM_MORE` | 3 (Isra/Mi'raj, etc.) | More Muslim |
| `ORTHODOX_MAJOR` | 3 (Orthodox Christmas, etc.) | Major Orthodox |
| `ORTHODOX_MORE` | 3 (Orthodox Easter Monday, etc.) | More Orthodox |
| `HINDU_MAJOR` | 0 (no Hindu data) | Major Hindu (empty) |
| `HINDU_MORE` | 0 (no Hindu data) | More Hindu (empty) |
| `WORLD_OBSERVANCE` | varies | Worldwide Observances |
| `UN_OBSERVANCE` | varies | UN Observances |

**Total: 21 filters visible** (vs US=18, IN=13, NL=4)

## Comparison: CA vs IN vs US

| Filter | Canada | India | US | Notes |
|---|:---:|:---:|:---:|---|
| **PUBLIC_NATIONAL** | 11 | 116 | ~10 | CA has clean federal list; IN has many gazetted |
| **PUBLIC_LOCAL** | 31 | 134 | ~52 | CA has 13 provinces; IN has 28 states |
| **PUBLIC_COMMON_LOCAL** | 8 | — | — | CA's "Family Day" in 5 provinces |
| **OPTIONAL_HOLIDAY** | 5 | 20 | — | IN has Restricted Holidays |
| **OBS_IMPORTANT** | 7 | — | — | CA's National Day for Truth |
| **OBS_COMMON** | 25 | — | — | CA's Valentine's, Mother's Day, etc. |
| **OBS_LOCAL** | 6 | 7 | — | CA's Heritage Day, Natal Day, etc. |
| **SEASON** | 4 | 4 | 4 | All countries |
| **CLOCK_CHANGE** | 2 | 0 | 2 | DST in CA + US, not IN |
| **CHRISTIAN_MAJOR** | 5 | 4 | ~7 | Similar |
| **CHRISTIAN_MORE** | 12 | 5 | ~10 | More Christian in CA |
| **JEWISH_MAJOR** | 8 | 0 | 0 | **CA unique** (small community, but Jewish holidays tracked) |
| **JEWISH_MORE** | 9 | 0 | 0 | **CA unique** |
| **MUSLIM_MAJOR** | 5 | 5 | 1 | IN has more |
| **MUSLIM_MORE** | 3 | 15 | 0 | IN has many more |
| **HINDU_MAJOR** | 0 | 23 | 1 | **IN unique** (large Hindu community) |
| **HINDU_MORE** | 0 | 68 | 0 | **IN unique** |
| **ORTHODOX_MAJOR** | 3 | 0 | 0 | **CA unique** (Greek/Ukrainian diaspora) |
| **ORTHODOX_MORE** | 3 | 0 | 0 | **CA unique** |
| **BUDDHIST** | 0 | 22 | 0 | **IN unique** |
| **SIKH / JAIN / OTHER_RELIGION** | 0 | 21 | 0 | **IN unique** (Sikh/Jain in IN) |
| **SPORTING_EVENT** | 0 | 0 | varies | **US unique** (Super Bowl etc.) |
| **WORLD_OBSERVANCE** | varies | varies | varies | All |
| **UN_OBSERVANCE** | varies | varies | varies | All |

**Total filter slots: CA=21, IN=15, US=18**

### Key insight: Religion is a HUGE differentiator

| Tradition | Canada | India | US |
|---|:---:|:---:|:---:|
| Hindu | 0 | 91 | 0 |
| Christian | 18 | 9 | ~20 |
| Jewish | 17 | 0 | 0 |
| Muslim | 8 | 20 | 1 |
| Orthodox | 6 | 0 | 0 |
| Sikh | 0 | 20 | 0 |
| Buddhist | 0 | 22 | 0 |
| Jain | 0 | 1 | 0 |
| Secular | ~130 | 114 | ~1500 |

**The 36-filter global vocabulary handles all 3 countries well — each country just activates the relevant subset.**

## Source strategy for Canada

| Tier | Source | Used for |
|---|---|---|
| A1 | Government of Canada (canada.ca) | 5 federal statutory holidays (Canada Labour Code) |
| A2 | Province labour standards (13 sites) | Provincial statutory holidays |
| C | Wikipedia "Public holidays in Canada" | Structure + tradition |
| C | timeanddate.com | Cross-validate + UX labels |
| D | Calendarific API | Breadth (107 concepts incl. all religious) |
| ~~D~~ | ~~nager.date~~ | NOT USED (only ~10 federal entries, redundant) |

## Calendarific vs API for Canada — what we have

```
GET /api/v1/countries/CA/holidays?year=2026
→ 184 occurrences, 107 concepts, 13 provinces/territories
```

The data is loaded. 23-row country filter policy for CA just applied to D1.

## Open issue: Public vs Private filter counts

The `PUBLIC_NATIONAL` count of 11 in our DB for CA comes from Calendarific's "national holiday" domain (11 concepts). But only 5 are strictly federal statutory. The other 6 (Good Friday, Victoria Day, Civic Holiday, Thanksgiving, Remembrance Day, Boxing Day) are widely observed but technically:
- Good Friday/Easter Monday: federal employees get these, but QC classifies as "optional"
- Victoria Day: federal holiday, not statutory
- Civic Holiday: provincial, not federal
- Thanksgiving: federal holiday in all provinces except NS (where it's observed)
- Remembrance Day: federal (Veterans Affairs), but statutory holiday only in 6 provinces
- Boxing Day: statutory only in ON, OBS in most others

**Recommendation:** Tag "Remembrance Day" with both `PUBLIC_NATIONAL` and `OBS_*` (federal observance + statutory in 6 provinces).
