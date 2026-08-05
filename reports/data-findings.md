# Data findings — what the database actually says

**Date:** 2026-08-02
**Source:** `timeandtimepro-full-v2` D1 (live, 152,970 cities, 250 countries)

A walk through the data with the lens of "what's interesting, what would a journalist write about, what would a product manager build on top of."

## Headline numbers

| Metric | Value | Notes |
|---|---:|---|
| Cities | 152,970 | All pop ≥ 15K (dr5hn cities15000) |
| Countries/territories | 250 | |
| IANA timezones in use | 378 | 462 in DB total, 378 used by cities |
| World population in DB | 3.49B | ~43% of ~8B (rest are sub-15K villages) |
| Capital cities | 201 | country-level |
| State capitals | 3,152 | state/province level |
| Null population | 35,546 | 23% of dataset (small towns, dr5hn gap) |
| Unique city names | ~110K | the rest are duplicates |

## Fun facts

### Population concentration: 49% of tracked population lives in just 1,175 cities (0.8%)

```
Top 1% of cities (1,175) hold 1.72B of 3.49B (49.3%)
```

This is the canonical Pareto distribution. Useful framing for any "how should we prioritize city features?" question — focus on the top ~1,000 cities for any mainstream feature, the rest are long tail.

### Asia/Shanghai covers ~550M people (16% of world pop)

```
Asia/Shanghai  : 549M pop in 1,353 cities
Asia/Kolkata   : 298M pop in 3,171 cities
America/Sao_Paulo: 121M in 2,932 cities
America/New_York: 111M in 7,291 cities
```

**That's bigger than every other country's capital combined.** The whole reason China is a single time zone is political (1949 unification) — the sun is at its highest in Urumqi (UTC+6 natural zone) when clocks say 2pm in Beijing (UTC+8). So at lunch in Beijing, people in western China are still eating breakfast.

### France has 5 timezones — for a country that's 1 timezone wide

Most people think France = Paris = UTC+1. But France has territories on every continent:

- Réunion (Indian Ocean, UTC+4)
- Mayotte (Indian Ocean, UTC+3)
- French Guiana (South America, UTC-3)
- Saint Pierre & Miquelon (North America, UTC-3)
- New Caledonia, French Polynesia, Wallis & Futuna (Pacific)
- Guadeloupe, Martinique, Saint Martin, Saint Barthélemy (Caribbean)

10+ timezones total. France has more timezones than Russia (11) per square km. The "12 TZs" urban legend is true for the country though — actually 10+ depending on how you count.

### Capitals that are NOT the biggest cities (16+ examples)

| Country | Capital | Pop | Why it matters |
|---|---|---:|---|
| 🇸🇦 Saudi Arabia | Riyadh | 4.2M | (Jeddah bigger historically) |
| 🇹🇷 Turkey | Ankara | 3.5M | (Istanbul 15.7M, 4.5x bigger) |
| 🇳🇬 Nigeria | Abuja | 2.7M | (Lagos 15.4M, 5.7x bigger) |
| 🇧🇷 Brazil | Brasília | 2.2M | (São Paulo 12M+) |
| 🇿🇦 South Africa | Pretoria | 2.1M | (Johannesburg ~5M) — 3 capitals actually |
| 🇦🇪 UAE | Abu Dhabi | 1.8M | (Dubai 3.5M) |
| 🇲🇦 Morocco | Rabat | 1.7M | (Casablanca 3.7M) |
| 🇨🇦 Canada | Ottawa | 1.0M | (Toronto 5.9M, Montréal 4.3M) |
| 🇲🇲 Myanmar | Nay Pyi Taw | 925K | (Yangon 5M, newer capital built 2006) |
| 🇹🇿 Tanzania | Dodoma | 765K | (Dar es Salaam 7.4M) |
| 🇳🇱 Netherlands | Amsterdam | 742K | (The Hague is gov, Rotterdam 656K) |
| 🇵🇰 Pakistan | Islamabad | 602K | (Karachi 16M, 26x bigger) |

This is a big UX issue for any "show me the capital" feature. Half the time the "capital" is administrative, not where people actually live.

### Same-name collision champions

| Name | Count | Countries |
|---|---:|---|
| Merkez | 51 | TR (Turkish for "center") |
| Santa Cruz | 34 | 13 countries |
| San Isidro | 34 | mostly AR, MX |
| San Antonio | 32 | 11 countries |
| San Francisco | 28 | 11 countries |
| Victoria | 27 | **15 countries** |
| Richmond | 27 | 4 countries (AU, US, CA, NZ) |
| San Miguel | 27 | 12 countries |
| Bristol | 12+ | 2 countries (GB + 11 in US) |
| Paris | 4 | FR, US, CA, others |
| Springfield | 23+ | US (20) + JM (2) + AU (1) |

"Merkez" is just a Turkish transliteration of "center" — every Turkish district has one. 51 of them.

### Cities with extreme name lengths

**Longest:** 59 characters

```
Colonia Ecológica Asociación de Lucha Social (Lucha Social)  [MX]
```

dr5hn's official names for Mexican ejidos and colonias are *wild*. They include the parent organization name in parentheses.

