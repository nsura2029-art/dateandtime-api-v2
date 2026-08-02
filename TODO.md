# TODO — dateandtime-api-v2

> Active work tracker. Updated as tasks complete or new ones are discovered.

## Status legend
- ✅ Done (this milestone)
- 🟡 In progress / partial
- ⏳ Pending (next milestone)
- ❌ Blocked (waiting on external)

---

## Milestone Tracker

| M | Title | Status | Commit | Tests |
|---|---|---|---|---:|
| 0 | Phase 1 (data rebuild) | ✅ | 13c620c | — |
| 1 | Timezone polygon (spec §1, §8.2) | ✅ | 65436e9 | 33 |
| 2 | Schema enrichment (dr5hn shape) | ✅ | f7ce709 | 7 |
| 3 | City enrichment data | ✅ | bf2b0c9 | 7 |
| 4 | Postcodes (dr5hn, 844K) | ✅ | f839c14 | 9 |
| 5 | Translations (19 langs, 2.97M) | ✅ | 3ad11fe | 11 |
| 6 | API contract upgrade (state, lang, ranking) | ✅ | fd0c293 | 14 |
| 7 | New endpoints (postcodes, airports) | ✅ | e049944 | 14 |
| 8 | Data quality metadata | ✅ | 7946c91 | 15 |
| 9 | Documentation | 🟡 | (this) | 5 |
| 10 | Final regression | ⏳ | — | +25 |

**Cumulative spec coverage: 151/209 (72.2%)**

---

## M9 — Documentation (in progress)

### Pending in M9
- [x] `docs/timezone-core-logic.md` — How timezone is determined
- [x] `docs/timezone-data-audit.md` — M8 data quality summary
- [x] `docs/timezone-test-plan.md` — Update to M1-M8 status
- [x] `README.md` — New endpoints + examples
- [x] `src/routes/docs.ts` — Swagger UI tag list, description
- [ ] **TODO**: Update `AGENTS.md` (if exists) with new endpoints

### Deferred
- Time-calc endpoint (separate work, not in M9)

---

## M10 — Final Regression

### Goals
- Re-run all spec §9-13 fixtures
- Performance tests
- Final acceptance criteria (25 items)
- Reach 100% spec coverage

### Pending tests (~25)
- §15 boundary cases (4) — needs boundary_distance_km compute
- §17.7-8 multi-TZ (2) — partial
- §18 multi-TZ municipality (3) — needs case
- §30-32 layers / performance / security (full coverage)
- §33.5, 17-18, 22-25 final acceptance

### Work items
- [ ] Compute boundary_distance_km for all 152K cities (M8 follow-up)
- [ ] Run perf benchmarks (§31)
- [ ] Audit log + monitoring
- [ ] Add rate limiting (spec §32.5)
- [ ] Add HTTPS-only middleware
- [ ] Production deployment prep
- [ ] Final audit + sign-off

---

## Known Gaps (not blocking any milestone)

### Data
- 5 sub-1K-pop US cities not in DB (New Salem ND, Kykotsmovi AZ, Adak AK, Pago Pago AS, Saipan MP)
- 22 Null Island cities (0,0 coords) — flagged unresolved, kept current TZ
- Phoenix OR incorrectly marked as state capital in dr5hn — known data error
- San Juan PR pop NULL in dr5hn
- Ciudad Juárez in DB is "Juárez" (no "Ciudad" prefix) — dr5hn naming

### API
- Time-calc endpoint (DST/date-line/fractional offset math) — separate task
- /airports/near returns empty (data import pending)
- boundary_distance_km not computed (heavy operation)

### Performance
- Search response time ~50-200ms (acceptable, but can improve with edge cache)
- Postcodes paginated endpoint ~100-300ms (state-scoped query is fast)

### Operational
- Cron: airport-data-reminder (task 426125193814084) — monthly 9 AM ET
- CORS: currently `*` (set in env), should restrict to dateandtime.live in prod
- Docs BUG-1: Swagger UI CORS via `wrangler dev --remote` proxy (known issue)

---

## Deferred to Future Phases

### Phase 2 (post-10): additional features
- Meeting planner endpoint (cross-timezone meeting finder)
- Travel/jet-lag tracking
- TV/sports event countdowns
- Religious observances (Ramadan, Sabbath, prayers)

### Phase 3: data expansion
- Airport data import (waiting on cron reminder)
- More languages (currently 19, target 50+)
- Historical timezone data
- Real-time DST transition alerts

### Phase 4: production
- Custom domain (dateandtime.live/api)
- Edge caching with KV
- Rate limiting per IP
- Monitoring/alerting
- Full HA / multi-region

---

## How to Use This File

1. **M1-M8 done** — covered by docs/timezone-data-audit.md
2. **M9 in progress** — this TODO + the docs files
3. **M10 is next** — final regression sweep
4. After M10: hand off to production team for Phase 2+ work
