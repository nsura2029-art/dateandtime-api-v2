# Known Issues — dateandtime-api-v2

Tracked here until fixed. Each issue has a clear repro, root cause (when known), and a proposed fix.

---

## [BUG-1] Swagger UI "Try it out" shows CORS error in browser even after dev Worker is deployed

**Status:** Open
**Severity:** Medium (dev-only — prod direct-URL works fine)
**First reported:** 2026-07-31
**Branch where it was worked around:** `feature/verify-and-run-script` (merged)

### Repro
1. Run `npm run dev` locally → server on `http://localhost:8787`
2. Open `http://localhost:8787/docs` in Chrome
3. Click "Try it out" on any endpoint
4. Browser DevTools Network tab shows the request went to `https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/status` (or `https://dt-api-v2.nsura2029.workers.dev`)
5. Server returns 200 OK
6. **But** Swagger UI still shows "Failed to fetch" / "Undocumented"

### What's NOT broken
- Direct `curl https://dt-api-v2-dev.nsura2029.workers.dev/api/v1/status` returns 200 with full data (33,945 cities, 242 countries, 408 timezones)
- `https://dt-api-v2-dev.nsura2029.workers.dev/docs` opened directly in browser works (no CORS error)
- The CORS fix (`http://localhost:*` port wildcard) IS in the code AND in `wrangler.toml`

### What's still broken
- Cross-origin request from `http://localhost:8787` (where Swagger UI is served) to `https://dt-api-v2-dev.nsura2029.workers.dev` (where Swagger UI tries to call) is blocked by the browser even with `Access-Control-Allow-Origin: http://localhost:8787` set.

### Root cause (suspected)
The `wrangler dev` local server seems to be proxying through to the deployed Worker rather than serving locally. So:
- The page origin is `http://localhost:8787`
- The request target is `https://dt-api-v2-dev.nsura2029.workers.dev`
- The Worker returns the right CORS header for the request origin
- BUT something in the wrangler dev proxy chain is dropping or rewriting the CORS header before it reaches the browser

This needs a direct investigation with DevTools showing the **actual** response headers from the Worker's URL (not the localhost URL).

### Proposed fix (one of these)
1. **Investigate wrangler dev proxy behavior** — does `--remote` mode rewrite response headers?
2. **Don't use `wrangler dev --remote` for Swagger UI testing** — instead, use a separately-deployed Worker and test against the deployed URL directly
3. **Pin Swagger UI server to the same origin as the docs page** — add a UI toggle so "Try it out" always uses the page's origin (no cross-origin at all)

### Workaround (right now)
Test the API with `curl` or visit `https://dt-api-v2-dev.nsura2029.workers.dev/docs` directly in the browser. The Swagger UI loads and "Try it out" works there (same-origin, no CORS issue).

---

## [BUG-2] 503 on /api/v1/status when using `npm run dev` (no --remote)

**Status:** By design (not a bug — but worth documenting)
**Severity:** Low (expected behavior for local-only mode)

### Repro
1. Run `npm run dev` (no `--remote`)
2. `curl http://localhost:8787/api/v1/status`
3. Returns 503 with `D1_ERROR: no such table: cities`

### Cause
`wrangler dev` without `--remote` creates a fresh local SQLite file with NO schema. The D1 tables don't exist, so any query fails.

### Fix
Use `npm run dev:remote` (talks to real Cloudflare D1, has all 33,945 cities) OR apply migrations to local D1 first.

---

## How to add a new known issue

```markdown
## [BUG-N] Short title

**Status:** Open / In Progress / Resolved
**Severity:** Critical / High / Medium / Low
**First reported:** YYYY-MM-DD

### Repro
1. Step-by-step how to trigger

### What's NOT broken
- Related stuff that works

### What's still broken
- The actual bug

### Root cause
- When known

### Proposed fix
- One option per line
```
