# src/AGENTS.md

> Conventions for source code. Read this BEFORE writing any new route, DAO, or middleware.
> Sub-context of root AGENTS.md.

## Directory structure

```
src/
├── index.ts                   ← Worker entry: `export default { async fetch(req, env, ctx) { return app.fetch(req, env, ctx) } }`
├── config/
│   └── env.ts                 ← Parse env vars, CORS, allowed origins
├── routes/
│   ├── docs.ts                ← OpenAPI spec + Swagger UI (OpenAPIHono)
│   ├── health.ts              ← GET /api/v1/health
│   ├── status.ts              ← GET /api/v1/status
│   └── (planned: regions.ts, countries.ts, cities.ts, search.ts)
├── lib/
│   ├── db.ts                  ← D1 DAOs (one per table)
│   ├── types.ts               ← TypeScript types matching schema
│   ├── schemas.ts             ← Zod request/response schemas
│   └── (planned: search.ts, formatter.ts)
└── middleware/
    └── (planned: us-state-gate.ts, rate-limit.ts, api-key.ts)
```

## Hono patterns (binding)

### Use OpenAPIHono for every route

```ts
import { OpenAPIHono, createRoute, z } from '@hono/zod-openapi';

export const citiesRoute = new OpenAPIHono();

const listCities = createRoute({
  method: 'get',
  path: '/api/v1/cities',
  tags: ['Cities'],
  summary: 'List cities',
  description: 'Returns a paginated list of cities...',
  request: {
    query: z.object({
      country: z.string().length(2).optional(),
      limit: z.coerce.number().int().min(1).max(1000).default(50),
      offset: z.coerce.number().int().min(0).default(0),
    }),
  },
  responses: {
    200: { content: { 'application/json': { schema: CitiesResponseSchema } } },
    400: { content: { 'application/json': { schema: ErrorSchema } } },
    500: { content: { 'application/json': { schema: ErrorSchema } } },
  },
});

citiesRoute.openapi(listCities, async (c) => {
  const { country, limit, offset } = c.req.valid('query');
  const cities = await db.listCities(c.env.DB, { country, limit, offset });
  return c.json({ cities, count: cities.length });
});
```

**Every endpoint MUST have full OpenAPI metadata** — this is a binding rule.

### Mount routes

```ts
// src/index.ts
import { healthRoute } from './routes/health';
import { citiesRoute } from './routes/cities';

const app = new OpenAPIHono();
app.route('/', healthRoute);
app.route('/', citiesRoute);
```

### Error handling

```ts
import { HTTPException } from 'hono/http-exception';

// Throw with status + body
throw new HTTPException(404, { message: `City ${id} not found` });

// Or use c.json for less critical errors
return c.json({ error: 'Invalid input', details: error.flatten() }, 400);
```

### HEAD requests (for CDN probes)

```ts
import { createRoute } from '@hono/zod-openapi';

const healthHead = createRoute({
  method: 'head',
  path: '/api/v1/health',
  tags: ['Meta'],
  summary: 'Health probe (HEAD)',
  responses: { 200: { description: 'OK' } },
});

app.openapi(healthHead, (c) => c.body(null, 200));
```

## DAO patterns

### One DAO per table

```ts
// src/lib/db.ts
export const citiesDao = {
  async list(env: D1Database, opts: { country?: string; limit: number; offset: number }) {
    const { country, limit, offset } = opts;
    const sql = country
      ? 'SELECT * FROM cities WHERE country_id = (SELECT id FROM countries WHERE cca2 = ?) ORDER BY population DESC LIMIT ? OFFSET ?'
      : 'SELECT * FROM cities ORDER BY population DESC LIMIT ? OFFSET ?';
    const params = country ? [country, limit, offset] : [limit, offset];
    const result = await env.prepare(sql).bind(...params).all();
    return result.results as City[];
  },

  async getById(env: D1Database, id: number) {
    return env.prepare('SELECT * FROM cities WHERE id = ?').bind(id).first() as Promise<City | null>;
  },

  async findByName(env: D1Database, name: string, countryCca2?: string) {
    const sql = countryCca2
      ? `SELECT c.* FROM cities c
         JOIN countries co ON co.id = c.country_id
         WHERE c.name = ? AND co.cca2 = ?`
      : 'SELECT * FROM cities WHERE name = ?';
    const params = countryCca2 ? [name, countryCca2] : [name];
    return env.prepare(sql).bind(...params).all();
  },
};
```

### Caching (planned)

