# dateandtime-api-v2 — AGENTS.md (root)

> **Hierarchical context for AI agents.** This file is the entry point. Sub-contexts live in
> `src/AGENTS.md`, `migrations/AGENTS.md`, `scripts/AGENTS.md`, `docs/AGENTS.md`, `tests/AGENTS.md`.
> Read this file first, then the sub-contexts relevant to your task.

## What this project is

A **Cloudflare Workers + D1 + Hono** REST API that powers the time/date/zone service for
dateandtime.live. Exposes country/state/city/timezone data with multi-language search,
FTS5 with diacritic normalization, and per-city IANA timezone resolution.

**Public URL (dev):** https://dt-api-v2-dev.nsura2029.workers.dev
**Public URL (prod):** https://dt-api-v2.nsura2029.workers.dev
**OpenAPI spec:** https://dt-api-v2-dev.nsura2029.workers.dev/openapi.json
**Swagger UI:** https://dt-api-v2-dev.nsura2022.workers.dev/docs

## Tech stack (binding — don't change without asking)

- **Runtime:** Cloudflare Workers (V8 isolate, Node.js compat)
- **Framework:** Hono 4.12+ (OpenAPIHono for Swagger)
- **Database:** Cloudflare D1 (SQLite under the hood)
- **Language:** TypeScript 5.9, strict mode, `noUncheckedIndexedAccess`
- **Validation:** Zod 3.25+ (for request/response schemas)
- **Tests:** Vitest 2.1+ (with `app.request()` for in-process)
- **Lint:** ESLint 9+ (flat config)
- **Wrangler:** 3.114.x (pinned — wrangler 4.x has breaking changes)
- **Node:** 22.13+ required (user is on 24+)

## 12 binding rules (work by these)

1. **Work on `feature/*` branches** off `develop`. Never `main` or `develop` directly.
2. **One feature = one branch.** Branch name: `feature/<short-name>` or `fix/<short-name>`.
3. **Task-by-task / endpoint-by-endpoint commits.** One logical unit per commit.
4. **All 5 checks must pass before push:**
   - `npm run typecheck` (tsc --noEmit)
   - `npm run lint` (eslint)
   - `npm run test` (vitest run)
   - `npm run smoke` (live API smoke test — skips if no server)
   - `npm run sync:readme` (auto-extract endpoints from JSDoc → README)
5. **Cover edge cases** in every endpoint: happy path, boundary, invalid, not-found, auth.
6. **Unit tests for pure functions** (DAOs, formatters, validators). Integration tests for routes.
7. **User pulls and verifies locally** before any merge. Never merge without explicit "lgtm".
8. **User approval required** (`lgtm`, `ship it`, `go`) before merge.
9. **Delete branch after merge** (local + remote). Branches are ephemeral.
10. **User pulls develop + re-verifies** after merge.
11. **Deploy develop to dev Worker** after user confirms (`npm run deploy:dev`).
12. **Never force-push develop/main.** Prod deploy is gated by explicit "ship it".

## File structure

