# src/ — source code

## Purpose

All TypeScript source code for the API Worker.

## Ownership

This directory owns the runtime code. Schema, tests, scripts, and CI live in sibling directories with their own AGENTS.md.

## Local Contracts

### Path alias

`@/*` maps to `src/*` (configured in `tsconfig.json`). Use `@/` imports for all cross-directory references, never `../../`.

```ts
// ✅ Good
import { success } from "@/lib/response";
import type { Env } from "@/types/env";

// ❌ Bad
import { success } from "../lib/response";
import type { Env } from "../../types/env";
```

### Module style

ESM only. `"type": "module"` in `package.json`. No `require()`, no CommonJS.

### Strict TypeScript

`tsconfig.json` has `strict: true`, `noUncheckedIndexedAccess: true`, `noImplicitOverride: true`. Fix type errors, don't suppress them.

### File naming

- `kebab-case.ts` for files (e.g. `error-handler.ts`)
- `PascalCase.ts` only for types files or class files
- Default export is the file's main export (Hono sub-app, helper group, etc.)

## Work Guidance

When adding a new feature, identify which subdirectory it belongs in:

| If you're adding... | Goes in... |
|---|---|
| A new REST endpoint / resource | `src/routes/<resource>.ts` |
| A D1 query helper | `src/lib/db.ts` |
| A response builder / utility | `src/lib/response.ts` or new `src/lib/<name>.ts` |
| A validation helper / Zod schema | `src/lib/validation.ts` or new `src/lib/<name>.ts` |
| A cross-cutting middleware | `src/middleware/<name>.ts` |
| Env parsing / CORS logic | `src/config/<name>.ts` |
| Cloudflare bindings | `src/types/env.d.ts` |
| A new row type | `src/lib/types.ts` |

If unsure, add to the closest existing file. Don't create new files for one-off helpers.

## Verification

```bash
npm run typecheck   # must be 0 errors
npm run lint        # must be 0 errors, 0 warnings
npm test            # tests pass (skips if no server)
```

## Child DOX Index

| Child | Owns |
|---|---|
| `routes/AGENTS.md` | HTTP route files (one per resource) |
| `lib/AGENTS.md` | DB helpers, validation, response, types |
| `middleware/AGENTS.md` | Cross-cutting middleware |
| `config/AGENTS.md` | Env validation, CORS config |
| `types/AGENTS.md` | Cloudflare bindings |
