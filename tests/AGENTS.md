# tests/ — Vitest tests

## Purpose

Integration tests for the API. Run against a live server (`npm run dev` or remote).

## Ownership

| File | Owns |
|---|---|
| `<resource>.test.ts` | Integration tests for a resource's endpoints |

Future: `unit/` for unit tests (no server), `e2e/` for end-to-end (full D1 + Cloudflare).

## Local Contracts

### Integration test pattern

Tests run against `http://localhost:8787` by default, or `$API_URL` if set. Each test file:

1. Checks if the server is reachable in `beforeAll`.
2. If not reachable, **skips** the tests with a warning (so CI can run without a server).
3. Otherwise, makes real HTTP requests and asserts on the response.

```ts
import { describe, it, expect, beforeAll } from "vitest";

const BASE_URL = process.env.API_URL ?? "http://localhost:8787";

async function isServerUp(url: string): Promise<boolean> {
  try {
    const r = await fetch(url, { signal: AbortSignal.timeout(1000) });
    return r.status < 500;
  } catch {
    return false;
  }
}

describe("cities (integration)", () => {
  let serverUp = false;

  beforeAll(async () => {
    serverUp = await isServerUp(BASE_URL);
    if (!serverUp) {
      console.warn(`⚠️  Server not reachable at ${BASE_URL} — tests will skip.`);
    }
  });

  it("GET /api/v1/cities returns paginated list", async () => {
    if (!serverUp) return;
    const r = await fetch(`${BASE_URL}/api/v1/cities?limit=2`);
    expect(r.status).toBe(200);
    const body = await r.json();
    expect(body.success).toBe(true);
    expect(body.data.items.length).toBe(2);
    expect(body.data.pagination.total).toBeGreaterThan(0);
  });
});
```

### Test categories

| Category | Purpose | Server needed? |
|---|---|---|
| Integration (this dir) | Test the full HTTP stack + real D1 | Yes (skips if not) |
| Unit (future `unit/`) | Test pure functions in `src/lib/` | No |
| E2E (future `e2e/`) | Test deploy flows | Yes (deployed) |

## Work Guidance

### Adding tests for a new resource

1. Create `tests/<resource>.test.ts`.
2. Mirror the resource's routes (one test per endpoint).
3. Cover happy path + at least one error case (400, 404).
4. Use `isServerUp` so tests skip if no server.

### Adding a test that needs the remote D1

Set `API_URL=https://api-v2.dateandtime.live npm test`. Tests will run against the deployed API instead of local.

## Verification

```bash
npm test                # runs all tests, skips if no server
npm test -- tests/cities.test.ts  # run a specific file
```

## Child DOX Index

No children.
