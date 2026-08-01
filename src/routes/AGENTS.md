# src/routes/ — HTTP route files

## Purpose

One file per API resource. Each file exports an `OpenAPIHono` sub-app that owns all endpoints for that resource (e.g. `cities.ts` owns every `/api/v1/cities/*` endpoint). Endpoints are defined via `createRoute()` from `@hono/zod-openapi` for auto-generated OpenAPI docs.

## Ownership

Routes own HTTP shape, not business logic. Business logic (D1 queries, validation, calculations) lives in `src/lib/`. Routes are thin: parse input → call helper → return response.

## Local Contracts

### File structure

```ts
/**
 * <Resource> endpoints.
 *   GET  /api/v1/<resource>             — <one-line description>
 *   GET  /api/v1/<resource>/:id         — <one-line description>
 *   POST /api/v1/<resource>             — <one-line description>
 */
import { OpenAPIHono, createRoute } from "@hono/zod-openapi";
import { z } from "zod";
import { success, paginate, Errors } from "@/lib/response";
import { Cities } from "@/lib/db";
import { City, CityQuery, CityParams, ErrorResponse, listResponse, singleResponse } from "@/lib/schemas";
import type { Env, Variables } from "@/types/env";

const <resource> = new OpenAPIHono<{ Bindings: Env; Variables: Variables }>();

// Define route via createRoute() — generates OpenAPI metadata
const listRoute = createRoute({
  method: "get",
  path: "/api/v1/<resource>",
  summary: "List <resource> (paginated)",
  description: "Returns a paginated list of <resource> with optional filters",
  tags: ["<Resource>"],
  request: { query: CityQuery },
  responses: {
    200: { content: { "application/json": { schema: listResponse(City) } }, description: "OK" },
    400: { content: { "application/json": { schema: ErrorResponse } }, description: "Bad request" },
  },
});

<resource>.openapi(listRoute, async (c) => {
  const { limit, offset, country, tz, sort, order } = c.req.valid("query");
  const items = await Cities.list(c.env.DB, { limit, offset, country, tz, sort, order });
  const total = await Cities.count(c.env.DB, { country, tz });
  return c.json({ success: true, data: { items, pagination: { total, limit, offset, hasMore: offset + items.length < total } } });
});

// HEAD probe for boot-time feature detection
<resource>.on("HEAD", "/api/v1/<resource>", () => new Response(null, { status: 200 }));

export default <resource>;
```

### JSDoc above every route

Required. The endpoint extractor (`scripts/extract-endpoints.ts`) reads JSDoc to populate the README endpoints table. Format:

```ts
/** <One-line description, no period, imperative mood> */
<resource>.get("/api/v1/path", ...);
```

### Mounting in `src/index.ts`

```ts
import cities from "@/routes/cities";
app.route("/", cities);  // mount at root — routes already include full path
```

### HEAD probes

Every GET endpoint should have a matching HEAD probe for boot-time feature detection. The probe returns `new Response(null, { status: 200 })` (or 400 if it requires a path param).

## Work Guidance

### Adding a new resource

1. Create `src/routes/<resource>.ts` with the structure above.
2. Add typed D1 helpers in `src/lib/db.ts` (see `src/lib/AGENTS.md`).
3. Mount in `src/index.ts`: `app.route("/", <resource>);`.
4. Add a smoke test in `scripts/test-endpoints.sh`.
5. Run `npm run sync:readme` to regenerate the endpoints table.
6. Add `import` and a route file in `tests/` for integration tests.

### Adding a new endpoint to an existing resource

1. Add the handler in the resource's file with JSDoc.
2. Add the DB helper if needed.
3. Add to `scripts/test-endpoints.sh`.
4. Run `npm run sync:readme`.
5. Commit.

## Verification

```bash
npm run typecheck       # 0 errors
npm run lint            # 0 errors, 0 warnings
npm run sync:readme     # README.md updates
bash scripts/test-endpoints.sh  # all checks pass
```

## Child DOX Index

No children — routes are flat, no subdirectories.
