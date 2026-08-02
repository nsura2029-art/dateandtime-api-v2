# Vinjanampadu — Why it returns no results

**Date:** 2026-08-02
**Query:** `vinjanampadu` (user's home village)
**Result:** `{"query":"vinjanampadu","results":[],"total":0,"tookMs":247}`

## TL;DR

Your village **isn't in the database**. The dr5hn cities15000 dataset (our source) only has 168 cities in all of Andhra Pradesh and ~1,500 sub-1K-population places in India total. Vinjanampadu is a small village that didn't make the threshold. We have the nearest city (Guntur, ~7 km away), but the village itself is below the dataset's cut.

## The Vinjanampadu(s)

Web search shows there are actually **3 distinct Vinjanampadu villages** in Andhra Pradesh — same name, different mandals:

| Name | Mandal | District | Lat,Lon | Source |
|---|---|---|---|---|
| Vinjanampadu | Vatticherukuru | Guntur | 16.23888°N, 80.426669°E | Wikipedia, onefivenine |
| Vinjanampadu | Yeddanapudi | Bapatla | 16.03167°N, 80.19278°E | Wikipedia |
| Vinjanampadu | Yeddana Pudi | Prakasam | (n/a) | mapsofindia |

The one closest to Guntur is at **16.23888°N, 80.426669°E**, in Vatticherukuru mandal, ~7 km south of Guntur city. Pin code 522017.

## What we have in the DB near those coordinates

```
c.id   name          population  lat,lon                dist_sq (vs Vinjanampadu)
132028 Guntur        13,183      16.29974, 80.45729     0.00464
133158 Narasaraopet  117,489     16.23488, 80.04927     far
131556 Chilakalurupet 101,398    16.08987, 80.16705     far
```

The nearest city in our DB is **Guntur at 16.29974, 80.45729** (0.05° away from the village, ~5–6 km). Population just 13,183 in our record — but actual Guntur city has ~750K people. dr5hn gives us a small-town entry, not the metro record.

## Why isn't it in the DB?

The dr5hn `cities15000.txt` source (which we use) only contains **cities with population ≥ 15,000** by default. With 168 Andhra Pradesh cities and 4,198 Indian cities total, that's the entire IN coverage. Sub-15K villages aren't in the file.

For context, our 152,970 city count comes from this filter — the upstream dr5hn cities500 (full 200K+) and cities1000 (mid-tier) would be needed to reach villages.

Indian villages at our scope:
- 168 / 29 States+UTs in AP (~5.8 cities/state avg)
- 4,198 total for IN
- Compare: US 19,592, DE 16,773, GB 7,123, CN 4,632

The dataset is biased toward Western urban coverage.

## What the timezone would be

Whatever it is, we already know the answer for the village regardless of whether it's in our DB:

```
Country: India
State: Andhra Pradesh (in our DB)
Timezone: Asia/Kolkata
UTC offset: +5:30 (no DST since 1945)
```

Confirmed: all 168 AP cities in our DB use `Asia/Kolkata` with `utc_offset_minutes=330`. India stopped observing DST in 1945 and hasn't used it since. Vinjanampadu's timezone is **IST, UTC+5:30, no DST ever**.

## Options to fix

### Option A: Add the village manually (one-off)

Insert one row into `cities`:
```sql
INSERT INTO cities (id, name, ascii_name, latitude, longitude, timezone, country_id, state_id, tier, source_id, timezone_confidence, timezone_source, data_quality_flags)
VALUES (163965, 'Vinjanampadu', 'Vinjanampadu', 16.23888, 80.426669, 'Asia/Kolkata', 101, <andhra_pradesh_id>, 'tier4', 'manual:villages:vinjanampadu', 'high', 'manual:timezone', 'manual,no_pop,no_wiki_pop');
```

Cost: 5 min. Doesn't scale.

### Option B: Add a "villages" dataset for India (or all countries)

Find a comprehensive village-level source:
- **GeoNames** has `cities500` (pop ≥ 500) and `cities1000` files — would add ~50K Indian villages
- **OpenStreetMap** has all places globally (~5M) but needs proper timezone mapping
- **Indian Census 2011** has 640K villages, all in India only, with population but no coordinates directly (you need linked GPS)
- **data.gov.in** has shapefile of Indian village boundaries
- **OpenWeatherMap city list** ~200K
- **geonames.org** full download: `cities500.txt` has 200K+, `cities1000.txt` has 150K, `cities5000.txt` has 50K, `cities15000.txt` has 25K

The dr5hn source specifically uses `cities15000`. To get villages, we'd switch to `cities5000` (or even `cities1000`) for at least the Indian state of AP.

Cost: 1-2 days for the migration + a few hours for the seed.

### Option C: Fuzzy match / nearest-city fallback

When a search returns 0 results, return the nearest city instead with a "did you mean" or "nearest match" field. Doesn't add the village but does help users who mistype or who search a place below our threshold.

Cost: 2-3 hours (search/route change + test).

### Option D: Accept the gap

For a global city/timezone API, 152K cities covering all pop ≥ 15K is reasonable. The user's specific case (a sub-15K village) is below scope. Document the gap in the API.

Cost: 0.

## Recommendation

**Option C** is the cheapest improvement: in `/cities/search`, when 0 results, also return the nearest 3 cities by lat/lon within 50 km of the query centroid (or a fuzzy prefix match). The user's `vinjanampadu` query would get back Guntur, Narasaraopet, etc., with a note "no exact match — showing nearest cities within 50 km of Vinjanampadu, India."

This also helps with:
- Misspellings (a user typing `Tokio` would get Tokyo)
- Tiny villages (the original use case)
- Sub-localities (boroughs, suburbs, neighborhoods)

**Option B** is the long-term play but is a multi-day data engineering task. Worth doing if village-level is a real product need (e.g. weather API, last-mile delivery).

## Open question for you

Which one do you want?

1. **Quick win (Option C)**: nearest-city fallback in /search → 2-3 hours
2. **Manual fix (Option A)**: insert Vinjanampadu specifically → 5 min
3. **Real fix (Option B)**: import GeoNames cities5000 / villages for India → 1-2 days
4. **None (Option D)**: document the threshold → 0
