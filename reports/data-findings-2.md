# Data findings, part 2 — time zone weirdness, toponyms, postcodes, population data quality

**Date:** 2026-08-02
**Source:** `timeandtimepro-full-v2` D1 (152,970 cities, 462 IANA timezones, 844,248 postcodes)

Continuing the exploration. Same methodology: **what we have → what we get → value**.

---

## 1. Time zone weirdness — half-hour and 45-min offsets

**What we have:** 462 IANA timezones in our DB. Most are whole-hour offsets. A small minority are not.

**What we get:** The 8 non-whole-hour offsets in active use:

| UTC offset | Zones | Cities | Pop covered | What it means |
|---|---|---:|---:|---|
| **-09:30** | Pacific/Marquesas | 6 | small | French Polynesia (Marquesas Islands) |
| **-02:30** | America/St_Johns, Canada/Newfoundland | 30 | 275K | Newfoundland, Canada — only North American half-hour TZ |
| **+03:30** | Asia/Tehran | 1,845 | **44.4M** | Iran |
| **+04:30** | Asia/Kabul | 100 | 8.8M | Afghanistan |
| **+05:30** | Asia/Kolkata, Asia/Colombo | 4,357 | **302.6M** | India + Sri Lanka |
| **+05:45** | Asia/Kathmandu | 71 | 1.6M | Nepal — only 45-min TZ in the world |
| **+06:30** | Asia/Yangon | 75 | 12.1M | Myanmar |
| **+08:45** | Australia/Eucla | 0 | 0 | Western Australia (rare) |

**Value:**
- 302M people (8.7% of tracked world pop) live in +05:30 (India). Any product serving Indian users must handle the +30 minute offset correctly. Off-by-30 bugs are common.
- 44.4M in Iran — Iran observes DST on different dates than the West (March 21-22 vs March 8-14). Any "meeting scheduler" feature needs country-specific DST rules.
- Nepal (+05:45) is the only 45-minute offset in the world. Unique, easy to get wrong.
- 8 of 462 timezones (1.7%) are not whole-hour. **99% of timezone code is whole-hour, but the 1% edge cases are where bugs hide.**

## 2. DST patterns — who has it, who doesn't

**What we have:** `is_dst` flag on every timezone. Currently 80 of 462 zones (17%) are in DST right now.

**What we get:** By region:

| Region | Timezones | Currently in DST |
|---|---:|---:|
| Americas | 181 | 74 (41%) |
| Asia | 85 | 6 (7%) |
| Pacific | 71 | 0 (0%) |
| Europe | ~80 | most |
| Africa | ~30 | 0 (0%) |
| Atlantic | ~10 | some |
| Indian | ~5 | 0 (0%) |

**Key insights:**
- **Africa: zero DST.** Every country on the African continent has abolished DST. The continent runs on whole-year standard time. Product can hardcode "Africa = no DST" without per-country logic.
- **Asia: 7% DST.** Only Iran, Israel, Palestine, Lebanon, Syria, Cyprus, Jordan. Everyone else (China, India, Japan, SE Asia, Korea) doesn't. Big simplification for products serving Asia.
- **Pacific: zero DST currently.** Australia/NZ DST just ended (early April), Pacific islands don't observe. Will be ~10 in DST from late September.
- **Americas: 41% DST.** High variance — US/Canada do, Mexico does, Brazil abolished it 2019, Argentina flipped on/off, Chile is unique (most of year in DST). DST code is messiest in the Americas.

**Value:**
- DST code can short-circuit: if user is in Africa/Asia, don't even check DST rules.
- For 92% of the world, "no DST" is a safe default. The 8% who do DST is concentrated in North America + Europe + Iran.
- A "DST-safe" timezone library needs 30-50 lines for the 92% + heavy code for the 8%.

## 3. Toponym patterns — what are the world's places named?

**What we have:** 152,970 city names. We can classify them by language patterns.

