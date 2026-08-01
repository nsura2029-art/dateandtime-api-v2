# Troubleshooting

> Common issues + concrete fixes. If your error isn't here, check [`setup.md`](./setup.md) or open an issue.

## Node version

### `Wrangler requires at least Node.js v22.0.0. You are using v20.x.x.`

**Cause:** You're on Node 20, but wrangler 3.114+ needs Node 22+.

**Fix:**
```bash
# Option A: nvm (recommended — multiple Node versions side by side)
nvm install 22
nvm use 22
nvm alias default 22  # make 22 the default

# Option B: Download Node 22+ from nodejs.org
# https://nodejs.org/en/download

# Option C: Docker (if you don't want to change local Node)
npm run dev:docker
# The container runs Node 22 regardless of your host version

# Verify
node --version
# Should print v22.x or higher
```

---

## npm install / lock file

### `npm error EUSAGE: ... can only install with an existing package-lock.json`

**Cause:** Your branch doesn't have `package-lock.json` (or you deleted it).

**Fix:**
```bash
# If you deleted it locally, restore from git:
git checkout -- package-lock.json

# If the branch is missing it (older branch), pull develop first:
git checkout develop
git pull
# Then create your branch off develop:
git checkout -b feature/your-thing
```

### `npm error EUSAGE: package.json and package-lock.json out of sync`

**Cause:** Someone added/removed a dependency without committing the lock file.

**Fix:**
```bash
# 1. Run npm install to update the lock file
npm install

# 2. Verify package.json + package-lock.json are now in sync
npm ci --dry-run
# Should print "added X packages" with no errors

# 3. Commit the updated lock file
git add package-lock.json
git commit -m "chore: update package-lock.json"
```

### `Cannot find module '@hono/zod-openapi'` (or any other dep)

**Cause:** Lock file drift or partial install.

**Fix:**
```bash
rm -rf node_modules
npm ci
```

---

## Dev server

### `Unknown argument: persist`

**Cause:** Old wrangler version. The `--persist` flag was removed in 3.x.

**Fix:**
```bash
npm install wrangler@latest
# or just:
npm ci  # uses the lock file's pinned version
```

### Dev server starts but immediately exits

**Cause:** Usually port 8787 already in use, or wrangler error.

**Fix:**
```bash
# Check if port 8787 is in use:
# macOS / Linux:
lsof -iTCP:8787 -sTCP:LISTEN
# Windows:
netstat -ano | findstr :8787

# If something is there, kill it:
# macOS / Linux:
kill -9 <PID>
# Windows:
taskkill /F /PID <PID>

# If nothing is there, check the wrangler output for the actual error
```

### `Failed to fetch. URL scheme must be "http" or "https" for CORS request` (in Swagger UI)

**Cause:** The dev server isn't running, or you opened the docs page from `file://`.

**Fix:**
```bash
# 1. Make sure the dev server is running
npm run dev
# Look for: "Starting local server on http://localhost:8787"

# 2. Open the page at the EXACT URL
#    http://localhost:8787/docs
#    NOT file:///C:/dev/dt-live/.../docs.html
#    NOT 127.0.0.1 (use localhost)
```

---

## Docker

### `Wrangler requires at least Node.js v22.0.0` (inside container)

**Cause:** Your image was built from an old Dockerfile (Node 20) or cached layer.

**Fix:**
```bash
# Force rebuild with no cache
docker compose -f docker/docker-compose.yml --profile local build --no-cache

# Or delete the image manually and retry
docker rmi dt-api-v2-api
npm run dev:docker
```

### `exited with code 1 (restarting)` (looping)

**Cause:** Missing env vars, bad token, or build failure.

**Fix:**
```bash
# View the actual error:
docker compose -f docker/docker-compose.yml logs -f

# Common fixes:
# - Set CLOUDFLARE_API_TOKEN + CLOUDFLARE_ACCOUNT_ID on the HOST (not just in the container)
# - Make sure token is valid: npx wrangler whoami
# - For local D1 (no token needed), use the 'local' profile:
npm run dev:docker   # local profile
# not:
npm run dev:docker:remote   # remote profile (needs token)
```

