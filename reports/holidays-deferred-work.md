# Holidays Feature — Deferred Work & Open Questions

**Date**: 2026-08-03
**Status**: MVP scope agreed. This doc captures what we're NOT building now and why.

---

## MVP scope (10 endpoints, ~10 days, dev only)

1. `GET /api/v1/filters` — filter catalog
2. `GET /api/v1/countries/{cca2}/filters` — per-country filter list with counts (**the variance endpoint**)
3. `GET /api/v1/holidays` — main list with filters + date range
4. `GET /api/v1/holidays/{id}` — single occurrence detail
5. `GET /api/v1/countries/{cca2}/holidays` — country-scoped shortcut
6. `GET /api/v1/holidays/today` — today's holidays (widget)
7. `GET /api/v1/holidays/upcoming` — next N days (widget)
8. `GET /api/v1/long-weekends` — SEO long-weekend finder
9. `GET /api/v1/calendars/holidays.ics` — ICS export
10. `POST /api/v1/feedback` — submit correction

Plus:
- NL via OpenHolidays (free, public domain)
- US via OPM (federal official) + Nager.Date (state/local fallback)
- English-only labels (CLDR localization is a follow-up)
- The 10 atomic dimensions in the schema, but only 4-5 are populated for MVP

---

## Deferred endpoints (10) — ship after MVP validates

| # | Path | Why deferred | When |
|---|---|---|---|
| 11 | `GET /api/v1/holidays/this-month` | Easy add but niche use case (calendar view backends) | post-MVP |
| 12 | `GET /api/v1/countries/{cca2}/subdivisions/{code}/holidays` | Needs full subdivision data; not in MVP scope | post-MVP, when US state adapters land |
| 13 | `GET /api/v1/concepts/{id}` | Concept layer is built but browsing API is post-MVP | post-MVP, when consumers ask "show me all Christmases" |
| 14 | `GET /api/v1/concepts/{id}/occurrences` | Same as #13 | post-MVP |
| 15 | `POST /api/v1/business-days` | Needs working-day override logic (China-style swaps) — not in MVP | post-MVP, after China adapter |
| 16 | `GET /api/v1/calendars/holidays.csv` | Easy add, low priority | post-MVP |
| 17 | `GET /api/v1/changes` | Needs revision tracking infra (Phase 1 includes the table) | post-MVP, when changes are real |
| 18 | `GET /api/v1/sources` | Source health dashboard — admin needs this first | Phase 6 (admin) |
| 19 | `GET /api/v1/sources/{key}` | Same as #18 | Phase 6 |
| 20 | `POST /api/v1/feedback/{id}/vote` | Voting on community reports — needs community to exist | post-MVP, when feedback volume justifies it |

---

## Deferred phases (from spec)

### Phase 4 — Provider accelerators (post-MVP)

Add OpenHolidays, Nager.Date, and licensed Timeanddate as **acceleration sources** (not canonical truth). All assertions flow through the same reconciliation pipeline.

- OpenHolidays: ~20 EU countries, free, Open Database License. Add for cross-validation once NL/US canonical sources are stable.
- Nager.Date: ~110 countries, MIT-style, used as fallback for countries without official sources.
- Timeanddate: only with signed license. **Spec forbids scraping.** If we sign, expose as `timeanddate_api` source with `authority_tier = C` (licensed specialist) and `license_code` pointing to the agreement.

### Phase 6 — Admin/review (post-MVP, requires user)

Build the admin panel for:
- Source health dashboard
- Conflict queue (when 2 sources disagree)
- Tentative queue (lunar/moon-sighting events awaiting confirmation)
- Diff approval (next-year holidays being published)
- Feedback triage
- Revision history viewer

**Why deferred**: requires internal user (you or a team) actively using it. Building without a user is over-engineering. The schema supports it; we just don't expose it yet.

### Phase 7 — Worldwide onboarding (post-MVP, customer-driven)

Add country adapters in waves based on demand:
- **Wave 1 (post-MVP)**: UK, AU, NZ, CA, IN, DE — biggest markets
- **Wave 2 (Phase 4)**: SG, UAE, JP, KR — Asia-Pacific + Middle East
- **Wave 3**: BR, MX, ZA, EG, NG — emerging markets
- **Wave 4**: remaining 200+ — only if we have customer pull per country

Each country needs: manifest, fetcher, parser, fixture, reconciliation tests, golden output. Per spec's "country is production-ready only when..." checklist.

---

## Deferred advancements (from the spec + my suggestions)

These are good ideas that don't fit MVP. Capturing for the backlog:

### From the spec

1. **Quality score auto-publish thresholds** (spec section 23)
   - National public holiday: 90+ auto-publish, 75-89 human review, <75 reject
   - Subdivision/local: 85+ / 70-84 / <70
   - Important observance: 80+ / 65-79 / <65
   - **MVP skip**: we don't have enough sources to calculate a real score. Add when we have 3+ sources per country.

