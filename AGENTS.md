# DOX framework — DOX is highly performant AGENTS.md hierarchy installed here.
# Agent must follow DOX instructions across any edits.

## Core Contract

- AGENTS.md files are binding work contracts for their subtrees.
- Work products, source materials, instructions, records, assets, and durable docs must stay understandable from the nearest applicable AGENTS.md plus every parent AGENTS.md above it.

## Read Before Editing

1. Read the root AGENTS.md (this file).
2. Identify every file or folder you expect to touch.
3. Walk from the repository root to each target path.
4. Read every AGENTS.md found along each route.
5. If a parent AGENTS.md lists a child AGENTS.md whose scope contains the path, read that child and continue from there.
6. Use the nearest AGENTS.md as the local contract and parent docs for repo-wide rules.
7. If docs conflict, the closer doc controls local work details, but no child doc may weaken DOX.

**Do not rely on memory. Re-read the applicable DOX chain in the current session before editing.**

## Update After Editing

Every meaningful change requires a DOX pass before the task is done. Update the closest owning AGENTS.md when a change affects:

- purpose, scope, ownership, or responsibilities
- durable structure, contracts, workflows, or operating rules
- required inputs, outputs, permissions, constraints, side effects, or artifacts
- user preferences about behavior, communication, process, organization, or quality
- AGENTS.md creation, deletion, move, rename, or index contents

Update parent docs when parent-level structure, ownership, workflow, or child index changes. Update child docs when parent changes alter local rules. Remove stale or contradictory text immediately. Small edits that do not change behavior or contracts may leave docs unchanged, but the DOX pass still must happen.

## Hierarchy

- Root AGENTS.md is the DOX rail: project-wide instructions, global preferences, durable workflow rules, and the top-level Child DOX Index.
- Child AGENTS.md files own domain-specific instructions and their own Child DOX Index.
- Each parent explains what its direct children cover and what stays owned by the parent.
- The closer a doc is to the work, the more specific and practical it must be.

## Child Doc Shape

Default section order: Purpose, Ownership, Local Contracts, Work Guidance, Verification, Child DOX Index.

## Style

- Keep docs concise, current, and operational.
- Document stable contracts, not diary entries.
- Put broad rules in parent docs and concrete details in child docs.
- Prefer direct bullets with explicit names.
- Do not duplicate rules across many files unless each scope needs a local version.
- Delete stale notes instead of explaining history.

## Closeout

1. Re-check changed paths against the DOX chain.
2. Update nearest owning docs and any affected parents or children.
3. Refresh every affected Child DOX Index.
4. Remove stale or contradictory text.
5. Run existing verification when relevant (typecheck, lint, test, smoke).
6. Report any docs intentionally left unchanged and why.

## User Preferences (durable)

- **"Always ask before code change"** — confirm before any commit, push, deploy, or merge to protected branches.
- **"Only deploy to dev"** — never deploy to prod without explicit "ship it" from the user.
- **"Feature branches"** — work on `feature/*` branches off `develop`, never directly on `main` or `develop`.
- **"For page, will merge to develop"** — landing-page work is merged to `develop` after each page migration; the next phase continues from there.
- **"Implement Dox framework"** — use the agent0ai/dox pattern: hierarchical AGENTS.md, child rules override parents, walk the tree before editing.
- **Same v2.5 design system** — header, breadcrumb, footer must be consistent across all pages (UI repo, when it exists; not in this API repo).
- **API-first** — build the API in this repo first; the UI lives in a separate repo and consumes this API.

## API Development Rules (binding)

### Stack (no deviation)

- **Runtime:** Cloudflare Workers (V8 isolate).
- **Framework:** Hono 4.6+.
- **Database:** Cloudflare D1 (`timeandtimepro-full`, ID c401ffb6).
- **Language:** TypeScript 5.6, strict mode.
- **Validation:** Zod 3.23+ for all input parsing.
- **Tests:** Vitest 2.1+ (integration tests skip gracefully if no server).
- **No new dependencies** without a written reason in the PR description.

