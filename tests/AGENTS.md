# tests/AGENTS.md

> Conventions for tests. Read this BEFORE writing any new test file.
> Sub-context of root AGENTS.md.

## Test framework

- **Vitest 2.1+** — `vitest run` (CI) or `vitest watch` (dev)
- **In-process app testing** — no real server, no real D1
- **Hono `app.request()`** — call routes as if they were HTTP requests

## Directory structure

```
tests/
├── AGENTS.md                  ← (this file)
├── setup.ts                   ← Vitest config (alias, env, mocks)
├── helpers/
│   ├── create-test-app.ts     ← Build a fresh app instance for each test
│   ├── create-mock-db.ts      ← In-memory D1 mock (or fixture)
│   └── fixtures.ts            ← Pre-populated test data
├── unit/
│   ├── daos/
│   │   ├── cities.test.ts
│   │   └── countries.test.ts
│   ├── formatters/
│   └── validators/
├── integration/
│   ├── health.test.ts
│   ├── status.test.ts
│   └── routes/
│       ├── cities.test.ts
│       └── countries.test.ts
└── e2e/                       ← (planned) Playwright for full app
```

## In-process D1 mock

D1 doesn't run locally, so we mock the binding for tests:

```ts
// tests/helpers/create-mock-db.ts
import { vi } from 'vitest';

export function createMockDb(overrides: Partial<D1Database> = {}): D1Database {
  return {
    prepare: vi.fn().mockReturnValue({
      bind: vi.fn().mockReturnThis(),
      all: vi.fn().mockResolvedValue({ results: [], success: true, meta: {} }),
      first: vi.fn().mockResolvedValue(null),
      run: vi.fn().mockResolvedValue({ success: true, meta: { changes: 0 } }),
    }),
    dump: vi.fn().mockResolvedValue(new ArrayBuffer(0)),
    batch: vi.fn().mockResolvedValue([]),
    exec: vi.fn().mockResolvedValue({ count: 0, duration: 0 }),
    ...overrides,
  } as unknown as D1Database;
}
```

For tests that need real SQL behavior, use `better-sqlite3` in-memory DB and shim D1 API.

## In-process Hono test

```ts
// tests/integration/health.test.ts
import { describe, it, expect } from 'vitest';
import { app } from '../../src/index';
import { createMockDb } from '../helpers/create-mock-db';

describe('GET /api/v1/health', () => {
  it('returns 200 with DB stats', async () => {
    const env = { DB: createMockDb() };
    const res = await app.request('/api/v1/health', { method: 'GET' }, env);
    expect(res.status).toBe(200);
    const body = await res.json();
    expect(body).toHaveProperty('database');
    expect(body.database).toHaveProperty('regions');
  });

  it('returns 503 when DB is unavailable', async () => {
    const env = { DB: createMockDb({ prepare: () => { throw new Error('DB unavailable'); } }) };
    const res = await app.request('/api/v1/health', { method: 'GET' }, env);
    expect(res.status).toBe(503);
  });

  it('HEAD returns 200 with no body', async () => {
    const env = { DB: createMockDb() };
    const res = await app.request('/api/v1/health', { method: 'HEAD' }, env);
    expect(res.status).toBe(200);
    const text = await res.text();
    expect(text).toBe('');
  });
});
```

## Edge case coverage (binding)

Every endpoint MUST cover:
1. **Happy path** — typical valid request
2. **Boundary** — empty result, max limit, exact match
3. **Invalid input** — bad query params, missing required fields
4. **Not found** — valid request, no matching data
5. **Auth (if applicable)** — missing/invalid token
6. **Error path** — DB unavailable, internal error

Example:

```ts
describe('GET /api/v1/cities', () => {
  it('returns 200 with paginated cities (happy path)', ...);
  it('returns empty array when no matches (boundary)', ...);
  it('returns 400 for invalid country code (invalid input)', ...);
  it('returns 400 for negative limit (invalid input)', ...);
  it('defaults limit=50 when not specified (default)', ...);
  it('filters by country=US correctly (filter)', ...);
  it('returns 503 when DB unavailable (error path)', ...);
});
```

## Coverage targets

- **Unit tests:** 100% for pure functions (DAOs, formatters, validators)
- **Integration tests:** Every endpoint has at least 1 test
- **Edge cases:** Every endpoint covers all 6 categories above

## Vitest config

```ts
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./tests/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'json'],
      include: ['src/**/*.ts'],
      exclude: ['src/**/*.test.ts', 'src/index.ts'],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 75,
        statements: 80,
      },
    },
  },
});
```

## Mocking Cloudflare APIs

For tests that need to mock KV, R2, etc.:

```ts
import { vi } from 'vitest';

const mockKV = {
  get: vi.fn().mockResolvedValue('mock-value'),
  put: vi.fn().mockResolvedValue(undefined),
  delete: vi.fn().mockResolvedValue(undefined),
  list: vi.fn().mockResolvedValue({ keys: [], list_complete: true }),
};
```

## Smoke test (npm run smoke)

A separate `tests/smoke.test.ts` that runs against the live dev Worker:

```ts
import { describe, it, expect } from 'vitest';

const BASE_URL = process.env.SMOKE_URL || 'http://localhost:8787';

describe.skipIf(!process.env.SMOKE_URL)('smoke', () => {
  it('health endpoint responds', async () => {
    const res = await fetch(`${BASE_URL}/api/v1/health`);
    expect(res.status).toBe(200);
  });
});
```

`describe.skipIf` lets the test skip cleanly when no server is available (matches
`npm run dev:remote` for local dev).

## Running tests

```bash
npm test              # vitest run
npm run test:watch    # vitest watch
npm run test:cov      # vitest run --coverage
npm run smoke         # vitest run tests/smoke.test.ts
```

## Common gotchas

- **Test isolation** — each test should create its own app/DB instance. Use `beforeEach`.
- **Async cleanup** — call `await app.close()` if your app holds resources.
- **Floating promises** — Vitest doesn't warn about them by default. Use `no-floating-promises` ESLint rule.
- **Hono context** — when testing middleware, the `c.env` is whatever you pass as the 3rd
  arg to `app.request()`. Don't rely on process.env.
- **Time-dependent tests** — use `vi.useFakeTimers()` for tests that depend on `Date.now()`.

## Adding a new test (checklist)

1. Identify the test type: unit (pure function), integration (route + DB), e2e (full app)
2. Add to the right directory: `tests/unit/`, `tests/integration/`, or `tests/e2e/`
3. Cover all 6 edge cases (happy, boundary, invalid, not-found, auth, error)
4. Use `createMockDb()` for DB-bound tests
5. Use `app.request()` for HTTP testing (no real server)
6. Run `npm run test:cov` to check coverage stays > 80%
7. Commit on the same `feature/*` branch as the code change
