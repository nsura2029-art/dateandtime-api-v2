# dateandtime-api-v2

> dateandtime.live API v2 — Hono + Cloudflare D1 + Zod, deployed on Cloudflare Workers.

The canonical API for dateandtime.live. Replaces the legacy `datetime-api` Worker with a modular, type-safe, testable codebase.

## Stack

- **Runtime:** Cloudflare Workers (V8 isolate)
- **Framework:** Hono 4.6
- **Database:** Cloudflare D1 (SQLite at edge) — `timeandtimepro-full` (33,945 cities, 242 countries, 408 timezones)
- **Validation:** Zod 3.23
- **Tests:** Vitest 2.1
- **Local dev:** Docker + wrangler dev (D1 persisted in volume)
- **CI:** GitHub Actions (lint, typecheck, test)

## Quick start

```bash
# 1. Install deps
npm install

# 2. Run locally (no Docker)
npm run dev          # → http://localhost:8787

# 3. Or run in Docker
docker compose -f docker/docker-compose.yml up

# 4. Run tests
npm test

# 5. Smoke test all endpoints
npm run smoke
```

## Endpoints

| Method | Path | Description |
|---|---|---|
| GET | `/` | API root, version, endpoint manifest |
| GET | `/api/v1/health` | DB stats, latency, version |
| GET | `/api/v1/cities` | List cities (paginated, filter by country/tz) |
| GET | `/api/v1/cities/:id` | City by numeric ID |
| GET | `/api/v1/cities/search?q=` | LIKE search |
| GET | `/api/v1/cities/near?lat=&lon=&r=` | Haversine proximity |
| GET | `/api/v1/cities/:id/climate` | Monthly climate |
| GET | `/api/v1/cities/:id/aliases` | Alternate names + historical |
| GET | `/api/v1/countries` | List countries |
| GET | `/api/v1/countries/:cca2` | Country by cca2 |
| GET | `/api/v1/countries/:cca2/cities` | Cities in a country |
| GET | `/api/v1/countries/:cca2/working-hours` | Business hours |
| GET | `/api/v1/timezones` | IANA timezones |
| GET | `/api/v1/timezones/:id` | Timezone by IANA name |
| GET | `/api/v1/time/now?tz=` | Current time in a tz |
| GET | `/api/v1/time/sun?lat=&lon=&date=` | Sunrise/sunset |
| GET | `/api/v1/holidays?country=&year=` | Public holidays |
| GET | `/api/v1/holidays/today?country=` | Today's holidays |
| GET | `/api/v1/holidays/upcoming?country=&days=` | Upcoming holidays |
| GET | `/api/v1/onthisday?month=&day=` | Historical events |
| GET | `/api/v1/dst/upcoming?tz=` | DST transitions |
| GET | `/api/v1/popular/cities` | Curated popular cities |
| GET | `/api/v1/popular/defaults` | Default 5-city list |
| GET | `/api/v2/search?q=` | FTS5 search |
| GET | `/api/v1/feedback` | List feedback |
| GET | `/api/v1/feedback/top` | Top-voted |
| POST | `/api/v1/feedback` | Create feedback |
| POST | `/api/v1/feedback/:id/vote` | Upvote |
| GET | `/api/v1/admin/data-quality` | Quality checks |

## Project structure

```
dateandtime-api-v2/
├── src/
│   ├── index.ts              # thin router (~80 lines)
│   ├── config/               # env validation, CORS
│   ├── routes/               # ONE file per resource
│   ├── middleware/           # logger, error-handler, rate-limit
│   ├── lib/                  # db, cache, validation, response, types
│   └── types/                # Cloudflare bindings
├── migrations/               # SQL migrations
├── seed/                     # Python seed scripts (ported from old repo)
├── tests/                    # vitest
├── scripts/                  # dev, deploy, smoke test
├── docker/                   # docker-compose
├── .github/workflows/        # CI
├── wrangler.toml             # Worker config
└── package.json
```

## Deploy

```bash
# Dev (auto-deploys on push to develop via Cloudflare Git integration)
npm run deploy:dev

# Prod (manual, after review)
npm run deploy:prod
```

## Development rules

See [AGENTS.md](./AGENTS.md) for the agent-friendly development conventions.
