# User Education Content Plan

**Location:** UI repo (dateandtime-live, separate) — NOT this API repo
**Status:** Phase 5 of `docs/PLAN-phased-implementation.md`
**Goal:** 10-15 SEO-optimized articles driving organic traffic to the API

---

## Why content?

The API alone is infrastructure. The UI brings users. The articles bring SEO traffic.

**Math:**
- 10 articles × 5K monthly searches = 50K monthly impressions
- 2% CTR = 1,000 monthly visitors
- 10% convert to API user = 100 monthly new API users

That's a meaningful funnel at zero ongoing cost.

---

## Article topics (15 total, prioritized)

### Tier 1: High search volume (10K+ searches/mo)

| # | Title | Target keyword | Search vol (est.) | Words |
|---|---|---|---|---|
| 1 | "What is a time zone? A complete guide" | what is a time zone | 50K/mo | 2,500 |
| 2 | "How many time zones are there in the world?" | how many time zones | 30K/mo | 1,500 |
| 3 | "UTC vs GMT: what's the difference?" | utc vs gmt | 25K/mo | 2,000 |
| 4 | "Daylight Saving Time 2026: when does it start?" | dst 2026 | 100K/mo | 2,000 |
| 5 | "Time zones by country: the complete list" | time zones by country | 40K/mo | 3,000 |
| 6 | "What is Unix time / epoch time?" | unix time | 35K/mo | 2,000 |
| 7 | "Time zone abbreviations: A to Z" | time zone abbreviations | 18K/mo | 2,500 |
| 8 | "Countries that don't observe DST" | countries without dst | 22K/mo | 2,000 |

### Tier 2: Medium search volume (1-10K/mo)

| # | Title | Target keyword | Search vol (est.) | Words |
|---|---|---|---|---|
| 9 | "The International Date Line: where is it?" | international date line | 15K/mo | 1,500 |
| 10 | "Half-hour and quarter-hour time zones" | half hour time zones | 5K/mo | 1,500 |
| 11 | "How to schedule meetings across time zones" | schedule meetings across time zones | 8K/mo | 2,000 |
| 12 | "Jet lag: how to recover faster" | jet lag recovery | 20K/mo | 2,000 |
| 13 | "The weirdest time zones in the world" | weird time zones | 12K/mo | 1,500 |
| 14 | "Why do we have time zones?" (history) | why time zones | 10K/mo | 2,500 |

### Tier 3: Long-tail (future)

| # | Title | Target keyword | Search vol (est.) | Words |
|---|---|---|---|---|
| 15 | "Current time in [City]" × 250 cities | current time in [city] | varies | 500/city template |

(15 = the meta-article; 250+ city pages auto-generated from API)

---

## Article format

Each article should have:

1. **Title** (50-60 chars) — primary keyword + benefit
2. **Meta description** (150-160 chars) — includes secondary keywords
3. **H1** — main title (often same as title)
4. **Intro** (100-200 words) — answer the search query directly (Google rewards direct answers)
5. **Table of contents** — for long articles (>1500 words)
6. **Body** with H2s/H3s — each section ~200-400 words
7. **Live data embeds** — at least 1-2 per article (current time, comparison table, etc.)
8. **FAQ** — 3-5 common questions, schema.org FAQ markup
9. **CTA** — link to relevant tool (e.g., "Try our meeting planner")
10. **Schema.org markup** — `Article` + `FAQPage` + `BreadcrumbList`
11. **Internal links** — to other articles + to API
12. **External links** — to authoritative sources (Wikipedia, NIST, IANA)

---

## Live data embeds (powered by API)

Every article should embed 1-2 live data widgets that pull from the API.

**Example 1** (in "What is a time zone?"):
- World clock showing current time in 6 major cities
- Pulls from `GET /api/v1/popular/cities` (returns New York, London, Tokyo, Sydney, Mumbai, São Paulo)

**Example 2** (in "DST 2026"):
- Countdown to next DST transition
- Pulls from `GET /api/v1/dst/upcoming`

**Example 3** (in "Time zones by country"):
- Search box → `GET /api/v1/countries/:cca2`
- Shows: country flag, capital, timezones, current local time

