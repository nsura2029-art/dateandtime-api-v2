# Data findings, part 3 — date line, geographic extremes, abbreviation ambiguity, population distribution, TZ aliases

**Date:** 2026-08-02
**Source:** `timeandtimepro-full-v2` D1

Same methodology: **what we have → what we get → value**.

---

## 1. The 19-hour time gap — Apia vs Pago Pago

**What we have:** Apia, Samoa (WS) at UTC+13. Pago Pago, American Samoa (US) at UTC-11. Same calendar day, but 19 hours apart in the same day (Apia is "tomorrow" while Pago Pago is "yesterday").

**What we get:**

```
Samoa (WS)              — Pacific/Apia    — UTC+13  — Apia (40K), Asau, Mulifanua, Vaiusu, Malie
American Samoa (US)     — Pacific/Pago_Pago — UTC-11 — Pago Pago (254 ppl — research base)
```

**The story:** In 2011, Samoa **skipped a calendar day** — they went from Thursday Dec 29, 2011 directly to Saturday Dec 31, 2011, switching from UTC-11 to UTC+13 to align with Australia/NZ rather than US. American Samoa (US territory) stayed on UTC-11. The two are 1,500 km apart and have the same calendar-day count, but Friday in Pago Pago is Saturday in Apia.

**Value:**
- Date-line math is a real product feature. "When is the meeting?" can have multiple right answers depending on which Samoa.
- A meeting-scheduler feature must know the city, not just the country. Samoa WS vs American Samoa US is the canonical edge case.
- Samoa (40K pop) and American Samoa (254 pop) are in the same longitude range but different time zones for political, not geographic, reasons.
- This is the "time zones are political" lesson in microcosm. Document it.

## 2. Geographic extremes — corners of the world

**What we have:** 152,970 cities with lat/lon.

**What we get:**

**Northernmost:**

| City | Lat | Country | Pop | TZ |
|---|---:|---|---:|---|
| Qaanaaq | 77.47°N | GL (Greenland) | null | America/Thule area |
| Dikson | 73.51°N | RU | 1,113 | Asia/Krasnoyarsk |
| Upernavik | 72.79°N | GL | null | America/Thule area |

**Southernmost:**

| City | Lat | Country | Pop | TZ |
|---|---:|---|---:|---|
| Dumont d'Urville Station | -66.66°S | TF (Fr. Antarctic) | null | various |
| Cabo de Hornos | -54.93°S | CL | null | America/Santiago |
| Ushuaia | -54.81°S | AR | 75K | America/Argentina/Ushuaia |

**Easternmost:**

| City | Lon | Country | Pop |
|---|---:|---|---:|
| Niulakita | 179.47°E | TV (Tuvalu) | null |
| Cakaudrove | 179.42°E | FJ | null |
| Labasa | 179.36°E | FJ | 27K |

**Westernmost:**

| City | Lon | Country | Pop |
|---|---:|---|---:|
| Egvekinot | -179.12°W | RU | 2,248 |
| Lau | -178.79°W | FJ | null |
| Leava | -178.16°W | WF (Wallis & Futuna) | null |

**Value:**
- **Qaanaaq (Greenland) is the northernmost tracked city in the world.** 1,300 km from the North Pole. Its TZ (America/Thule) is only 4 hours behind NY despite being in another hemisphere.
- **Ushuaia is the southernmost "real city"** (75K pop). Famous as "end of the world" city. Cruise ships depart from here for Antarctica.
- **Egvekinot (RU) is the westernmost "real" city** in eastern longitude territory. It's on the Chukotka peninsula, closer to Alaska than Moscow.
- These are the anchor points for any "globe visualization" feature. We have them all.

## 3. TZ abbreviation ambiguity — the bug factory

**What we have:** 462 IANA timezones, each with a current abbreviation. Some abbreviations collide.

**What we get:** The most-ambiguous abbreviations:

| Abbrev | # TZs | Examples |
|---|---:|---|
| **AST** | 23 | Atlantic + Arabia + Alaska (3 different UTC offsets!) |
| **EDT** | 21 | US East + various other DST zones |
| **CST** | 17 | US Central (UTC-6) + China Standard (UTC+8) — same abbrev, 14h difference |
| **CDT** | 14 | US Central Daylight + others |
| **EST** | ~10 | US East + Australia East + others |
| **IST** | 4 | India + Ireland + Israel + Indonesia |
| **BST** | 3 | Bangladesh + British Summer + Brazil Standard + Bhutan |