### `port 8787 already in use` from container

**Cause:** Another process (or a previous container) has port 8787.

**Fix:**
```bash
# Find what's on 8787:
# macOS/Linux:
lsof -iTCP:8787 -sTCP:LISTEN
# Windows:
netstat -ano | findstr :8787

# Stop the conflicting process, or change the port:
# In wrangler.toml, change `port = 8787` to `port = 8788` (and update docker-compose port mapping)
```

### Container can't reach Cloudflare (remote D1 mode)

**Cause:** Token not passed from host to container, or wrong token.

**Fix:**
```bash
# 1. Confirm token is set on the host:
echo $CLOUDFLARE_API_TOKEN  # should print the token (first 10 chars at least)

# 2. Restart Docker with the env var in scope:
export CLOUDFLARE_API_TOKEN="..."
export CLOUDFLARE_ACCOUNT_ID="..."
npm run dev:docker:remote

# 3. Verify inside the container:
docker exec -it dt-api-v2-dev-remote sh
# In the container:
echo $CLOUDFLARE_API_TOKEN
npx wrangler whoami
```

### `Cannot connect to the Docker daemon`

**Cause:** Docker Desktop not running.

**Fix:** Start Docker Desktop, wait for the whale icon to be steady, retry.

---

## Cloudflare auth

### `CLOUDFLARE_API_TOKEN env var is required for remote mode`

**Cause:** Token not set in current shell.

**Fix:** See [setup.md §6](./setup.md#6-set-env-vars).

### `wrangler whoami` errors with "Authentication error [code: 10000]"

**Cause:** Token is invalid, expired, or revoked.

**Fix:**
1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Find your token, click the 3-dot menu
3. If the token was rolled (regenerated), copy the new value
4. If it was deleted, create a new one with the "Edit Cloudflare Workers" template
5. Update your env var (in the current shell, and in your persistent file like `~/.bashrc`)

### `wrangler whoami` succeeds but the deploy fails with "Authentication error"

**Cause:** Token has the wrong scopes, or doesn't have access to the specific resource.

**Fix:**
- Re-create the token with **"Edit Cloudflare Workers"** template (don't use custom — the template has the right scopes)
- Make sure "Account Resources" includes your account
- Make sure "Zone Resources" includes the zone you're deploying to (or "All zones")

---

## Migrations + D1

### `d1 execute` fails with "no such table: cities"

**Cause:** Schema not applied to the D1 database.

**Fix:**
```bash
# For local D1:
npx wrangler d1 execute timeandtimepro-full --local --file=migrations/000_initial.sql

# For remote D1 (needs token):
npx wrangler d1 execute timeandtimepro-full --env dev --file=migrations/000_initial.sql
```

### `INSERT` fails with "too many SQL variables"

**Cause:** SQLite/D1 has a limit on the number of parameters per statement.

**Fix:** Batch the insert. For example, in a seed script:
```python
BATCH_SIZE = 9  # for 11-col tables
for i in range(0, len(rows), BATCH_SIZE):
    batch = rows[i:i+BATCH_SIZE]
    db.execute("INSERT INTO ... VALUES (?, ?, ..., ?)", batch)
```

---

## Other

### `git checkout develop` fails with "Your local changes would be overwritten"

**Cause:** You have uncommitted changes (often from a previous `npm install`).

**Fix:**
```powershell
# Option A: Stash them
git stash push -m "before-checkout"
git checkout develop
git stash pop  # if you need them later

# Option B: Discard them (safe if they're just npm-regenerated files)
git checkout -- package.json package-lock.json
git checkout develop

# Option C: Nuclear option (always works)
git stash push -u
git checkout develop
```

### Smoke test fails with "Server not reachable"

This is **expected** when no dev server is running. The smoke test now skips gracefully (since `feature/verify-and-run-script` shipped the fix). If you want to actually run the smoke test, start the dev server in another terminal first.

### Swagger UI shows "Undocumented" with no other error

**Cause:** The spec fetch failed silently. The newer docs page (after `feature/complete-swagger-ui` merged) shows a clear error message in the page. If you still see this, check the browser DevTools console (F12) for the actual error.