**Shortest:** 1 character

- `U` in Micronesia (FM) — yes, a single letter is a city name
- `Y` in Alaska (US)
- `Au` in Austria (AT)

### The "Bikini Atoll" surprise

We have a city named `Bikini` (Bikini Atoll, Marshall Islands) in our DB, with 23 translations. The Japanese translation is `ビキニ (水着)` — literally "bikini (swimsuit)." The French translation is `Bikini (vêtement)` — "bikini (clothing)." The translations reflect how the **word** bikini entered the language, not the atoll. Fun fact: the swimsuit was named after the atoll because French designers tested it there in 1946.

### India is concentrated in 5 states

```
Uttar Pradesh    618 cities
Maharashtra      557
Tamil Nadu       350
Gujarat          303
Madhya Pradesh   273
```

These 5 states hold 2,101 of the 4,198 IN cities (50%). And yet they're home to ~600M people — 43% of India's 1.4B. The 168 cities in Andhra Pradesh cover a state of 50M+ people. Lots of people, not many tracked places.

### US: state-level data skew

| State | Cities in DB |
|---|---:|
| CA | 1,066 |
| TX | 1,022 |
| NY | 991 |
| PA | 986 |
| FL | 777 |
| IL | 751 |
| OH | 667 |
| NJ | 531 |

The four most-populous states (CA, TX, NY, FL) dominate. But there's a twist: **CA and TX have 1,000+ cities, while Wyoming has ~50.** Population density × dr5hn coverage = state representation. Sparse states (WY, MT, ND) are dramatically under-counted in our DB.

### "Springfield" is a public-policy problem

The Simpsons' fictional hometown is the most-named city in the US (20+ Springfields across 17 states). 247K+ people live in a "Springfield" in the US, and they're spread across 20 distinct places. Any feature that says "show me the city named Springfield" without disambiguation is broken. We solved this in M6 (state filter, population ranking, etc.) but the dataset itself doesn't help.

### 149,764 cities have all 19 languages translated

That's 98% of the dataset. The remaining 2% are split-name cities (Moscow vs Moskva vs Moscou), disputed (Bikini Atoll as swimsuit), or just rare. **Translation coverage is the strongest signal of data quality we have.**

## Implications for the product

### 1. The 1,000-city problem

99% of users will only ever interact with the top 1,000-2,000 cities. Optimize the API for them: cache aggressively, eager-compute, return in <50ms. For the long tail (the 150K we don't have + the 150K we do), accuracy matters more than speed.

### 2. Locale and political reality

Showing "Beijing time" to a user in Urumqi is **technically correct but practically useless**. A real product needs to either:
- (a) Show the official time and let users be confused
- (b) Show the solar time (UTC+6 in Urumqi) and be politically incorrect
- (c) Show both and let users choose
- (d) Show the business hours of major cities and ignore western China

This is the kind of product decision no API can make. The data has to expose both.

### 3. The "village question" is a real product decision

Sub-15K villages are 1.5M+ places globally. Each of them is a real human's home. We have 0 of them. For a "where is the time in my village" feature, we need GeoNames cities5000 (or lower). That's Option B from the data platform work.

### 4. The capital paradox

If your product says "capital city: Brasilia" and the user is Brazilian, they already know São Paulo is where business happens. If the user is **not** Brazilian, the data is useful (they learn the political structure). Different products need different defaults.

### 5. Same-name search is a hard problem

We've solved the easy version (state filter, population ranking). The hard version — "Springfield, Illinois, USA, the one with a Simpsons museum" — needs Wikidata. Wikidata QIDs are stable cross-references to "the right Springfield" with provenance.

### 6. Translation has a confidence problem

23 translations for "Bikini Atoll" where the French translation is `Bikini (vêtement)` is funny but reveals an issue: **CLDR-style translations conflate "name in this language" with "what the word means in this language."** For product use, we want the first, not the second. Wikidata is better at this because it knows the *Q-item* (Q170292 Bikini Atoll) and its labels in 200+ languages, distinct from the *word* (Q852190 bikini swimsuit).

## What this tells me about the data platform

We have **rich data with known biases**:
- **Geographically biased** to US/EU
- **Population-biased** to top 1% of cities
- **Linguistically rich** but with conflation issues
- **Capital-centric** with weak ground truth on which cities are "important"
- **Time zone truth** is strong (we did M0-M10+)
- **Sub-15K villages are a known gap**

The data platform should add:
1. **GeoNames cities5000** — fills the village gap
2. **Wikidata** — stable QIDs for the same-name disambiguation problem
3. **CLDR** — proper locale-aware formatting, not just translations
4. **UN WPP** — population that doesn't have the 23% NULL gap
5. **US Census** — annual vintage tracking for 19,500 US places
6. **Eurostat** — proper FUA/City distinction for Europe
7. **Census of India** — fills the 168-AP-cities gap
8. **World Bank** — economic context for cities

The product opportunity is **a single API where the 49% in the top 1% get first-class treatment, the long tail gets accurate timezone + population + language, and the source of every row is auditable.**

That's the value.