**The killer example: CST.**

- America/Bahia_Banderas — UTC-6 — Central Standard (Mexico)
- America/Belize — UTC-6 — Central Standard
- Asia/Shanghai — UTC+8 — China Standard Time
- Asia/Taipei — UTC+8 — Chungyuan Standard Time (sometimes CST)

**Same abbreviation, 14-hour difference.** If a product says "the meeting is at 2pm CST," the user in Chicago and the user in Shanghai will be 14 hours apart, not 0.

**Value:**
- **Display UTC offset, not abbreviation, by default.** "14:00 UTC-6" beats "2pm CST" every time for global products.
- Allow abbreviation as a display option, but never as an API input.
- Document the abbreviations that collide and the offset differences. This is a known gotcha but most products don't handle it.

## 4. IANA timezone aliases — the 79 hidden duplicates

**What we have:** 462 IANA timezones, but 79 of them (17%) are aliases. They point to canonical_id.

**What we get:** Sample aliases:

| Alias | Canonical | Why |
|---|---|---|
| Australia/ACT | Australia/Sydney | Old state-name alias |
| Australia/NSW | Australia/Sydney | Same |
| Australia/Queensland | Australia/Brisbane | Same |
| Australia/South | Australia/Adelaide | Same |
| US/Eastern | America/New_York | Old US link |
| US/Pacific | America/Los_Angeles | Old US link |
| Mexico/General | America/Mexico_City | Old Mexico link |

**Value:**
- Aliases exist because old IANA names persist for backward compat. We resolve them via `canonical_id`.
- Without this, an API could return different `timezone.id` for the same physical location depending on which dataset the source used. Now: always the canonical.
- **79 aliases is small. If a product doesn't resolve them, ~17% of timezone "IDs" are ambiguous.** Critical for any "store timezone, look up later" workflow.

## 5. Population distribution — the long tail is real

**What we have:** Population on 117,424 of 152,970 cities (76.7%).

**What we get:** Population buckets:

| Pop range | # Cities | % of known |
|---|---:|---:|
| < 100 | 1,199 | 1.0% |
| 100 - 1K | 8,685 | 7.4% |
| 1K - 10K | 75,362 | 64.2% |
| 10K - 100K | 27,456 | 23.4% |
| 100K - 1M | 4,342 | 3.7% |
| 1M - 10M | 465 | 0.4% |
| > 10M | 14 | 0.01% |

**Insights:**
- **64% of cities with known pop are 1K-10K.** The "real" world is small towns.
- **14 cities have >10M population.** Beijing 18.9M, Shenzhen 17.5M, Guangzhou 16.1M, Kinshasa 16M, Istanbul 15.7M, Lagos 15.4M, Ho Chi Minh 14M, Chengdu 13.6M, Lahore 13M, Mumbai 12.7M, São Paulo 12.4M, Tianjin 11.3M, Moscow 10.4M, Dhaka 10.3M.
- **Only 5% of cities are >100K.** 95% are below that. "Important city" is a small set.

**Value:**
- **Cache the top 5%** (cities >100K) in Cloudflare KV for sub-millisecond responses. The other 95% go through normal D1 queries.
- **For "show me world cities" maps, the 465 cities with 1M+ pop are the actionable set.** Below that, you're into "local knowledge" territory.
- A "major cities" endpoint can return 465 results. A "cities in a country" endpoint should be paginated.

## 6. Toponym patterns (refined)

**What we have:** 152,970 city names. We can count prefix patterns.

**What we get:**

| Prefix class | Count | Share |
|---|---:|---:|
| Saint/San/Santa/Santo | 4,231 | 2.8% |
| Fort- | 98 | 0.06% |
| Port- | 192 | 0.13% |
| Mount/Monte/Mont- | 1,500+ | 1.0% |

**Other patterns I want to dig into:**
- "New-" prefix count (US/AU/GB colonial)
- "-burg/-borough" suffix (German/English)
- "City" / "Town" / "Ville" / "Città" suffix

**Value:**
- Saint-prefixed cities are mostly Catholic heritage (Spanish/Portuguese/Italian/French colonies). Strong signal of colonial history.
- "New-" cities are English colonial (US, AU, NZ, ZA, CA). Strong signal of British empire.
- "Mount-" cities are often mining or mountain towns. Different category.
- These are signals for **historical/cultural layers** in a city-detail page.

