# Wikidata Source (M11.2 family)

> Sources for the 148,331 cities with Wikidata integration.

## Wikidata SPARQL

- **Source:** https://query.wikidata.org/sparql
- **Tier:** D
- **License:** CC0
- **Coverage:** 148,331 cities matched via Q-id
- **What we extract across the M11.2 family:**

| Milestone | What we got | Count |
|---|---|---:|
| M11.2 | Wikidata Q-ids + Wikipedia URLs | 148,331 |
| M11.2.5 | Wikidata alt labels (for search) | 148K+ (226K extra) |
| M11.2.6 | Wikidata short descriptions (e.g., "capital of Japan") | 148,331 (100%) |
| M11.2.7 | Backfill any missing Q-ids | +5K |
| M11.2.8 | Wikidata P-codes (P31, P17, P131, P421) for top 5K cities | 5,000 |

## M11.2 — Q-ids

Match `cities.wikidata_qid = ?` field added in M11.2.

```sparql
SELECT ?city ?cityLabel WHERE {
  ?city wdt:P31/wdt:P279* wd:Q515 .  # instance of city
  ?city wdt:P17 ?country .           # has country
  ?city wdt:P625 ?coord .            # has coordinates
  SERVICE wikibase:label { bd:serviceParam wikibase:language "en" . }
}
LIMIT 100
```

## M11.2.5 — alt labels

Wikidata alt labels improve search ranking for queries like "Tokyo Tower" that
don't match the canonical city name.

## M11.2.6 — short descriptions

Stored in `wikidata_descriptions` table. Used in `/cities/{id}.description` field.

## M11.2.7 — backfill

Closed the gap: 100% of Q-id cities now have descriptions.

## M11.2.8 — P-codes (top 5K cities)

For the top 5K cities by population, we extracted:

| P-code | Property | Coverage |
|---|---|---|
| P31 | instance of | 100% |
| P17 | country | 100% |
| P131 | admin entity | 99.9% |
| P421 | timezone | 42% (sparse) |

## Why top 5K only?

- Population > 250K covers all world capitals + all G20 cities
- 100K cities is post-MVP
- 5K was small enough for a single SPARQL batch run (500 Q-ids per POST × 10 batches)

## API additions

- `/cities/{id}.wikidata` block: Q-id, P-codes, alt labels, description
- 4 new fields: `instanceOf`, `countryQid`, `adminQid`, `timezoneQid`

## Gotchas

- **P625 (coordinates)** returns "Point(long lat)" WKT format — parse with regex
- **qid is not UNIQUE** — use `INSERT OR REPLACE` (qid is the PK but multiple cities
  can share a qid in our data because of the merge)
- **BATCH_ROWS=11** for 9-col inserts (11 × 9 = 99 vars, under 100 limit)

## Deferred (post-MVP)

- P-codes for all 148K cities (not just top 5K)
- P1566 (GeoNames ID) for cross-reference
- P6 (head of government) for political data
- Multilingual descriptions (currently English only)

## See also

- `reports/m11.2-wikidata-result.md`
- `reports/m11.2.5-wikidata-altlabels-result.md`
- `reports/m11.2.6-wikidata-desc-result.md`
- `reports/m11.2.7-wikidata-backfill-result.md`
- `reports/m11.2.8-and-m11.8-result.md`
- `tests/m11.2-wikidata.test.ts`
- `tests/m11.2.5-wikidata-altlabels.test.ts`
- `tests/m11.2.6-wikidata-desc.test.ts`
- `tests/m11.2.8-wikidata-pcodes.test.ts`
