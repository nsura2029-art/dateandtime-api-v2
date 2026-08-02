# M6: API Contract Upgrade Audit

**Date:** 2026-08-01

## New Search Features

| Feature | Status |
|---|---|
| `?state=XX` filter (strong boost) | ✅ Pass |
| `?lang=xx` cross-language search | ✅ Pass |
| URL encoding (UTF-8) | ✅ Pass |
| Same-name same-country disambiguation | ✅ Pass |
| Validation (lat/lon range) | ✅ Pass |
| Search ranking for tied cities | ✅ Pass |

## Ranking changes

```
?state=XX:     +1000 (very strong: user explicitly asked for this state)
country match: +300
same-name same-country (relative pop): up to +600
country capital: +500
state capital: +50 (down from 200)
tier1: +200, tier2: +80
population: log10(pop+1) × 100
exact match: +1000, prefix: +500
```

## Data fix (migration 132)

- Backfilled population for Monterrey NLE (1.14M), Perth WA (2.2M), 
  Guadalajara (1.7M), Chihuahua (922K), Hobart (337K), Darwin (264K), Canberra (148K)
- Re-tiered affected cities
- Fixed Phoenix OR is_state_capital data error (it's not the Oregon capital)

## Ranking tests (14 pass)

| Test | Result |
|---|---|
| M6.1 Phoenix + state=AZ | ✅ Pass |
| M6.2 Monterrey + state=NLE | ✅ Pass |
| M6.2b Monterrey (no state, NLE wins via backfilled pop) | ✅ Pass |
| M6.3 Perth + state=WA | ✅ Pass |
| M6.3b Perth (no state, WA wins via backfilled pop) | ✅ Pass |
| M6.4 state=AZ adds +1000 boost | ✅ Pass |
| M6.5 日本語 search for 東京 | ✅ Pass |
| M6.6 中文 search for 北京 | ✅ Pass |
| M6.7 العربية search for باريس | ✅ Pass |
| M6.8 Cancún UTF-8 | ✅ Pass |
| M6.9 Ürümqi UTF-8 | ✅ Pass |
| M6.10 Mérida UTF-8 | ✅ Pass |
| M6.11 invalid lat (91) → 400 | ✅ Pass |
| M6.12 invalid lon (-181) → 400 | ✅ Pass |

## Total test count: 145/146 (1 pre-existing env.test.ts)

## Spec coverage progress

| Section | Before M6 | After M6 | New passing |
|---|---:|---:|---:|
| §10.2 Mexico | 6 pass | 9 pass | +3 (Monterrey, Matamoros, Chihuahua) |
| §10.3 Australia | 4 pass | 6 pass | +2 (Perth, Hobart) |
| §14.2 Lat/lon validation | 0 | 2 | +2 |
| §17 Same-name disambiguation | 0 | 3 | +3 (Phoenix, Monterrey, Perth) |
| §32 Unicode URL encoding | 0 | 3 | +3 (Cancún, Ürümqi, Mérida) |

**Cumulative: 130/209 spec tests (62.2%)**