```
dateandtime-api-v2/
├── AGENTS.md                  ← (this file)
├── src/
│   ├── AGENTS.md              ← source code conventions
│   ├── index.ts               ← Worker entry: app.fetch export
│   ├── config/
│   │   └── env.ts             ← env-var parsing, CORS, allowed origins
│   ├── routes/
│   │   ├── docs.ts            ← OpenAPI spec + Swagger UI
│   │   ├── health.ts          ← GET /api/v1/health (DB stats + latency)
│   │   └── status.ts          ← GET /api/v1/status (build/runtime/DB info)
│   ├── lib/
│   │   ├── db.ts              ← D1 DAOs (Regions, Subregions, Countries, ...)
│   │   ├── types.ts           ← TypeScript types matching schema
│   │   └── schemas.ts         ← Zod schemas for request/response
│   └── middleware/
│       └── (planned: us-state-gate.ts)
├── migrations/                ← SQL migrations (D1)
│   ├── AGENTS.md              ← migration guidelines
│   ├── 000_initial.sql
│   ├── 100_drop_all.sql       ← DESTRUCTIVE, not applied by default
│   ├── 101_create_schema.sql  ← 10 new tables (regions, subregions, ..., place_redirects)
│   ├── 102_seed_regions.sql
│   ├── 103_seed_subregions.sql
│   ├── 104_seed_countries.sql
│   ├── 105_seed_admin_regions.sql
│   ├── 106_seed_time_zones.sql
│   └── cities/                ← 223 per-country files (gitignored, 21MB total)
│       └── run-all.sh
├── scripts/
│   ├── AGENTS.md              ← seed scripts guidelines
│   ├── verify-and-run.sh      ← local dev runner
│   ├── deploy.sh              ← prod deploy (requires "ship it")
│   └── seed/                  ← generator scripts for migrations
│       ├── 102_generate_regions_subs_countries.py
│       ├── 105_generate_admin_regions.py
│       ├── 106_generate_timezones.py
│       └── 107_generate_cities.py
├── tests/                     ← Vitest tests
│   ├── AGENTS.md              ← test conventions
│   ├── health.test.ts
│   ├── status.test.ts
│   └── (route tests here)
├── docs/
│   ├── AGENTS.md              ← documentation conventions
│   ├── setup.md               ← how to set up the project
│   ├── troubleshooting.md     ← common issues + fixes
│   ├── KNOWN_ISSUES.md        ← BUG-1, BUG-2, TODO-1
│   └── api/                   ← OpenAPI spec, Postman collection
├── wrangler.toml              ← CF Workers + D1 bindings
├── package.json
├── tsconfig.json
├── vitest.config.ts
├── eslint.config.js
├── Dockerfile                 ← Node 22 for local dev
└── README.md                  ← auto-generated from JSDoc
```

## Database (current state)

**Active D1:** `timeandtimepro-full-v2` (UUID in `wrangler.toml`).
**Legacy D1:** `timeandtimepro-full` (preserved in `wrangler.toml` ROLLBACK section, not active).

10 tables:
- `regions` (6) — UN M49 codes
- `subregions` (22) — UN M49 sub-regions
- `countries` (250) — ISO 3166-1 + dr5hn attributes
- `administrative_regions` (5,308) — states/provinces/counties
- `cities` (152,970) — canonical place records
- `time_zones` (391) — IANA tzdb-2026c (312 canonical + 79 aliases)
- `place_names` (empty) — multi-language FTS5 search
- `city_time_zones` (empty) — M2M cities ↔ time_zones
- `country_time_zones` (empty) — M2M countries ↔ time_zones
- `data_sources` (8) + `import_history` (10) + `place_redirects` (30) — data lineage

Read `migrations/AGENTS.md` for migration patterns and D1 limits.

## Current endpoints (Phase 1)

| Method | Path | Purpose | Swagger tag |
|---|---|---|---|
| GET | `/` | API root (manifest) | Meta |
| GET | `/api/v1/health` | DB stats + latency | Meta |
| GET | `/api/v1/status` | Build/runtime/DB info | Meta |
| HEAD | `/api/v1/health` | 200 probe (CDN-style) | Meta |
| HEAD | `/api/v1/status` | 200 probe (CDN-style) | Meta |
| GET | `/openapi.json` | OpenAPI 3.1 spec | (not in Swagger) |
| GET | `/docs` | Swagger UI | (not in Swagger) |

**Every endpoint MUST appear in the OpenAPI spec with full metadata:** summary, description,
tags, parameter schemas, request body schema, response schemas (200, 4xx, 5xx), examples.

## Style guide

- **Naming:** `kebab-case.ts` for files, `PascalCase.ts` for types/classes, `@/*` path alias
- **Naming exception:** `Otd` const in `db.ts` (not `OnThisDay`) to avoid collision with `OTD`
- **Comments:** WHY not WHAT. No "this function does X" — explain the trade-off or gotcha.
- **Error handling:** throw `HTTPException` from Hono, not raw `Error`. Always include `status` and a JSON body.
- **Logging:** `console.log` is fine for Cloudflare Workers (becomes tail log). No `console.error` for expected paths.
- **No console.log in production code paths** — gate with `if (env.DEBUG)` or just remove before merge.