For endpoints that hit the same data repeatedly (e.g. `GET /api/v1/countries/US`), use
Cloudflare's `caches.default`:

```ts
const cache = caches.default;
const cached = await cache.match(request);
if (cached) return cached;

const response = await fetchFresh();
const cacheable = new Response(response.body, response);
cacheable.headers.set('Cache-Control', 'public, max-age=300');
await cache.put(request, cacheable);
return cacheable;
```

## Type patterns

```ts
// src/lib/types.ts
export interface City {
  id: number;
  name: string;
  ascii_name: string | null;
  country_id: number;
  state_id: number | null;
  district_id: number | null;
  latitude: number;
  longitude: number;
  timezone: string;
  population: number | null;
  // ...
}

export interface Country {
  id: number;
  cca2: string;  // 'US'
  cca3: string | null;  // 'USA'
  name: string;
  // ...
}
```

**Type names match the table name in singular:** `cities` → `City`, `countries` → `Country`.

## Zod schema patterns

```ts
// src/lib/schemas.ts
import { z } from 'zod';

export const CitySchema = z.object({
  id: z.number().int(),
  name: z.string(),
  // ... matches City type
});

export const CitiesResponseSchema = z.object({
  cities: z.array(CitySchema),
  count: z.number().int(),
});

export const ErrorSchema = z.object({
  error: z.string(),
  details: z.unknown().optional(),
});
```

## CORS (binding — `http://localhost:*` port-wildcard)

```ts
// src/config/env.ts
const ALLOWED_ORIGINS = [
  'http://localhost:*',  // any port (Swagger UI from any dev port)
  'https://dateandtime.live',
  'https://dateandtime-live.pages.dev',
  'https://dt-api-v2-dev.nsura2029.workers.dev',
  'https://dt-api-v2.nsura2029.workers.dev',
];

export function isOriginAllowed(origin: string): boolean {
  return ALLOWED_ORIGINS.some(allowed => {
    if (allowed.endsWith(':*')) {
      const prefix = allowed.slice(0, -2);
      return origin.startsWith(prefix);
    }
    return origin === allowed;
  });
}
```

## OpenAPI server URL auto-detect

The first server in the OpenAPI spec should be the current origin (for Swagger UI to
work locally AND on dev Worker AND on prod):

```ts
// src/routes/docs.ts
app.get('/openapi.json', (c) => {
  const url = new URL(c.req.url);
  const origin = `${url.protocol}//${url.host}`;
  return c.json({
    openapi: '3.1.0',
    info: { title: 'dateandtime-api-v2', version: '0.1.0' },
    servers: [{ url: origin, description: 'Current deployment' }],
    paths: { ... },
  });
});
```

## Test patterns

See `tests/AGENTS.md`. For source code changes, ALWAYS add or update tests.

## Commit format

```
feat(route): add GET /api/v1/cities?country=US&limit=10
fix(dao): handle null state_id in city lookups
docs(openapi): add example response for /api/v1/countries
refactor(middleware): extract CORS into shared util
test(cities): cover empty result, single match, pagination
```

Format: `<type>(<scope>): <subject>`. Types: feat, fix, docs, refactor, test, chore.

## Common gotchas

- **No `process.env`** — use `c.env` (Hono context) or `env` (Worker bindings).
- **No `fs` / `path`** — Workers don't have a filesystem. Use KV for storage.
- **No `console.error` in expected paths** — use `console.log` for tail logs, and only
  log actual errors. Otherwise the tail log fills with noise.
- **Zod `.optional()` vs `.nullable()`** — Optional = can be undefined, nullable = can be null.
  Match the DB column's NOT NULL/NULL constraint.
- **D1 `prepare().bind()`** — the `?` placeholders must match the `bind()` order. Mismatch
  → SQLITE_ERROR (no line number).
- **Hono context types** — extend `Hono<{ Bindings: { DB: D1Database; ... } }>` so `c.env.DB`
  is typed.

## Adding a new route (checklist)

1. Create file in `src/routes/`
2. Use OpenAPIHono + createRoute for full Swagger metadata
3. Add Zod schemas in `src/lib/schemas.ts`
4. Add types in `src/lib/types.ts`
5. Add DAO methods in `src/lib/db.ts` (if needed)
6. Mount in `src/index.ts`
7. Add tests in `tests/`
8. Run all 5 checks: `npm run check-all`
9. Commit on `feature/<route-name>` branch
10. Push, ask user to verify
11. After `lgtm`, merge to develop, delete branch