### HTTP Conventions (REST)

| Status | Use for |
|---|---|
| 200 | Successful GET, PUT, PATCH |
| 201 | Successful POST that created a resource |
| 204 | Successful DELETE |
| 400 | Bad input (Zod validation failure, bad param) |
| 401 | Missing/invalid auth |
| 403 | Auth OK but not allowed |
| 404 | Resource not found |
| 409 | Conflict (duplicate, version mismatch) |
| 422 | Semantically invalid (e.g. invalid date range) |
| 429 | Rate limited |
| 500 | Unexpected server error |
| 501 | Not implemented yet |
| 503 | Dependency unavailable |

### Response Shape (always)

```ts
// Success
{ "success": true, "data": <T> }

// Error
{ "success": false, "error": { "code": "STRING_CODE", "message": "...", "details": ... } }
```

Use the helpers in `src/lib/response.ts` — `success()`, `fail()`, `paginate()`, `Errors.X`. Never construct response bodies inline.

### Error Code Naming

Use `SCREAMING_SNAKE_CASE` codes. Be specific. Examples:

- `BAD_REQUEST`, `NOT_FOUND`, `INTERNAL_ERROR` (generic)
- `INVALID_CITY_ID`, `INVALID_DATE`, `MISSING_QUERY_PARAM` (specific)
- `RATE_LIMITED`, `CORS_BLOCKED`, `ADMIN_KEY_REQUIRED` (auth/limit)

### Pagination

- Query params: `limit` (1-1000, default 50) and `offset` (0+, default 0).
- Response: `{ success: true, data: { items: T[], pagination: { total, limit, offset, hasMore } } }`.
- Use the `paginate()` helper from `src/lib/response.ts`.

### Filtering & Sorting

- Single-value filters via query params: `?country=US&tz=America/New_York`.
- Multi-value via comma-separated: `?country=US,DE,JP` (parsed by `parseCsv` in `src/lib/validation.ts`).
- Sort via `?sort=name|population&order=asc|desc` (default: ascending, name).

### Versioning

- All endpoints under `/api/v1/...` or `/api/v2/...`.
- Never break a deployed version. New fields are additive. Removed fields require a new version.
- Document breaking changes in the PR description and the changelog.

### OpenAPI Documentation (binding)

**Every new route MUST be defined via `@hono/zod-openapi`'s `createRoute()` and registered with `.openapi()`.** This auto-generates the OpenAPI 3.1 spec served at `/openapi.json` and the Swagger UI at `/docs`.

```ts
import { OpenAPIHono, createRoute } from "@hono/zod-openapi";
import { z } from "zod";

const route = createRoute({
  method: "get",
  path: "/api/v1/cities/:id",
  summary: "Get city by ID",  // one-line
  description: "Returns a single city with full details",
  tags: ["Cities"],
  request: { params: CityParams },
  responses: {
    200: { content: { "application/json": { schema: SingleResponse(City) } }, description: "OK" },
    404: { content: { "application/json": { schema: ErrorResponse } }, description: "Not found" },
  },
});

app.openapi(route, async (c) => {
  // ... handler
});
```

**Why:** the spec is the contract. It's served to UI developers at `/docs`, consumed by code generators (openapi-generator, orval, etc.), and used by the smoke test to validate response shapes.

Rules:
- All request/response types come from Zod schemas in `src/lib/schemas.ts` (never raw TS types).
- Use the `singleResponse(name, schema)` and `listResponse(schema)` helpers for consistent envelope.
- Always include `tags` so Swagger UI groups endpoints.
- Always provide a 4xx response schema (typically `ErrorResponse`).
- New endpoints are added to the README's endpoint table by `npm run sync:readme` — the JSDoc on `createRoute()` is the source of truth.

### Caching

- `Cache-Control` headers on every GET response.
- Hot endpoints (`/api/v1/health`, `/api/v1/popular/defaults`) cached in Cloudflare KV (when bound).
- `ETag` for clients that want conditional requests (optional, add when needed).

