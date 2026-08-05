# dateandtime-api-v2

> dateandtime.live API v2 — Hono + Cloudflare D1 + Zod, deployed on Cloudflare Workers.

The canonical API for dateandtime.live. Replaces the legacy `datetime-api` Worker with a modular, type-safe, testable codebase.

## Stack

- **Runtime:** Cloudflare Workers (V8 isolate)
- **Framework:** Hono 4.6 + @hono/zod-openapi
- **Database:** Cloudflare D1 (SQLite at edge) — `timeandtimepro-full-v2` (**152,970** cities, 250 countries, 462 IANA timezones)
- **Validation:** Zod 3.23
- **Tests:** Vitest 2.1 (174 passing)
- **Local dev:** Docker + wrangler dev (D1 persisted in volume)
- **CI:** GitHub Actions (lint, typecheck, test, README sync check)
- **API docs:** Swagger UI at `/docs`, OpenAPI 3.1 at `/openapi.json`

## Quick start

```bash
# 1. Install deps (uses package-lock.json — use `npm ci` for reproducible installs)
npm ci

# 2. Run locally (no Docker)
npm run dev          # → http://localhost:8787 (local SQLite D1)
npm run dev:remote   # → http://localhost:8787 (talks to deployed Worker's D1)

# 3. Or run in Docker
npm run dev:docker          # local SQLite
npm run dev:docker:remote   # remote D1 (needs CLOUDFLARE_API_TOKEN)

# 4. Run tests
npm test

# 5. Smoke test all endpoints (needs a running server)
npm run smoke

# 6. Sync README endpoint table (run after adding a route)
npm run sync:readme

# 7. Check README is in sync (used by CI)
npm run sync:readme:check

# 8. Run all 5 checks at once (no server required — smoke test skips if no server)
npm run verify:checks
```

## First-time setup on Windows (Git Bash)

```bash
# 1. Clone the repo
cd /c/dev/dt-live
git clone https://github.com/nsura2029-art/dateandtime-api-v2.git
cd dateandtime-api-v2
git checkout develop
npm ci

# 2. (Optional) Set up Cloudflare for remote D1 mode
#    a) Create an API token at https://dash.cloudflare.com/profile/api-tokens
#       - Click "Use template" next to "Edit Cloudflare Workers"
#       - This auto-includes: Workers Scripts:Edit, D1:Edit, Workers KV Storage:Edit
#       - Set Account Resources: your account
#       - Set Zone Resources: All zones (or specific)
#       - Click "Continue to summary" → "Create Token"
#       - COPY the token (you'll only see it once — never share it in chat)
#    b) Get your Account ID:
#       - Cloudflare dashboard → Workers & Pages → right sidebar → "Account ID"
#    c) Set env vars (in Git Bash — NOT PowerShell):
export CLOUDFLARE_API_TOKEN="your-NEW-token-here"
export CLOUDFLARE_ACCOUNT_ID="your-account-id-here"

# 3. Verify the token works
npx wrangler whoami
# Should print your account name + ID. If it errors, the token is wrong.

# 4. Run the dev server (local D1 — no token needed)
npm run dev
# → http://localhost:8787/

# 5. Or run in Docker (local D1)
npm run dev:docker
# → same URL, but in a container

# 6. Or run with REMOTE D1 (real 33,945 cities — needs token)
npm run dev:remote
# → talks to the deployed Worker; uses prod data
```

### Shell-specific notes

| Shell | Prompt | Env var syntax |
|---|---|---|
| **PowerShell** | `PS C:\dev\...>` | `$env:NAME="value"` |
| **Git Bash (MINGW64)** | `user@host MINGW64 /c/...` | `export NAME="value"` |
| **CMD** | `C:\dev\...>` | `set NAME=value` |

**Common gotcha**: setting env vars in PowerShell doesn't persist to Git Bash and vice versa. Set them in whichever shell you'll use to run wrangler.

## Common issues

| Error | Fix |
|---|---|
| `Wrangler requires at least Node.js v22.0.0` | Update Node to 22+. Use `nvm install 22` or download from nodejs.org. Docker users: pull latest image (already on Node 22). |
| `npm error EUSAGE: ... can only install with an existing package-lock.json` | `git pull` then re-run. Lock file might be missing on your branch. |
| `npm error EUSAGE: package.json and package-lock.json out of sync` | Run `npm install` to update lock file, then `git add package-lock.json` and commit. |
| `Unknown argument: persist` | Update to latest wrangler (`npm install wrangler@latest`). The `--persist` flag is gone in 3.x. |
| `Failed to fetch. URL scheme must be "http" or "https" for CORS request` (in Swagger UI) | Dev server not running. Start with `npm run dev` first. |
| Docker: `exited with code 1 (restarting)` | Usually a Node version mismatch or missing token. Check `docker compose logs`. |
| `CLOUDFLARE_API_TOKEN env var is required for remote mode` | Run with `--local` flag, or set the env var first. |

