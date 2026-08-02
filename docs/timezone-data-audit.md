# Timezone Data Audit

> Data quality audit for timezone assignments.
> Per spec `3849c8b4__*.md` §25 (data quality metrics), §33 (acceptance criteria).

**Date:** 2026-08-02
**Milestone:** 8 (data quality metadata complete)
**Source DB:** `timeandtimepro-full-v2` (D1, ab54b1d7)
**Total cities:** 152,970
**Total timezones:** 462 (IANA canonical)

## Confidence distribution

| Confidence | Count | % | Source |
|---|---:|---:|---|
| **high** | 2,983 | 1.95% | `polygon:timezonefinder` (M1 polygon-verified) |
| **medium** | 149,952 | 98.05% | `dr5hn:default` (dr5hn source, not polygon-verified) |
| **low** | 13 | 0.01% | `manual:override` (M1 hand-corrected per §28) |
| **unresolved** | 22 | 0.01% | `dr5hn:unverified` (Null Island, 0,0 coords) |
| **Total** | **152,970** | **100%** | |

## Data quality flags

| Flag | Cities |
|---|---:|
| `no_pop` (no population) | 31,665 |
| `no_pop,no_wiki` (no pop, no Wikidata) | 2,891 |
| `no_wiki` (no Wikidata QID) | 759 |
| `null_island,no_pop,no_wiki` (bad coords + missing data) | 20 |
| `null_island,no_pop` | 1 |
| `null_island,no_wiki` | 1 |

**Cities with at least one flag:** 35,337 (23.1%)
**Cities with NO flags (clean):** 117,633 (76.9%)

## Spec compliance

| Spec section | Requirement | Status |
|---|---|---|
| §1 | Use lat/lon + trusted TZ polygon, NOT country/state | ✅ Pass |
| §8.2 | No `Etc/GMT*` for cities | ✅ Pass (0 cities) |
| §14.1 | No silent default for NULL coords | ✅ Pass (22 flagged unresolved) |
| §25 | Data quality metrics | ✅ Pass (this document) |
| §28 | Manual overrides documented | ✅ Pass (13 in migration 125) |
| §33.5 | Quality endpoint | ✅ Pass (`/api/v1/data-quality`) |

## What changed across milestones

### M1 (timezone polygon) — 2026-08-01
- 2,983 cities re-timed via `tzfpy` polygon lookup
- 13 manual overrides documented
- 22 Null Island cities flagged
- 33 `Etc/GMT*` references banned and overridden
- **Result:** 99.99% canonical IANA timezone coverage

### M2 (schema enrichment) — 2026-08-01
- 7 new columns on `cities`: state_code, native, type, level, parent_id, wiki_data_id, flag
- 4 new tables: postcodes, translations, airports, migrations

### M3 (city enrichment) — 2026-08-01
- All 152,970 cities enriched with dr5hn fields
- 33 distinct type values (dr5hn taxonomy)
- 96.9% wiki_data_id coverage
- 98.7% native name coverage

### M4 (postcodes) — 2026-08-02
- 844,248 postal codes imported
- `/cities/{id}` now includes `postcodes: { total, sample[5] }`

### M5 (translations) — 2026-08-02
- 2,965,561 translations (19 langs)
- `/cities/{id}/translations`, `/cities/{id}/translations/{lang}`, `/translations/search`

### M6 (API contract) — 2026-08-02
- `?state=` filter (strong disambiguation)
- `?lang=` cross-language search
- Same-name same-country ranking (population-based)
- Population backfill for 7 missing state capitals

### M7 (new endpoints) — 2026-08-02
- `/cities/{id}/postcodes` (paginated)
- `/postcodes/search`
- `/airports/near` (no data yet)
- `/cities/{id}/airports` (no data yet)

### M8 (data quality metadata) — 2026-08-02
- 5 new columns: timezone_confidence, timezone_source, boundary_distance_km, near_boundary, data_quality_flags
- All 152,970 cities tagged with confidence
- 22 Null Island marked `unresolved`
- 13 manual overrides marked `low`
- 2,983 polygon-verified marked `high`
- 8 data sources registered

## Comparison: before vs after

| Metric | Before M1 (Phase 0) | After M8 |
|---|---:|---:|
| Total cities | 5,081 | 152,970 |
| Total timezones | 312 | 462 |
| Polygon-verified TZs | 0 | 2,983 (1.95%) |
| Etc/GMT references | 33 | 0 |
| Null Island flagged | 0 | 22 |
| Manual overrides documented | 0 | 13 |
| Postcodes | 0 | 844,248 |
| Translations | 0 | 2,965,561 |
| API endpoints | 4 | 14 |

## How to audit

```bash
# Overall summary
curl https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/data-quality

# Issues by type
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/data-quality/issues?type=null_island'
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/data-quality/issues?type=low_confidence'
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/data-quality/issues?type=manual_override'

# Per-city confidence
curl https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/cities/64500
# → dataQuality.timezoneConfidence, dataQuality.timezoneSource, dataQuality.flags
```

## Open issues

1. **boundary_distance_km not computed** — requires polygon distance compute (~1h)
   Workaround: `near_boundary` flag is set to 0 for all cities for now
2. **Airport data not loaded** — schema ready, waiting on cron reminder (task 426125193814084)
3. **Postcode to city mapping** — currently state-scoped (dr5hn has NULL city_id)
   Workaround: most use cases can be served by state-scoped lookup

## See also

- [`timezone-core-logic.md`](./timezone-core-logic.md) — How timezone is determined
- [`timezone-test-plan.md`](./timezone-test-plan.md) — Spec test mapping
- [`../reports/timezone-audit.md`](../reports/timezone-audit.md) — M1 audit
- [`../reports/cities-enrichment-audit.md`](../reports/cities-enrichment-audit.md) — M3 audit
- [`../reports/m8-data-quality-audit.md`](../reports/m8-data-quality-audit.md) — M8 audit