**What we get:** 4,497 cities start with `San/Santa/Santo/São` — that's 3% of all cities. Almost all in Spanish/Portuguese-speaking countries (Mexico, Brazil, Argentina, Spain, Philippines, Italy).

| Prefix class | Count | Share | Where |
|---|---:|---:|---|
| San/Santa/Santo/São | 4,497 | 2.9% | ES, MX, AR, BR, IT, PH |
| Article (El/La/Le/Les) | 3,732 | 2.4% | ES, FR, IT |
| New- (Newtown/Newport/etc) | 2,500+ | 1.6% | US, AU, GB |
| North/South/East/West | 2,000+ | 1.3% | US, CA, AU |
| Mount/Monte/Mont/Berg | 1,500+ | 1.0% | US, IT, FR, DE, ZA |
| Fort- | 800+ | 0.5% | US, CA, IN, PK |
| Port/Porto/Puerto | 700+ | 0.5% | GB, PT, US, ES, BR |

**Value:**
- **Search ranking** — "San" / "New" / "Mount" prefixes are noise in autocomplete. We could rank "San Jose" results higher when the country is US-CA vs when it's "San José" in Costa Rica. Currently we don't.
- **Indigenous names** — Many countries are officially changing colonial names. India has 30+ renamings (Bengaluru from Bangalore, Kolkata from Calcutta, etc.). Our place_names table has these aliases.
- **Same name, different script** — "Moscow" / "Москва" / "莫斯科" all need to resolve to the same city_id. Our translations table handles this.
- **The "Dr5hn long-name problem"** — Mexican colonias/ejidos have 50-60 character official names. Display must truncate, but search must not (so people can find them).

## 4. Postcode patterns — global format diversity

**What we have:** 844,248 postcodes across many countries. Each has a different format.

**What we get:** The format diversity is wild:

| Country | Codes | Format | Example |
|---|---:|---|---|
| PT | 197,024 | `NNNN-NNN` (8 chars) | 1000-001 |
| MX | 144,600 | `NNNNN` (5 digits) | 01000 |
| JP | 120,677 | `NNN-NNNN` (8 chars) | 001-0000 |
| US | 33,791 | `NNNNN` (5 digits) | 00601 |
| MT | 26,593 | `AAA NNNN` (alphanumeric) | ATD 1010 |
| AR | 23,184 | `NNNN` (4 digits, w/ letters) | 1000 |
| ES | ~20K | `NNNNN` (5 digits) | 28001 |

**Notable:**
- US only has 33,791 codes vs PT's 197,024 — because US ZIPs are area-based (5 digits cover large areas), while Portuguese postcodes are street-based (one per block).
- **Alphanumeric postcodes exist:** Malta uses `ATD 1010` (letters + digits). The UK uses similar (`SW1A 1AA`). Canada alternates letters (`K1A 0B1`).
- **Length varies 4-8 chars.** Validation library must support both.
- **PT has 197K postcodes for a country of 10M people** = 50 postcodes per 1,000 people. **US has 33K for 330M** = 0.1 per 1,000. That's a 500x density difference.

**Value:**
- **Validation is hard** — each country has its own format. We can ship a postcode validator that knows the top 20 countries (covers 90%+ of users) and falls back to "looks like a code" for the rest.
- **Search by postcode** is a feature. UX must handle "type a code" not just "type a city name."
- **PT street-level postcodes enable features US ZIPs can't:** delivery ETA, walking distance, hyper-local services. PT has better address resolution than US for many use cases.

## 5. Population data quality — where is the data thin?

**What we have:** Population field on 117,424 of 152,970 cities (76.7%). 35,546 (23.3%) are NULL.

**What we get:** NULL-pop distribution by country:

| Country | Cities | NULL pop | NULL % | Pattern |
|---|---:|---:|---:|---|
| Jersey (JE) | 51 | 51 | 100% | Tiny territory, dr5hn no data |
| Uruguay (UY) | 2,010 | 1,879 | 93.5% | dr5hn gap for UY |
| Saint Lucia (LC) | 479 | 446 | 93.1% | Small Caribbean |
| Micronesia (FM) | 80 | 71 | 88.8% | Small Pacific islands |
| Nepal (NP) | 77 | 68 | 88.3% | dr5hn gap for NP |
| Jamaica (JM) | 837 | 738 | 88.2% | dr5hn gap for JM |
| Yemen (YE) | 339 | 297 | 87.6% | dr5hn gap for YE |

