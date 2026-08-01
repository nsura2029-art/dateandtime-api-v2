# src/config/ — env validation, configuration

## Purpose

Parse and validate environment variables at the top of the call chain. Fail fast on misconfiguration.

## Ownership

| File | Owns |
|---|---|
| `env.ts` | Zod schema for `c.env`, `loadEnv()` function, `isOriginAllowed()` |
| `cors.ts` | `getCorsHeaders()`, `handleCorsPreflight()` |

## Local Contracts

### env.ts

Exports a `loadEnv(raw: RawEnv): ValidatedEnv` function that:
1. Parses the raw env (from `c.env`) through a Zod schema.
2. Throws `ZodError` if any required var is missing or malformed.
3. Returns a `ValidatedEnv` with parsed + typed values + derived data (e.g. `allowedOrigins: string[]`).

```ts
const env = loadEnv(c.env);
console.log(env.API_NAME);  // string, guaranteed non-empty
```

### c.ts

`getCorsHeaders(request, env)` returns a `Headers` object with the right CORS headers (or empty if origin not allowed).

`handleCorsPreflight(request, env)` handles `OPTIONS` preflight requests. Returns `null` for non-OPTIONS.

## Work Guidance

### Adding a new env var

1. Add to `wrangler.toml` `[vars]` (and `[env.dev.vars]` for dev).
2. Add to the Zod schema in `env.ts`.
3. Add to the `Env` interface in `src/types/env.d.ts` (for raw access).
4. If it's a secret, add to `wrangler.toml` comments and use `wrangler secret put NAME`.
5. Re-run `npm run typecheck` — TypeScript will catch any handlers that miss the new var.

### Adding a new CORS origin

Edit `ALLOWED_ORIGINS` in `wrangler.toml` (comma-separated). No code change needed.

## Verification

```bash
npm run typecheck
```

## Child DOX Index

No children.