### CORS

- Read `ALLOWED_ORIGINS` env var (comma-separated).
- `"*"` allowed only in `[env.dev]` for local development.
- In prod, list the exact origins (e.g. `https://dateandtime.live`).
- Use the helpers in `src/config/cors.ts`. Don't set CORS headers manually.

### Security

- No secrets in code. Use `wrangler secret put NAME` for any sensitive value.
- Admin endpoints (`/api/v1/admin/*`) require `Authorization: Bearer <ADMIN_API_KEY>` header.
- Input validation via Zod for every endpoint — never trust query params, path params, or body.
- SQL queries use parameterized binds only (`.bind(...)`). Never concatenate user input into SQL.

### Observability

- Structured JSON logging via the `logger` middleware (request, response, error events).
- Include `requestId` in every log line for correlation.
- Latency logged for every request.
- Errors logged with full stack trace in dev, redacted in prod.

## Deploy Workflow (NEVER skip)

```bash
# Dev — OK to deploy without asking
npm run deploy:dev    # → dt-api-v2-dev

# Prod — REQUIRES user confirmation
npm run deploy:prod   # → dt-api-v2
```

**Rule:** Before `npm run deploy:prod`, paste the diff summary and wait for "ship it". No exceptions.

## Branch Workflow (binding)

```bash
# 1. Start from develop
git checkout develop
git pull

# 2. Create a feature branch
git checkout -b feature/<name>   # e.g. feature/v25-cities, feature/rate-limit, feature/openapi-and-status

# 3. Implement task-by-task or endpoint-by-endpoint
#    - Each task: implement → write tests (unit + integration + edge cases) → verify → commit
#    - Run after every meaningful change:
#      npm run typecheck           # 0 errors
#      npm run lint                # 0 errors, 0 warnings
#      npm test                    # all pass
#      bash scripts/test-endpoints.sh  # all smoke checks pass
#      npm run sync:readme:check   # README in sync

# 4. Push the branch
git push -u origin feature/<name>

# 5. AUTOMATED CHECKS + USER FEEDBACK — REQUIRED before merge
#    Run the full check suite. THEN show the user:
#      - The diff summary (what changed, line counts)
#      - The test results (typecheck + lint + test + smoke output)
#      - Any new endpoints/behavior the user should review
#      - Screenshots if visual changes
#    Wait for explicit user approval ("ship it" / "go" / "lgtm" / "merge it") before proceeding.
#    If the user requests changes, address them in additional commits on the same branch.

# 6. Merge to develop (after user approval)
git checkout develop
git merge --no-ff -m "merge: <description> (feature/<name>)" feature/<name>
git push origin develop

# 7. DELETE the feature branch (local + remote) — they're ephemeral
git branch -d feature/<name>
git push origin --delete feature/<name>

# 8. Deploy develop to the API Worker in Cloudflare (dev env)
npm run deploy:dev

# 9. Verify the deploy (curl /api/v1/health, /api/v1/status, new endpoints)
#    AND ask the user to spot-check the dev Worker (give them the URL)
```

**Rules (binding):**

1. **Work on `feature/*` branches off `develop`.** Never commit directly to `main` or `develop`.
2. **One feature = one branch.** Don't mix unrelated changes.
3. **Task-by-task or endpoint-by-endpoint.** Commit per logical unit. Each commit should pass all checks.
4. **Test everything before merging.** Required checks (all must pass):
   - `npm run typecheck` — 0 TypeScript errors
   - `npm run lint` — 0 ESLint errors, 0 warnings
   - `npm test` — all vitest cases pass (unit + integration)
   - `bash scripts/test-endpoints.sh` — all smoke checks pass
   - `npm run sync:readme:check` — README in sync with code