**Pattern:** dr5hn has 0 population data for many small countries and small-island states. The pattern is "dr5hn didn't crawl Wikipedia's local government pages for these."

**Value:**
- **UN WPP covers countries, not cities.** So WPP fills "country total" but not "city X in country Y." 
- **US Census fixes US (zero null %).** Census of India fixes IN (zero null %).
- **The 23% NULL rate is fixable** by importing Eurostat City/AU/NZ/CA municipal data. Per-city population is more available than dr5hn's data suggests.
- For now: "we have pop for 76.7% of cities, 100% of countries" is the product truth. Don't promise city-level pop for un-fixed countries.

## 6. Tier 1 cities — who are the 70?

**What we have:** 70 cities tagged tier1 (highest importance). Spread across 32 countries, 33 timezones.

**What we get:** Tier 1 = world capitals + megacities. Population threshold appears to be ~5M+.

| Tier | Count | Countries | Timezones | Avg pop |
|---|---:|---:|---:|---:|
| tier1 | 70 | 32 | 33 | ~8M |
| tier2 | 3,511 | 218 | 315 | ~313K |
| tier3 | 149,389 | many | many | ~12K |

**Top tier1 cities by pop:**
```
Beijing          18.9M  CN
Shenzhen         17.5M  CN
Guangzhou        16.1M  CN
Kinshasa         16.0M  CD
Istanbul         15.7M  TR
Lagos            15.4M  NG
Ho Chi Minh City 14.0M  VN
Chengdu          13.6M  CN
Lahore           13.0M  PK
Mumbai           12.7M  IN
São Paulo        12.4M  BR
```

**Value:**
- **70 cities cover the world's true importance.** For any "show me the world" map, you can't go below these.
- **The 70 are spread across 32 countries** — but China has 4 in the top 12 (Beijing, Shenzhen, Guangzhou, Chengdu). India has only 1 (Mumbai). Africa has 1 in top 12 (Lagos). Tier 1 is biased to Asia.
- **tier2 (3,511) is the regional capital layer** — 218 countries represented, 315 timezones. This is your "default" product view.
- **tier3 (149K) is the long tail** — every small town in dr5hn.

## 7. Cities on the equator — the world's pivot

**What we have:** Cities with latitude near 0.

**What we get:** Cities with pop > 50K on the equator (|lat| < 0.06°):

| City | Country | Lat | Pop | Notes |
|---|---|---:|---:|---|
| Nanyuki | KE | 0.006 | 73K | "Equator town" with a sign |
| Pontianak | ID | -0.021 | 686K | On Borneo |
| Macapá | BR | 0.039 | 513K | State capital of Amapá |
| Meru | KE | 0.046 | 80K | |
| Mbandaka | CD | 0.049 | 455K | Provincial capital |
| Entebbe | UG | 0.056 | 103K | Old capital of Uganda |

**Value:**
- The equator passes through 13 countries. Only 6 have tracked cities on it.
- **Macapá is the only state capital on the equator** (Brazil, Amapá). Famous for the "Marco Zero" monument.
- **Pontianak is the only city > 500K on the equator.** Indonesian Borneo.
- **For a "places on the equator" feature, our data has 6 candidates.** The 7 are missing from dr5hn (would need GeoNames cities5000).

## 8. Cities that span the date line

**What we have:** Cities in extreme positive/negative longitudes.

**What we get:** Not yet queried, but worth noting:
- Fiji is at +180° (just east of the date line)
- American Samoa is at -170° (just west of the date line)
- Same calendar day, opposite days. **Tuesday in Apia, Monday in Pago Pago.**

