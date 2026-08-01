#!/usr/bin/env bash
# deploy.sh — Deploy the Worker to Cloudflare (dev or prod).
#
# Usage:
#   bash scripts/deploy.sh dev           # → dt-api-v2-dev
#   bash scripts/deploy.sh prod          # → dt-api-v2 (prod — REQUIRES "ship it")
#   bash scripts/deploy.sh dev --dry-run # → don't actually deploy, just build
#
# Requires:
#   CLOUDFLARE_API_TOKEN   — Cloudflare API token
#   CLOUDFLARE_ACCOUNT_ID  — Cloudflare account ID
#
# Exit codes:
#   0  — deploy succeeded
#   1  — bad env or missing token
#   2  — wrangler not installed
#   3  — build failed
#   4  — deploy failed (network, auth, etc.)
#   5  — prod deploy attempted without "ship it" (interactive prompt required)

set -uo pipefail

ENV="${1:-dev}"
DRY_RUN=0
if [ "${2:-}" = "--dry-run" ]; then DRY_RUN=1; fi

# Colors
if [ -t 1 ]; then
  GREEN='\033[0;32m'
  RED='\033[0;31m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

info() { echo -e "${BLUE}${BOLD}==>${NC} $1"; }
ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
fail() { echo -e "  ${RED}✗${NC} $1"; }
warn() { echo -e "  ${YELLOW}⚠${NC}  $1"; }

# Sanity checks
info "Pre-flight"
if ! command -v npx >/dev/null 2>&1; then
  fail "npx not found. Install Node.js 22+: https://nodejs.org/"
  exit 2
fi
ok "npx available"

if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
  fail "CLOUDFLARE_API_TOKEN env var not set."
  echo "    See README → 'First-time setup on Windows' for token creation."
  exit 1
fi
ok "CLOUDFLARE_API_TOKEN is set"

if [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
  fail "CLOUDFLARE_ACCOUNT_ID env var not set."
  echo "    Get it from: Cloudflare dashboard → Workers & Pages → right sidebar"
  exit 1
fi
ok "CLOUDFLARE_ACCOUNT_ID is set"

if ! npx wrangler --version >/dev/null 2>&1; then
  fail "wrangler not installed. Run: npm ci"
  exit 2
fi
WRANGLER_VERSION=$(npx wrangler --version 2>/dev/null | head -1)
ok "wrangler ${WRANGLER_VERSION}"

# Confirm token works
info "Verifying Cloudflare auth"
if ! npx wrangler whoami >/dev/null 2>&1; then
  fail "wrangler whoami failed — token is invalid or expired"
  echo "    Re-create at: https://dash.cloudflare.com/profile/api-tokens"
  exit 1
fi
ACCOUNT_NAME=$(npx wrangler whoami 2>/dev/null | grep -oE 'account "[^"]+"' | head -1)
ok "Authenticated as ${ACCOUNT_NAME:-Cloudflare user}"

# Confirm branch matches what we're deploying
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
echo "  Current branch: ${CURRENT_BRANCH}"

# Confirm clean working tree (don't deploy with uncommitted changes)
if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
  warn "Uncommitted changes detected:"
  git status --short 2>/dev/null | sed 's/^/    /'
  if [ "$ENV" = "prod" ]; then
    fail "Refusing to deploy to prod with uncommitted changes. Commit first."
    exit 1
  else
    warn "Continuing dev deploy with uncommitted changes (use git stash to suppress)"
  fi
fi

# Confirm git is in sync with origin
git fetch origin --quiet 2>/dev/null
LOCAL=$(git rev-parse HEAD 2>/dev/null)
REMOTE=$(git rev-parse "origin/${CURRENT_BRANCH}" 2>/dev/null || echo "")
if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
  warn "Local branch is not in sync with origin/${CURRENT_BRANCH}:"
  echo "    local:  $LOCAL"
  echo "    remote: $REMOTE"
  if [ "$ENV" = "prod" ]; then
    fail "Refusing to deploy to prod without sync. Run: git pull"
    exit 1
  fi
fi

# Confirm we're deploying the right env
case "$ENV" in
  dev)  WORKER_NAME="dt-api-v2-dev" ;;
  prod) WORKER_NAME="dt-api-v2" ;;
  *)    fail "Unknown env: $ENV. Use 'dev' or 'prod'."
        exit 1 ;;
esac

# Production gate — require explicit "ship it"
if [ "$ENV" = "prod" ]; then
  echo ""
  warn "============================================"
  warn "  DEPLOYING TO PRODUCTION: ${WORKER_NAME}"
  warn "============================================"
  echo ""
  echo -n "Type 'ship it' to confirm: "
  read -r CONFIRM
  if [ "$CONFIRM" != "ship it" ]; then
    fail "Aborted. You typed: '$CONFIRM' (expected 'ship it')"
    exit 5
  fi
  ok "Confirmed: ship it"
fi

# Build
info "Building (${ENV} → ${WORKER_NAME})"
if npx wrangler deploy --env "$ENV" --dry-run --outdir=dist > /tmp/wrangler-build.log 2>&1; then
  SIZE=$(du -sh dist 2>/dev/null | cut -f1 || echo "?")
  ok "Build succeeded (${SIZE})"
else
  fail "Build failed — see /tmp/wrangler-build.log"
  tail -20 /tmp/wrangler-build.log | sed 's/^/    /'
  exit 3
fi

# Deploy
if [ "$DRY_RUN" = "1" ]; then
  ok "Dry run complete — not deployed"
  exit 0
fi

info "Deploying to ${WORKER_NAME}"
DEPLOY_START=$(date +%s)
if npx wrangler deploy --env "$ENV" 2>&1 | tee /tmp/wrangler-deploy.log; then
  DEPLOY_DUR=$(($(date +%s) - DEPLOY_START))
  ok "Deployed to ${WORKER_NAME} in ${DEPLOY_DUR}s"

  # Show the URL
  echo ""
  URL="https://${WORKER_NAME}.nsura2029.workers.dev"
  ok "Worker URL: ${URL}"
  echo ""
  echo "  Test it:"
  echo "    curl ${URL}/"
  echo "    curl ${URL}/api/v1/health"
  echo "    curl ${URL}/api/v1/status"
  echo "    curl ${URL}/openapi.json | head -c 200"
  echo "    open ${URL}/docs"
  echo ""
else
  fail "Deploy failed — see /tmp/wrangler-deploy.log"
  tail -20 /tmp/wrangler-deploy.log | sed 's/^/    /'
  exit 4
fi