## Hard rules (don't violate)

- **NEVER paste a Cloudflare API token in chat.** Set as env var only. See `docs/setup.md`.
- **NEVER merge to main without "ship it" from user.** Prod is gated.
- **NEVER push to develop without user-pulled verification.** User has the final say.
- **NEVER delete a branch that hasn't been merged.** Even broken branches.
- **NEVER drop a D1 table without explicit user OK** (we lost data once, won't again).
- **NEVER run wrangler without --remote on prod-shaped D1s** (will create empty local DB).
- **NEVER hardcode /tmp** in Python (use `tempfile.gettempdir()` for cross-platform).
- **NEVER use `or` for None handling in SQL generators** (`0 or 'NULL'` = 'NULL' since 0 is falsy).
- **NEVER put `;` inside a multi-row INSERT** (only at the very end). Use separate INSERT statements instead.
- **NEVER use wrangler's --file= with a glob in Git Bash** (globs not expanded; use explicit filenames or for loop).

## Known issues (full detail in `docs/KNOWN_ISSUES.md`)

- **BUG-1:** Swagger UI "Try it out" fails CORS in `wrangler dev --remote` proxy. Workaround:
  use the live URL `https://dt-api-v2-dev.nsura2029.workers.dev/docs` directly.
- **BUG-2:** 503 on `/api/v1/status` when using `npm run dev` (no --remote). Local SQLite
  has no schema. Use `npm run dev:remote`.
- **TODO-1:** Port the better spec-fetch error UX from discarded `feature/complete-swagger-ui`
  branch (commit a61d5d5 on develop before discard).
- **In progress:** Cities apply FK error. See `migrations/AGENTS.md` for current state.

## How to ask for help

When a user request is ambiguous, ask ONE question that actually changes the outcome. Don't
list every possible interpretation.

Examples:
- ✅ "Should I add a new endpoint to the existing `cities` route, or create a new `search` route group?"
- ❌ "There are 12 ways to do this. Should we go with A, B, C, D, E, F, G, H, I, J, K, or L?"

## Related projects

- `dateandtime-live-frontend` (UI repo, separate) — consumes this API
- `dateandtime-live` (legacy project) — older API at https://dateandtime.live

## Memory hooks

- Always check `migrations/AGENTS.md` BEFORE writing a new migration
- Always check `scripts/AGENTS.md` BEFORE writing a new generator
- Always check `tests/AGENTS.md` BEFORE writing a new test file
- Always check `src/AGENTS.md` BEFORE writing a new route or DAO
- Always check `docs/AGENTS.md` BEFORE updating any docs

## Doc-update framework (every merge to develop)

**The contract:** every merge to `develop` must update these files:

1. **`STATUS.md`** (root) — single source of truth for "where are we"
   - Branch state, last 5 commits, test count, DB stats, next 3 things
   - Refresh with: `bash scripts/sync-status.sh --write`
2. **`CHANGELOG.md`** (root) — per-PR notes, newest first
   - Add `[unreleased]` entry BEFORE merge
   - After merge, rename to `[released] — develop @ <hash>`
3. **`TODO.md`** (root) — milestone checklist (M0-M10+)
   - Move completed items from Active → Done
   - Add new Active items discovered during the milestone
4. **`docs/`** — refresh any spec doc that changed (core logic, data audit, test plan)
5. **`reports/m{N}-*.md`** — write a per-milestone audit for new milestones

**Pre-merge check:**

```bash
bash scripts/pre-merge-to-develop.sh        # check
bash scripts/pre-merge-to-develop.sh --fix  # auto-fix
```

If it exits non-zero, do NOT merge. Fix the warnings/errors first.

**Post-merge:**

```bash
bash scripts/sync-status.sh --write
git add STATUS.md CHANGELOG.md
git commit -m "docs: sync status after merge to develop"
```

**Framework scripts:**
- `scripts/sync-status.sh` — refreshes STATUS.md timestamp + commits
- `scripts/pre-merge-to-develop.sh` — checks doc framework before merge
- `scripts/build_postman.py` — regenerates Postman collection (M10+)

