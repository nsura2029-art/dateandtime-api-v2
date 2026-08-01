# scripts/ — CLI tools

## Purpose

Bash and TypeScript scripts for development, deployment, testing, and documentation.

## Ownership

| File | Owns |
|---|---|
| `test-endpoints.sh` | Smoke test 30+ endpoints (curl-based) |
| `extract-endpoints.ts` | Parse `src/routes/*.ts` → endpoint manifest |
| `sync-readme.sh` | Run `extract-endpoints.ts` + update `README.md` |
| `seed/*.py` | Python seed scripts (cities, holidays, etc.) |

## Local Contracts

### Bash scripts

- Start with `#!/usr/bin/env bash`.
- Use `set -uo pipefail` (not `-e` — we count failures manually).
- Print colored output (green=pass, red=fail, yellow=warn).
- Exit 0 on all-pass, 1 on any-fail.

### TypeScript scripts

- Run via `tsx` or `node --experimental-strip-types` (no build step).
- Use the same `@/` path alias as the Worker code.
- Output structured (JSON or markdown) for downstream tooling.

## Work Guidance

### Adding a new script

1. Add the file in this dir.
2. Add an `npm` script in `package.json` to invoke it.
3. Document what it does in this AGENTS.md (add a row to the table).
4. For bash scripts: `chmod +x scripts/<name>.sh` before committing.

### Updating test-endpoints.sh

Every time you add a new endpoint, add a `check` call:

```bash
check "Endpoint name" GET  "/api/v1/..."  200 "?param=value"
```

Use `400` for negative cases (bad params), `404` for not-found cases.

## Verification

```bash
bash scripts/test-endpoints.sh    # all 30+ checks pass
npm run sync:readme                # README.md updates
```

## Child DOX Index

| Child | Owns |
|---|---|
| `seed/AGENTS.md` | Python seed scripts (GeoNames, Nager.Date, Wikipedia) |
