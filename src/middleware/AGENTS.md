# src/middleware/ — cross-cutting middleware

## Purpose

Hono middleware that runs on every request (or a subset) and provides cross-cutting concerns: logging, error handling, CORS, rate limiting, auth, caching.

## Ownership

| File | Owns |
|---|---|
| `logger.ts` | Structured request/response/error logging |
| `error-handler.ts` | Catches thrown errors, returns 500; ZodError → 400 |
| `cors.ts` | (logic lives in `config/cors.ts`; this folder reserved for Hono-specific CORS middleware) |

Future: `auth.ts`, `rate-limit.ts`, `cache.ts`, `request-id.ts`.

## Local Contracts

### Middleware factory pattern

Every middleware exports a factory function that returns a `MiddlewareHandler`:

```ts
import type { MiddlewareHandler } from "hono";
import type { Env, Variables } from "@/types/env";

export const myMiddleware = (opts: {...}): MiddlewareHandler<{ Bindings: Env; Variables: Variables }> => {
  return async (c, next) => {
    // before
    await next();
    // after
  };
};
```

### Setting context variables

Use `c.set("key", value)` to make data available in route handlers. Always type the variable in `src/types/env.d.ts` under `Variables`:

```ts
export type Variables = {
  requestId: string;
  startTime: number;
  // add new keys here
};
```

### Throwing errors

Throw `Hono` HTTPException for known errors (caught by errorHandler):

```ts
import { HTTPException } from "hono/http-exception";
throw new HTTPException(404, { message: "Not found" });
```

Throw plain `Error` for unexpected errors. The `errorHandler` middleware catches both and returns 500.

## Work Guidance

### Adding a new middleware

1. Create `src/middleware/<name>.ts`.
2. Export a factory function that returns a `MiddlewareHandler<{ Bindings: Env; Variables: Variables }>`.
3. If it sets context variables, add them to `Variables` in `src/types/env.d.ts`.
4. Mount in `src/index.ts` with `app.use("*", <name>(opts))` (or with a path filter).
5. Order matters — error-handler goes first, then logger, then CORS preflight, then routes, then CORS response headers.

### Order of middleware (top to bottom in `src/index.ts`)

1. `errorHandler()` — catches all thrown errors, MUST be first
2. `logger()` — logs request/response, sets `requestId`
3. CORS preflight (`OPTIONS`) — must come before routes
4. Routes (`app.route("/", ...)`)
5. CORS response headers — applies to all responses

## Verification

```bash
npm run typecheck
npm run lint
npm test  # integration tests exercise the middleware chain
```

## Child DOX Index

No children.
