# AGENTS.md — dateandtime-api-v2

> Conventions for AI agents (and humans) working on this repo.
> Hierarchical AGENTS.md pattern: this is the root. Subdirectories get their own
> as needed. See §6 for the rule.

## §1. Stack (don't deviate)

- **Runtime:** Cloudflare Workers (V8)
- **Framework:** Hono 4.6+
- **Database:** Cloudflare D1 (`timeandtimepro-full`, ID c401ffb6)
- **Language:** TypeScript 5.6, strict mode
- **Validation:** Zod 3.23+
- **Tests:** Vitest 2.1+
- **No new dependencies** without a written reason in the PR description.

## §2. Project structure (one resource per file)

```
src/
├── index.ts              # thin router — only app.use() and app.route() calls
├── routes/               # ONE file per resource (cities, countries, time, etc.)
├── middleware/           # cross-cutting concerns
├── lib/                  # db, cache, validation, response, types
├── config/               # env, cors
└── types/                # Cloudflare bindings
```

**Rule:** Each resource file exports a Hono `new Hono()` sub-app. `index.ts` only does `app.route("/", resourceSubApp)`. No business logic in `index.ts`.

## §3. Response shape (always)

```ts
// Success
{ "success": true, "data": <T> }

// Error
{ "success": false, "error": { "code": "STRING_CODE", "message": "...", "details": ... } }
```

**Rule:** Use the helpers in `src/lib/response.ts` — `success()`, `fail()`, `paginate()`, `Errors.X`. Never construct response bodies inline.

## §4. D1 access (typed only)

```ts
// ✅ Good — typed via db.ts
import { Cities, Countries } from "@/lib/db";
const city = await Cities.byId(c.env.DB, 5128581);

// ❌ Bad — untyped, repeated everywhere
const city = await c.env.DB.prepare("SELECT * FROM cities WHERE geoname_id = ?").bind(5128581).first();
```

**Rule:** All common queries go through `src/lib/db.ts`. For one-off queries, use `c.env.DB.prepare(sql).bind(...).all<T>()` with a type from `src/lib/types.ts`.

## §5. Validation (Zod everywhere)

```ts
// ✅ Good — Zod schema
const { limit, offset } = c.req.query() as unknown as z.infer<typeof PaginationQuery>;

// ❌ Bad — manual parsing
const limit = parseInt(c.req.query("limit") ?? "50", 10);
```

**Rule:** All query/path/body inputs validated via Zod schemas. Errors caught by `errorHandler` middleware → 400 with `details: zodError.issues`.

## §6. Child AGENTS.md (Dox convention)

> This is the "Dox" framework — a hierarchical AGENTS.md pattern. Each subdirectory may have its own `AGENTS.md` with rules specific to that area. Child rules OVERRIDE root rules when they conflict.

When to create a child AGENTS.md:
- The subdirectory has 3+ files
- It has rules that don't apply to the rest of the repo
- Future agents will need to know "how to add a new route in `routes/`" or "how to add a new migration"

When NOT to create one:
- The subdirectory is shallow (1-2 files)
- The rules are already covered here

## §7. Deploy workflow (NEVER skip)

> This is the cardinal rule. **Never deploy to prod without explicit "ship it" from the user.**

```bash
# Dev — OK to deploy without asking
npm run deploy:dev    # → dt-api-v2-dev

# Prod — REQUIRES user confirmation
npm run deploy:prod   # → dt-api-v2
```

**Rule:** Before `npm run deploy:prod`, paste the diff summary and wait for "ship it". No exceptions.

## §8. Branch workflow (off develop, not main)

```bash
git checkout -b feature/<name>  # off develop, NOT main
# work
git push -u origin feature/<name>
# create PR → develop
# after merge, develop → main via release branch
```

**Rule:** Work on `feature/*` branches off `develop`. Never commit directly to `main` or `develop`.

## §9. Don't touch

- `timeandtimepro-full` D1 schema (read-only access at first)
- The existing `dateandtime-live` repo (separate concern)
- The existing `datetime-api` and `datetime-api-dev` Workers (legacy, will be retired)
- `node_modules/`, `.wrangler/`, `dist/` (gitignored)
- Any secret in `.dev.vars` (gitignored, never commit)

## §10. Future sections (Dox children)

When the project grows, add child AGENTS.md files:

- `src/routes/AGENTS.md` — how to add a new route file
- `src/lib/AGENTS.md` — how to add a new D1 helper
- `migrations/AGENTS.md` — migration conventions
- `tests/AGENTS.md` — testing conventions
- `seed/AGENTS.md` — how to add a new seed script
