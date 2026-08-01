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

## Branch Workflow

```bash
git checkout develop
git checkout -b feature/<name>  # off develop, NOT main
# work
git push -u origin feature/<name>
# create PR → develop
# after merge, develop → main via release branch
```

**Rule:** Work on `feature/*` branches off `develop`. Never commit directly to `main` or `develop`.

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