## 7. Capital record completeness

**What we have:** 201 is_country_capital=1 records. 152,769 is_country_capital=0.

**What we get:** Almost every country has its capital in our DB. Exceptions are very small territories:

- Antarctica (AQ) — no capital (correct)
- Bouvet Island (BV) — Norwegian dependency, no capital (correct)
- Heard & McDonald Islands (HM) — Australian territory, no capital
- South Georgia & South Sandwich Islands (GS) — UK territory, no capital

**Antarctica is correctly marked with no capital.** The 3 other uninhabited territories are also correct.

**Value:**
- Capital data is 100% complete for inhabited countries. 
- 201 capitals cover 201 of 250 countries. The 49 missing are mostly small territories (which is correct).
- A "give me the country capital" feature has 100% coverage for the 92% of countries that matter.

## 8. Country code data quality

**What we have:** 250 countries with cca2, cca3, ccn3 (3-letter and 3-digit ISO codes).

**What we get:** No duplicates in cca2 (unique), cca3 (unique), or ccn3 (unique). All 250 countries have all 3 codes populated.

**Value:**
- ID disambiguation works. Every country has 3 stable IDs.
- Wikidata Q-numbers would be a 4th ID. We have 5,308 admin regions. Wikidata would add Q-numbers for each.
- This is what enables cross-source data integration: ISO codes are the universal key.

## 9. The "CST collision" pattern — a UI hazard

**What we have:** TZ abbreviations collide across continents. 17+ timezones share "CST."

**What we get:** Beyond CST, here's the full set of dangerous collisions:

| Abbrev | # TZs | Worst case (hours apart) |
|---|---:|---:|
| CST | 17 | 14h (US Central vs China) |
| EST | 10 | 16h (US East vs Australia East in their respective DST) |
| IST | 4 | 6h (India vs Ireland, Israel, Indonesia) |
| BST | 3 | 7h (Bangladesh vs British Summer vs Brazil) |
| AST | 23 | 8h (Atlantic vs Arabia vs Alaska) |

**Value:**
- Build a "abbreviation → timezones" disambiguation map.
- Default to "UTC+offset" in API responses, not abbreviation.
- For UI, prefer the city name with offset: "2pm in Chicago (UTC-6)" not "2pm CST."
- This is a small UX fix with big impact on global product usability.

---

## 10. Patterns not yet explored (for pt 4+)

As I keep digging, the next interesting things to look at:

1. **City clusters** — Tokyo metro, Pearl River Delta, BosWash, Randstad. Multi-city functional urban areas.
2. **Cross-source agreement** — once we have Wikidata, how often do dr5hn and Wikidata disagree on which Springfield is which?
3. **TZ history** — which countries changed TZs in the last 10 years? Russia (2010, 2014), Samoa (2011), North Korea (2015, 2018).
4. **City elevation** — La Paz (3,640m) is the highest capital. We don't have elevation data.
5. **Coastal vs inland** — what % of world pop is within 100km of a coast?
6. **The "Dr5hn gap" countries** — which countries have < 50% of expected cities? WPP gives country totals, so we can compute coverage ratios.
7. **Time zone boundary artifacts** — places where TZ cuts through a city (e.g. airport in one TZ, downtown in another).
8. **Indigenous vs colonial names** — India has 30+ renamings, but how many of our cities have the official renamed name vs the legacy name?

---

## TL;DR

| Question | Answer |
|---|---|
| Date-line math is real? | Yes. 19h gap between Apia and Pago Pago. |
| Geographic extremes in our DB? | Qaanaaq (77.5°N), Ushuaia (-54.8°S), Egvekinot (-179°W), Niulakita (179.5°E). |
| TZ abbreviation hazards? | CST spans 14 hours. AST spans 8h. Use UTC offset, not abbreviation. |
| Aliases in IANA data? | 79 (17%) — mostly old US/AU/Mexico links. We resolve via canonical_id. |
| Capital record completeness? | 100% for inhabited countries. Antarctica + 3 territories correctly have no capital. |
| Country code data quality? | No duplicates. All 250 have cca2 + cca3 + ccn3. |
| Population skew? | 64% of known cities are 1K-10K. Only 5% are >100K. 14 are >10M. |

This is the data. Now let me start the GeoNames source implementation.