2. **9 quality gates** (spec section 24)
   - Gate 0: licensing, Gate 1: source registration, ..., Gate 8: release
   - **MVP skip**: implement Gate 1+2+7 (registration, fetch integrity, API contract). Skip Gate 3-6 (parser integrity, semantic integrity, reconciliation, country completeness) until Phase 4.

3. **Golden-country test matrix** (spec section 25)
   - 13 countries: US, NL, UK, AU, NZ, CN, IN, UAE, DE, NO, SE, PT, CA, SG
   - **MVP ships**: NL + US. Add 1 per month after.

4. **Conflict resolution UI** (admin tool)
   - When Nager.Date says 2026-12-25 and official says 2026-12-26, expose this
   - **Deferred to Phase 6 (admin)**

5. **Source health monitoring dashboards** (spec section 27)
   - Source freshness, ready/degraded countries, parser failures, etc.
   - **Deferred to Phase 6**

6. **Webhook / changes feed for cache invalidation**
   - **Deferred**: when external consumers ask for it

7. **CDN-friendly ICS feed with ETag**
   - **Partially in MVP**: ICS export exists, ETag not. Add ETag when traffic justifies.

8. **RFC 5545 ICS validation** (AC-A04)
   - **MVP**: manual verification with ical.js. Add automated test in Phase 4.

9. **Per-country readiness score**
   - 0-100 score based on coverage, freshness, source tier, etc.
   - **Deferred to Phase 6 (admin)**

10. **Timeanddate license-watch bot**
    - Quarterly check of Timeanddate API terms + pricing
    - **Deferred**: we have no active license. Add when we sign one.

### My additions (already discussed)

11. **Multi-language holiday names** (reuse CLDR)
    - **MVP skip**: English only. We have 19-language CLDR infra for country names; same pattern applies to holidays when we want it.

12. **IANA clock changes as derived source** (not ingested)
    - **MVP ships**: derived from existing IANA data. We already have the timezone data.

13. **Seasons as computed** (not ingested)
    - **MVP ships**: equinox/solstice computed in code. Same pattern as climate data.

14. **Tentative status with reason** (spec section 21)
    - Lunar events expose why they're tentative
    - **MVP partial**: tentative flag exists, reason field optional. Full implementation when we add Islamic/Jewish events.

15. **Working-day override support** (China-style swaps)
    - **MVP skip**: AC-D04 not testable without a China adapter. Add with Phase 7 Wave 2.

16. **Cross-year substitute date handling**
    - **MVP ships**: dates are dates, queries are inclusive, year wraps work. Full edge case testing in Phase 4.

17. **Partial-day holidays**
    - **MVP skip**: most public holidays are full-day. Add when needed for e.g.Christmas Eve half-day in some countries.

18. **Bridge holiday detection**
    - When Thu + Fri are both holidays, Sat-Sun-Mon = 4-day weekend
    - **MVP ships** as part of long-weekends endpoint

---

## Open questions (for later)

These need user input before we touch them:

1. **Timeanddate license**: Do we have one, want one, or stay clear? Affects Phase 4 source mix.
2. **Internal admin UI**: Build in-app or use a 3rd party like Retool? Affects Phase 6 scope.
3. **Feedback moderation**: Who reviews? Affects feedback endpoint SLA implementation.
4. **Country prioritization**: Which countries go in Wave 1, 2, 3? Driven by customer data, not our guess.
5. **Monetization**: Are holidays free, behind a paywall, or usage-metered? Affects API key/auth strategy.
6. **Translation strategy**: Crowdsource (Wikidata-style), commission (CLDR), or auto-translate (DeepL)? Affects Phase 4+ cost.
7. **Cache TTLs**: How stale can a "today" response be? 1 min? 1 hour? Affects Cloudflare cache rules.
8. **License compatibility**: OpenHolidays (ODbL) + Nager.Date (MIT) + Wikidata (CC0) — all compatible? Need legal review.
9. **PII in feedback**: GDPR for the feedback endpoint? Affects retention policy.
10. **Source attribution**: Show "data from OpenHolidays" in UI? Affects API response shape (already in spec but needs product decision).

---

## What we're building right now (MVP)

```
Phase 0: Schema + source_registry + holiday_filter catalog
Phase 1: Core DB (concepts, occurrences, source_assertions, revisions)
Phase 2: UN observances + IANA clock changes (derived) + seasons (computed)
Phase 3: NL + US adapters
Phase 5: 10 MVP endpoints
+ Tests
+ Report
```

ETA: ~10 days, dev only. Single PR, merged to develop, no production deploy.

When MVP is stable, the next decision is: which Phase 7 country in Wave 1? My default: UK (biggest market, well-documented sources, similar shape to US).

---

## Cross-references

- Full spec: `/workspace/attachments/525518f4__fec29dac-c40b-411b-a52c-815fe7d01613.md`
- This session's API design: previous turn
- Existing data we reuse: 250 countries, 47,549 admin-2, 462 IANA timezones, 170K cities, 19-lang CLDR