**Example 4** (in "Half-hour time zones"):
- Table of 5+ half-hour zones with their offsets
- Pulls from `GET /api/v1/timezones?offset_minutes=30`

---

## Technical implementation (UI repo)

### Static site (Next.js / Astro)

```
dateandtime-live/
  content/
    learn/
      what-is-a-time-zone.mdx
      how-many-time-zones.mdx
      utc-vs-gmt.mdx
      dst-2026.mdx
      ...
  app/
    learn/
      [...slug]/
        page.tsx     # MDX render
  components/
    LiveTime.tsx     # fetches from API
    TimezoneTable.tsx
    WorldClock.tsx
  lib/
    api.ts           # client for the API
```

### Build-time vs runtime

- **Build time:** Most content (the article body) is static MDX
- **Runtime:** Live data widgets (current time, world clock) fetch from API on each page load (cached for 1 min)
- **ISR (Incremental Static Regeneration):** Articles rebuild every 24h to pick up data changes

### Sitemap + hreflang

- `sitemap.xml` with all article URLs
- `hreflang` tags for each article in 5 languages (en, es, fr, de, ja) — Phase 6
- Submit to Google Search Console

---

## Content production workflow

### For 10 articles (initial batch)

1. **Day 1:** SEO research + outline 10 articles (2 hours)
2. **Day 2-3:** Write 5 articles (1.5 days, 1,500-2,500 words each)
3. **Day 4:** Write 5 more articles (1 day)
4. **Day 5:** Edit + publish (1 day)
5. **Day 6-7:** Submit to Search Console + initial ranking check

### Total: 7 days for 10 articles

### For 250 city pages (auto-generated)

1. **Build the template** (1 day) — `app/cities/[slug]/page.tsx` with city data from API
2. **Configure routing** — use the 50 US states + DC only (per MVP coming-soon logic)
3. **Test + deploy** (1 day)
4. Total: 2 days for 51 city pages

### Ongoing (1 article per week after launch)

- Identify new keyword opportunities
- Write 1 article/week
- Update existing articles based on Search Console data

---

## SEO target

**Year 1 goal:** Rank in top 10 for 5+ tier-1 keywords

**Year 1 metrics:**
- 50 articles published
- 50K monthly organic impressions
- 1,000 monthly organic clicks
- Domain rating (DR) > 30

---

## Reference articles (inspiration)

The user pointed to these as examples:
- https://www.remitly.com/blog/lifestyle-culture/time-zones/
- https://www.timeanddate.com/time/current-number-time-zones.html
- https://www.timeanddate.com/time/time-zones.html

**Key takeaways:**
- Direct answers at the top
- Visual aids (maps, world clock)
- Comprehensive tables
- Cross-linked related content
- Updated yearly (DST changes, etc.)

---

## What this is NOT

- **Not a blog** — these are reference articles (like Wikipedia entries), not opinions
- **Not news** — evergreen content, not breaking news
- **Not localized** — start with English only (Phase 6 adds i18n)
- **Not paid** — no sponsored content, no affiliate links
- **Not AI-generated slop** — human-edited for quality

---

## Open questions for user

1. **Tone** — formal/encyclopedic (Wikipedia style) or friendly/conversational (Remitly style)?
2. **Author** — write yourself, hire writer, or AI-assisted?
3. **Languages** — start with English only, or add 1-2 others in parallel?
4. **Cadence** — all 10 at once, or 1/week over 10 weeks?
5. **Live data widgets** — every article, or only on relevant ones?

My recommendation:
1. **Friendly/conversational** with Wikipedia-style structure
2. **AI-assisted** with human review (faster + cheaper)
3. **English only** for MVP
4. **All 10 at once** to seed the site quickly
5. **1-2 per article** where relevant (don't force it)

---

## File location

- **Content files** (MDX): in the UI repo (dateandtime-live)
- **This plan** (markdown): in the API repo (dateandtime-api-v2) → `docs/PLAN-user-education-content.md`

When the UI repo is created/spun up, copy this plan there.