## Interactive API docs

| URL | What it is |
|---|---|
| `GET /openapi.json` | OpenAPI 3.1 spec (machine-readable) |
| `GET /docs` | Interactive Swagger UI for developers |
| `GET /api/v1/status` | Comprehensive service info: build, runtime, DB, features |

After `npm run dev`, open <http://localhost:8787/docs> to explore the API in your browser.

## Endpoints

<!-- ENDPOINTS_START -->

| Method | Path | Description |
|---|---|---|
| `GET` | `/` | API root |
| `GET` | `/api/v1/admin2/{id}` | Detail for an admin-2 |
| `GET` | `/api/v1/airports/near` | Find airports near a point |
| `GET` | `/api/v1/cities` | List cities with filters |
| `GET` | `/api/v1/cities/{id}` | Get city detail by ID |
| `GET` | `/api/v1/cities/{id}/airports` | Get airports serving a city |
| `GET` | `/api/v1/cities/{id}/aliases` | Get alternate / historical names for a city |
| `GET` | `/api/v1/cities/{id}/climate` | Get climate summary for a city |
| `GET` | `/api/v1/cities/{id}/postcodes` | Get all postcodes for a city |
| `GET` | `/api/v1/cities/{id}/translations` | Get all translations for a city |
| `GET` | `/api/v1/cities/{id}/translations/{lang}` | Get city name in a specific language |
| `GET` | `/api/v1/cities/near` | Find cities near a point |
| `GET` | `/api/v1/cities/search` | Search cities by name |
| `GET` | `/api/v1/countries` | List all countries |
| `GET` | `/api/v1/countries/{cca2}` | Get a single country by cca2 |
| `GET` | `/api/v1/countries/{cca2}/admin2` | List admin-2 for a country |
| `GET` | `/api/v1/countries/{cca2}/states` | List states/provinces for a country |
| `GET` | `/api/v1/data-quality` | Data quality summary |
| `GET` | `/api/v1/data-quality/issues` | List data quality issues |
| `GET` | `/api/v1/health` | Health check (DB stats + latency) |
| `GET` | `/api/v1/holidays` | List holidays with filters and date range |
| `GET` | `/api/v1/postcodes/search` | Find cities by postal code |
| `GET` | `/api/v1/regions` | List all UN regions |
| `GET` | `/api/v1/regions/{code}/subregions` | List sub-regions for a region |
| `GET` | `/api/v1/sources` | GET /api/v1/sources |
| `GET` | `/api/v1/sources/:key` | GET /api/v1/sources/:key |
| `GET` | `/api/v1/sources/:key/releases` | GET /api/v1/sources/:key/releases |
| `GET` | `/api/v1/staging/cities` | GET /api/v1/staging/cities |
| `GET` | `/api/v1/staging/summary` | GET /api/v1/staging/summary |
| `GET` | `/api/v1/states/{id}` | Get a single state/province |
| `GET` | `/api/v1/status` | API status and service info |
| `GET` | `/api/v1/subregions/{code}/countries` | List countries in a sub-region |
| `GET` | `/api/v1/time/convert` | Convert a wall-clock time between two cities/timezones |
| `GET` | `/api/v1/time/now` | Get current local time in a city |
| `GET` | `/api/v1/translations/search` | Search cities by translated name |
| `HEAD` | `/api/v1/health` | Health check probe — returns 200 if API is up (no body, for monitoring agents). |
| `HEAD` | `/api/v1/status` | Status probe — returns 200 if API is up (no body) |

_37 endpoints across 17 route files._

_Auto-generated by `npm run sync:readme`. Don't edit by hand._
<!-- ENDPOINTS_END -->

## API Examples

