# Setup Guide

> Complete setup for local dev + Cloudflare deployment. Windows, macOS, Linux.

## Table of contents

1. [Prerequisites](#1-prerequisites)
2. [Clone the repo](#2-clone-the-repo)
3. [Local dev (no Docker)](#3-local-dev-no-docker)
4. [Local dev (Docker)](#4-local-dev-docker)
5. [Cloudflare credentials](#5-cloudflare-credentials)
6. [Set env vars](#6-set-env-vars)
7. [Verify the setup](#7-verify-the-setup)
8. [Common issues](#8-common-issues)

---

## 1. Prerequisites

| Tool | Version | Install |
|---|---|---|
| **Node.js** | 22.0.0+ | [nodejs.org](https://nodejs.org/) or `nvm install 22` |
| **npm** | 10+ | comes with Node 22 |
| **Git** | 2.30+ | [git-scm.com](https://git-scm.com/) |
| **Docker Desktop** (optional) | latest | [docker.com](https://www.docker.com/products/docker-desktop) |

Verify with:
```bash
node --version    # should be v22.x or higher
npm --version     # should be 10.x or higher
git --version     # should be 2.30 or higher
docker --version  # should be 24+ if using Docker
```

### Windows users

You'll likely use **Git Bash** (MINGW64) which is installed with Git for Windows. The commands in this guide are bash-compatible. If you prefer PowerShell, the same commands work with one change: replace `export NAME=value` with `$env:NAME="value"`.

---

## 2. Clone the repo

```bash
# Clone
cd /c/dev/dt-live  # or your projects dir
git clone https://github.com/nsura2029-art/dateandtime-api-v2.git
cd dateandtime-api-v2

# Switch to develop (the integration branch)
git checkout develop

# Install deps from lock file
npm ci
```

**Why `npm ci` instead of `npm install`?**
- Uses the exact versions in `package-lock.json` (reproducible)
- Faster (skips dependency resolution)
- Doesn't modify `package.json` (no drift)

---

## 3. Local dev (no Docker)

The fastest way to get going. No Docker, no Cloudflare account needed.

```bash
# Start the dev server with local SQLite D1
npm run dev
```

Output:
```
> wrangler dev --port 8787
⛅️ wrangler 3.114.17
Starting local server on http://localhost:8787
Compiled successfully.
```

The local D1 starts EMPTY (no cities, no holidays). To get realistic data, see [§5. Cloudflare credentials](#5-cloudflare-credentials) and use `npm run dev:remote` instead.

### Verify

In another terminal:
```bash
curl http://localhost:8787/
curl http://localhost:8787/api/v1/health
# Should return: {"success":true,"data":{"status":"ok","db":{"cities":0,...}}}

# Open Swagger UI in your browser:
# http://localhost:8787/docs
```

---

## 4. Local dev (Docker)

Docker gives you a consistent environment across machines. The container is Node 22 + wrangler + your code, all wired up.

### Local D1 (no token needed)

```bash
# Build and start
npm run dev:docker
# OR (verbose):
docker compose -f docker/docker-compose.yml --profile local up --build
```

### Remote D1 (needs Cloudflare token)

```bash
# 1. Set env vars (see §5 and §6):
export CLOUDFLARE_API_TOKEN="your-token-here"
export CLOUDFLARE_ACCOUNT_ID="your-account-id-here"

# 2. Start with remote D1:
npm run dev:docker:remote
# OR:
docker compose -f docker/docker-compose.yml --profile remote up --build
```

The container reads the env vars from the host, passes them to wrangler, which uses them to talk to the deployed Worker's D1.

### Verify (Docker)

```bash
# In another terminal (after container starts):
curl http://localhost:8787/api/v1/health
# Should return real data: {"data":{"db":{"cities":33945,...}}}

# View container logs:
docker compose -f docker/docker-compose.yml logs -f

# Stop the container:
# Press Ctrl+C in the terminal running docker compose, or:
docker compose -f docker/docker-compose.yml down
```

### Profile matrix

| Profile | D1 source | Cloudflare token needed? | Real data? |
|---|---|---|---|
| `local` (default) | Local SQLite at `.wrangler/state/v3/d1/` | No | No (empty by default) |
| `remote` | Deployed Worker (`dt-api-v2-dev` or similar) | Yes | Yes (33,945 cities) |

### Common Docker issues

| Error | Fix |
|---|---|
| `Wrangler requires at least Node.js v22.0.0` | Pull latest image: `docker compose --profile local build --no-cache` |
| `port 8787 already in use` | Stop the other process: `lsof -iTCP:8787 -sTCP:LISTEN` (macOS/Linux) or `netstat -ano \| findstr :8787` (Windows) |
| `exited with code 1 (restarting)` | Check `docker compose logs`. Usually wrong env vars or Node version mismatch. |
| Container can't reach Cloudflare | Check `CLOUDFLARE_API_TOKEN` is set on the host before starting Docker. |
| `Cannot connect to the Docker daemon` | Start Docker Desktop. |

---

## 5. Cloudflare credentials

You need TWO things to deploy or use remote D1:
1. **API Token** (auth)
2. **Account ID** (scope)

### 5.1 Create the API Token

1. Go to https://dash.cloudflare.com/profile/api-tokens
2. Click **"Create Token"**
3. Under **"API token templates"**, click **"Use template"** next to **"Edit Cloudflare Workers"**

   This template auto-includes:
   - ✅ Workers Scripts:Edit (deploy Workers)
   - ✅ Workers KV Storage:Edit (read/write KV)
   - ✅ Workers R2 Storage:Edit (read/write R2)
   - ✅ Workers Tail:Read (read logs)
   - ✅ D1:Edit (read/write D1) ← we need this
   - ✅ Account Settings:Read

4. Under **"Permissions"** (auto-filled by template, don't change):
   - Account → Workers Scripts:Edit
   - Account → Workers KV Storage:Edit
   - Account → Workers R2 Storage:Edit
   - Account → Workers Tail:Read
   - Account → D1:Edit
   - Account → Account Settings:Read

5. Under **"Account Resources"**:
   - Include → `<your-account-name>` (e.g. `nsura2029-art`)

6. Under **"Zone Resources"**:
   - Include → All zones (or specific zones like `dateandtime.live`)

7. (Optional) Under **"TTL"**:
   - Start date: now
   - End date: 1 day, 1 week, 1 month, or "Never" (your choice — shorter is more secure)

8. Click **"Continue to summary"** → **"Create Token"**

9. **COPY THE TOKEN NOW** — you won't see it again. Format: `cfut_qa0Z...` (32+ chars)

10. ⚠️ **Never share this token in chat, screenshots, or commit it to git.** If you accidentally expose it, go back to the tokens page and "Roll" (regenerate) or "Delete" it immediately.

### 5.2 Find your Account ID

The Account ID is shown in several places:

**Option A: `wrangler whoami` (no browser needed)**
```bash
export CLOUDFLARE_API_TOKEN="your-token-here"
npx wrangler whoami
```
Output:
```
👋  You are logged in with an API Token, associated with the account "nsura2029-art".
📎  Account ID: a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6
```

**Option B: Dashboard sidebar**
1. Go to https://dash.cloudflare.com
2. Look at the right sidebar (or bottom-right corner)
3. You'll see "Account ID" with a copy button

**Option C: Workers & Pages page**
1. Go to https://dash.cloudflare.com → **Workers & Pages** (left sidebar)
2. Right sidebar → **"Account ID"** section
3. Click the copy icon

The Account ID is a 32-character hex string like `a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6`.

---

## 6. Set env vars

Pick ONE method for your shell. The env vars only persist in the current shell session (so set them every time you open a new terminal, or use the persistent method).

### Git Bash (MINGW64) — recommended for Windows

**Per-session (current terminal only):**
```bash
export CLOUDFLARE_API_TOKEN="your-NEW-token-here"
export CLOUDFLARE_ACCOUNT_ID="your-account-id-here"
```

**Persistent (every new terminal):**
Add to `~/.bashrc` or `~/.bash_profile`:
```bash
echo 'export CLOUDFLARE_API_TOKEN="your-NEW-token-here"' >> ~/.bashrc
echo 'export CLOUDFLARE_ACCOUNT_ID="your-account-id-here"' >> ~/.bashrc
source ~/.bashrc
```

### PowerShell

**Per-session:**
```powershell
$env:CLOUDFLARE_API_TOKEN = "your-NEW-token-here"
$env:CLOUDFLARE_ACCOUNT_ID = "your-account-id-here"
```

**Persistent:**
```powershell
[System.Environment]::SetEnvironmentVariable("CLOUDFLARE_API_TOKEN", "your-NEW-token-here", "User")
[System.Environment]::SetEnvironmentVariable("CLOUDFLARE_ACCOUNT_ID", "your-account-id-here", "User")
# Restart your terminal
```

### CMD

**Per-session:**
```cmd
set CLOUDFLARE_API_TOKEN=your-NEW-token-here
set CLOUDFLARE_ACCOUNT_ID=your-account-id-here
```

**Persistent:**
1. Win+R → `sysdm.cpl` → Advanced → Environment Variables
2. Add the two vars under "User variables"

### Verify the env vars are set

```bash
# Git Bash
echo "Token: ${CLOUDFLARE_API_TOKEN:0:10}..."
echo "Account: $CLOUDFLARE_ACCOUNT_ID"

# PowerShell
Write-Host "Token: $($env:CLOUDFLARE_API_TOKEN.Substring(0, 10))..."
Write-Host "Account: $env:CLOUDFLARE_ACCOUNT_ID"
```

You should see the first 10 chars of the token (e.g. `cfut_qa0ZK...`) and the 32-char account ID. If both are empty, the env var wasn't set in the current shell.

---

## 7. Verify the setup

Run the all-in-one verification:
```bash
npm run verify:checks
```

Expected output (5 checks pass):
```
==> Pre-flight checks
  ✓ package.json found
  ✓ node_modules present
==> Automated checks
  ✓ typecheck (3s)
  ✓ lint (2s)
  ✓ vitest (2s)
  ✓ smoke (curl) — skipped (no server)
  ✓ readme sync (1s)
✓ 5 checks passed (in ~10s)
```

To run the smoke test too, start the dev server in another terminal first:
```bash
# Terminal 1
npm run dev

# Terminal 2
npm run verify:checks
# Now the smoke test will actually run:
#   ✓ smoke (curl) (5s)
```

Full verify (with Docker server):
```bash
npm run verify
# Runs all checks, then starts the server in Docker
# Press Ctrl+C to stop
```

### Manual verification

```bash
# Start the server
npm run dev
# or: npm run dev:remote  (real data)
# or: npm run dev:docker

# In another terminal:
curl http://localhost:8787/
curl http://localhost:8787/api/v1/health
curl http://localhost:8787/api/v1/status
curl http://localhost:8787/openapi.json | head -c 200

# Open in browser:
# http://localhost:8787/docs  ← Swagger UI
```

---

## 8. Common issues

| Error | Cause | Fix |
|---|---|---|
| `Wrangler requires at least Node.js v22.0.0` | Old Node version | Update Node to 22+. `nvm install 22 && nvm use 22` |
| `npm error EUSAGE: ... can only install with package-lock.json` | Lock file missing on your branch | `git pull` and ensure you're on develop or a recent branch |
| `npm error EUSAGE: package.json and package-lock.json out of sync` | Someone ran `npm install` instead of `npm ci` | Run `npm install`, commit the lock, then continue |
| `Unknown argument: persist` | Old wrangler | `npm install wrangler@latest` (3.x removed `--persist`) |
| `Failed to fetch. URL scheme must be "http" or "https"` (in Swagger UI) | Dev server not running, or page loaded from `file://` | Start with `npm run dev` and open `http://localhost:8787/docs` (not `file://...`) |
| Docker: `exited with code 1` | Wrong Node version, bad env, or build failure | `docker compose logs`. See [`docs/troubleshooting.md`](./troubleshooting.md) for details |
| Docker: `port 8787 already in use` | Another process on the port | macOS/Linux: `lsof -iTCP:8787 -sTCP:LISTEN` then kill the PID. Windows: `netstat -ano \| findstr :8787` then `taskkill /F /PID <pid>` |
| `CLOUDFLARE_API_TOKEN env var is required` | Token not set | See §6. Set in current shell, then retry. |
| `wrangler whoami` shows wrong account | Old/wrong token | Regenerate at https://dash.cloudflare.com/profile/api-tokens, update env var, retry |
| `Authentication error [code: 10000]` | Token expired or revoked | Same as above — roll the token |
| `durable_object` or `r2` errors | You tried to use a binding not in `wrangler.toml` | Add the binding to `wrangler.toml` first |
| `Cannot find module '@hono/zod-openapi'` | Lock file drift | `rm -rf node_modules && npm ci` |

### Security

- **Never commit** the API token. It's in `.gitignore` (via `.dev.vars`) but if you accidentally echo it in a script, scrub it from history.
- **Rotate** the token periodically (every 90 days is a good baseline).
- **Scope** the token to the minimum needed (the "Edit Cloudflare Workers" template is a good default).
- **Use a separate token** for dev vs. CI vs. prod.

---

## What's next?

After the setup works:

- **Add an endpoint** — see [`docs/adding-endpoints.md`](./adding-endpoints.md) (TODO)
- **Deploy to dev** — `npm run deploy:dev`
- **Deploy to prod** — `npm run deploy:prod` (requires "ship it")
- **Open Swagger UI** — `http://localhost:8787/docs`

If you hit an issue not covered here, check [`docs/troubleshooting.md`](./troubleshooting.md) or open an issue.