5. **Cover edge cases.** For every endpoint, test at minimum:
   - Happy path (valid input, expected output)
   - Boundary values (limit=0, limit=1000, offset=0, max-offset)
   - Invalid input (bad types, missing fields, malformed params)
   - Not found (id that doesn't exist, country code not in DB)
   - Auth/permission failures (if applicable)
6. **Unit tests for pure functions.** Helpers in `src/lib/` (parsers, formatters, validators) MUST have unit tests in `tests/unit/` (no server required).
7. **User feedback is part of testing — REQUIRED before merge.** After all automated checks pass, present a clear summary to the user (diff stats, test output, new endpoints, behavior changes) and wait for explicit approval. Automated tests don't catch design issues, naming preferences, or whether the API "feels right" — humans do. The user's feedback may include:
   - Approval to merge ("ship it", "go", "lgtm", "merge it")
   - Requested changes (implement in additional commits on the same branch, then re-request feedback)
   - Questions or clarifications (address before merging)
   NEVER merge to develop without explicit user approval.
8. **Delete the branch on merge.** Feature branches are ephemeral. Once merged to develop, delete both local and remote copies immediately. This keeps the branch list clean and prevents stale code from being merged later by accident.
9. **Deploy develop after merge.** After deleting the branch, deploy develop to the dev API Worker (`dt-api-v2-dev`) via `npm run deploy:dev`. Verify the deploy with `curl https://dev.api.dateandtime.live/api/v1/health` AND ask the user to spot-check it in their browser.
10. **Never force-push to develop or main.** Use `--no-ff` for merge commits so the history is preserved.
11. **Prod deploy is a separate step.** Once develop has been verified in dev for at least 24 hours (or all tests pass), request "ship it" before `npm run deploy:prod`.

**Why this workflow:**

- **Ephemeral branches** keep the repo clean. A 6-month-old feature branch is a liability.
- **Automated tests** catch type errors, lint issues, and shape mismatches. They're fast and repeatable.
- **User feedback** catches design issues, naming, ergonomics, and "feels right" judgments. It MUST happen before merge — never after.
- **Deploy develop to dev Worker** means every merge is immediately verifiable against real D1 data.
- **Prod deploy is gated** by the "ship it" rule — never auto-deploy to prod.

## README Maintenance

The endpoints table in `README.md` is **auto-generated** by `npm run sync:readme`. It scans `src/routes/*.ts` for route definitions and writes the markdown table.

- **Every time you add or change a route, run `npm run sync:readme` before committing.**
- CI (`.github/workflows/ci.yml`) fails if `README.md` is out of sync with the code.
- The static parts of `README.md` (description, quick-start, stack) are manual. The endpoints table between the `<!-- ENDPOINTS_START -->` and `<!-- ENDPOINTS_END -->` markers is auto-generated.

## Don't Touch

- `timeandtimepro-full` D1 schema (read-only access at first).
- The existing `dateandtime-live` repo (UI, separate concern).
- The existing `datetime-api` and `datetime-api-dev` Workers (legacy, will be retired).
- `node_modules/`, `.wrangler/`, `dist/`, `.dev.vars` (gitignored, never commit).

## Child DOX Index

| Child | Owns |
|---|---|
| `src/AGENTS.md` | Source code organization, import rules, alias conventions |
| `src/routes/AGENTS.md` | Route file structure, how to add a new resource, JSDoc conventions |
| `src/lib/AGENTS.md` | D1 helpers, validation, response builders, types |
| `src/middleware/AGENTS.md` | Cross-cutting middleware (logger, error-handler, CORS) |
| `src/config/AGENTS.md` | Env validation, CORS config |
| `src/types/AGENTS.md` | Cloudflare bindings, shared types |
| `migrations/AGENTS.md` | SQL migration rules, naming, ordering |
| `tests/AGENTS.md` | Vitest conventions, integration vs unit, skip behavior |
| `scripts/AGENTS.md` | CLI tools: dev, deploy, smoke, extract, sync |
| `docker/AGENTS.md` | Local dev stack: docker-compose, Dockerfile, volumes |
| `.github/AGENTS.md` | CI workflows, deploy gates, required checks |