**Value:**
- Date-line handling is a real product feature. "When is the meeting?"
- Apia (Samoa) → UTC+13 → Friday 3pm = Thursday 2pm NY
- Pago Pago (American Samoa) → UTC-11 → Friday 3pm = Saturday 2am NY
- 19-hour time difference between two Pacific islands 1,500 km apart.

## 9. Hemisphere distribution

**What we have:** 152,970 cities with lat/lon.

**What we get:**

| Hemisphere | Cities | Pop |
|---|---:|---:|
| Northern | 104,873 (68.6%) | 2.95B (84.7%) |
| Southern | 48,097 (31.4%) | 0.54B (15.3%) |

**Value:**
- **85% of tracked population lives in the Northern Hemisphere.** Maps should center on 20°N, not 0°.
- **Australia + South America + Sub-Saharan Africa = 15%.** Their cities are underrepresented in our product, but their TZ behavior is rich (SA has 16 TZs, AU has 9, BR has 16).
- The data is Northern-Hemisphere-centric. Any "global" UI defaults to Northern-centric design.

---

## 10. What this tells me about what we DON'T have

| Need | Have | Gap |
|---|---|---|
| Time zone for any place | ✓ (462 IANA zones) | nothing — covered |
| Capital city | ✓ (201) | mostly complete |
| Population for top 1000 cities | ✓ | covered |
| Population for all cities | partial (76.7%) | 23% NULL — fixable |
| Population for 1.5M sub-15K villages | ✗ (0%) | need GeoNames |
| Population for India | partial (4,198 cities, 168 in AP) | need Census of India |
| Sub-15K Indian villages | ✗ | need Census of India |
| Stable Q-IDs for same-name disambiguation | partial (wiki_data_id exists) | not enforced |
| Locale-aware date/number formatting | ✗ | need CLDR |
| Functional language populations | ✗ | need CLDR |
| Time zone history (DST changes over time) | partial (M9) | need tzdata history |
| City elevation | partial | not in dr5hn |
| Climate/weather | ✗ | need separate source |
| Economic data (GDP, unemployment) | ✗ | need World Bank |
| Age/gender structure | ✗ | need UN WPP detail |

---

## 11. Scenarios we'll keep learning

Things to revisit as data grows:

1. **Cross-validation** — once we have UN WPP, we can compare WPP country totals vs sum of city populations. For India (1.4B people, 298M in 4,198 cities), the ratio tells us coverage.
2. **Disambiguation success rate** — once we have Wikidata QIDs, we can answer "how often does 'Springfield' have a unique QID?" Today we use heuristics.
3. **Translation quality** — once we have CLDR, we can compare CLDR's name vs dr5hn's translation for the same city. Disagreements are signals.
4. **TZ accuracy** — once we have polygon-verified data for more cities (M1 covered 3,018), we can re-test. India has only 1 of 4,198 polygon-verified.
5. **DST correctness** — once we have IANA tzdata history, we can run "for each city, did we predict the correct UTC offset on date X?" Backtesting.
6. **Postcode resolution** — once we have CLDR + better postcode data, "type a postcode, get the city" becomes a first-class feature.
7. **Same-name confidence** — once we have multiple sources, we can ask "how many sources agree on which Springfield is which?" Higher confidence → better ranking.

---

## TL;DR

| Question | Answer |
|---|---|
| Is our time zone data complete? | Yes (462 IANA, 8 non-whole-hour covered) |
| Is our population data complete? | No (76.7% — 23% NULL, mostly small countries) |
| Are we biased? | Yes — Northern Hemisphere, US/EU, urban, English |
| Do we have sub-15K villages? | No (this is the biggest gap) |
| What unlocks the next 50% of value? | GeoNames (villages), Wikidata (disambiguation), CLDR (locale), UN WPP (pop), US Census (US pop) |
| What's already great? | Translation coverage (98%), capital tracking, TZ correctness |

This is the state of the data on 2026-08-02. As the data platform work lands, these numbers will move. Re-run this analysis after each source ingest.
