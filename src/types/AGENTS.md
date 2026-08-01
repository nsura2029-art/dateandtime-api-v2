# src/types/ — Cloudflare bindings, shared types

## Purpose

Type declarations for Cloudflare Worker bindings (D1, KV, env vars) and any types shared across multiple modules that don't fit in `lib/types.ts`.

## Ownership

| File | Owns |
|---|---|
| `env.d.ts` | `Env` interface (Cloudflare bindings), `Variables` type (Hono context vars) |

`lib/types.ts` owns the D1 row types (City, Country, etc.). This directory is for **framework** types only.

## Local Contracts

### `Env` interface

Maps 1:1 with the bindings declared in `wrangler.toml`. Add a field here whenever you add a binding (D1, KV, R2, queue, etc.) to `wrangler.toml`.

```ts
export interface Env {
  DB: D1Database;                              // from [[d1_databases]]
  CACHE?: KVNamespace;                          // from [[kv_namespaces]]
  API_VERSION: string;                          // from [vars]
  ADMIN_API_KEY?: string;                      // from `wrangler secret put`
}
```

### `Variables` type

Lists the keys that middleware can set on the Hono context via `c.set()`. Add a field here whenever a middleware adds a new context variable.

```ts
export type Variables = {
  requestId: string;
  startTime: number;
};
```

## Work Guidance

### Adding a new binding

1. Add the binding to `wrangler.toml` (e.g. `[[r2_buckets]]`).
2. Add the corresponding field to `Env` in `env.d.ts`.
3. TypeScript will enforce usage in handlers.

### Adding a new context variable

1. Add the field to `Variables` in `env.d.ts`.
2. Set it in the middleware via `c.set("key", value)`.
3. Read it in handlers via `c.get("key")`.

## Verification

```bash
npm run typecheck  # will fail if wrangler.toml and env.d.ts are out of sync (eventually)
```

## Child DOX Index

No children.