```bash
# Search for Tokyo with country boost
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/cities/search?q=Tokyo&country=JP&limit=3'

# Get city detail with all enrichments
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/cities/64500' | jq
# Returns: name, native (東京), stateCode, type, wikiDataId, timezone, postcodes, translations, dataQuality

# Find cities by Japanese name
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/translations/search?q=%E6%9D%B1%E4%BA%AC&lang=ja'

# Find cities by US ZIP code
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/postcodes/search?code=32501&country=US&exact=true'

# Disambiguate same-name cities
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/cities/search?q=Phoenix&country=US&state=AZ'

# Get data quality audit
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/data-quality' | jq
# Returns: confidence counts, sources, migrations, etc.

# Find Null Island cities (spec §14.1)
curl 'https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/data-quality/issues?type=null_island'
```

## Project structure

```
dateandtime-api-v2/
├── src/
│   ├── index.ts              # thin router (~80 lines)
│   ├── config/               # env validation, CORS
│   ├── routes/               # ONE file per resource (Hono sub-apps)
│   ├── middleware/           # cross-cutting concerns
│   ├── lib/                  # db, cache, validation, response, types
│   └── types/                # Cloudflare bindings
├── migrations/               # SQL migrations
├── seed/                     # Python seed scripts (ported from old repo)
├── tests/                    # vitest
├── scripts/                  # dev, deploy, smoke, extract, sync
├── docker/                   # docker-compose
├── .github/workflows/        # CI
├── wrangler.toml             # Worker config
└── package.json
```

## Available npm scripts

| Script | What it does |
|---|---|
| `npm run dev` | Start wrangler dev on port 8787 (D1 auto-persisted) |
| `npm run dev:docker` | Start dev server in Docker |
| `npm run build` | Dry-run deploy (output to `dist/`) |
| `npm run deploy:dev` | Deploy to `dt-api-v2-dev` Worker |
| `npm run deploy:prod` | Deploy to `dt-api-v2` (prod) — REQUIRES "ship it" |
| `npm run tail:dev` | Tail logs for dev Worker |
| `npm run tail:prod` | Tail logs for prod Worker |
| `npm test` | Run vitest (skips integration tests if no server) |
| `npm run typecheck` | `tsc --noEmit` (must be 0 errors) |
| `npm run lint` | ESLint (must be 0 errors, 0 warnings) |
| `npm run format` | Prettier write |
| `npm run smoke` | Smoke test 30+ endpoints against the running server |
| `npm run sync:readme` | Regenerate the endpoints table in README.md |
| `npm run sync:readme:check` | CI check — exit 1 if README is out of sync |
| `npm run migrate:dev` | Apply a migration to the dev D1 |
| `npm run migrate:prod` | Apply a migration to the prod D1 — REQUIRES "ship it" |

## Dox (AGENTS.md hierarchy)

This repo uses the [Dox framework](https://github.com/agent0ai/dox) — a hierarchical AGENTS.md pattern. Each directory has its own AGENTS.md with rules specific to that area.

| Doc | What it covers |
|---|---|
| `AGENTS.md` | Root: stack, deploy workflow, API rules, Dox child index |
| `src/AGENTS.md` | Source code organization, path aliases, file naming |
| `src/routes/AGENTS.md` | How to add a new route file, JSDoc conventions |
| `src/lib/AGENTS.md` | DB helpers, validation, response builders, types |
| `src/middleware/AGENTS.md` | Cross-cutting middleware, factory pattern, ordering |
| `src/config/AGENTS.md` | Env validation, CORS config |
| `src/types/AGENTS.md` | Cloudflare bindings, context variables |
| `migrations/AGENTS.md` | SQL migration rules, naming, ordering |
| `tests/AGENTS.md` | Vitest conventions, skip-when-no-server pattern |
| `scripts/AGENTS.md` | CLI tools, sync-readme, smoke test |
| `docker/AGENTS.md` | Local dev stack, volumes, health check |
| `.github/AGENTS.md` | CI workflows, required checks |

## Deploy

```bash
# Dev (auto-deploys on push to develop via Cloudflare Git integration)
npm run deploy:dev    # → dt-api-v2-dev

# Prod (manual, after review)
npm run deploy:prod   # → dt-api-v2
```

## Worker bindings (Cloudflare)

| Binding | Type | Source |
|---|---|---|
| `DB` | D1Database | `timeandtimepro-full` (c401ffb6) |
| `CACHE` (optional) | KVNamespace | Add via `wrangler kv:namespace create CACHE` |
| `API_NAME`, `API_VERSION`, etc. | vars | `[vars]` in `wrangler.toml` |
| `ADMIN_API_KEY` (optional) | secret | `wrangler secret put ADMIN_API_KEY` |
