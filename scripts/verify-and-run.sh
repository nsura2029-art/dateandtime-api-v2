#!/usr/bin/env bash
# verify-and-run.sh — All-in-one: run every check, then start the dev server in Docker (remote D1).
#
# Usage:
#   bash scripts/verify-and-run.sh                # full: all checks + Docker server
#   bash scripts/verify-and-run.sh --checks-only   # only the 5 checks, no Docker
#   bash scripts/verify-and-run.sh --server-only   # only start the server, skip checks
#   bash scripts/verify-and-run.sh --no-build      # skip the 'npm ci' rebuild
#   bash scripts/verify-and-run.sh --help          # show this help
#
# Required env (for Docker remote mode):
#   CLOUDFLARE_API_TOKEN   — Cloudflare API token with Workers Scripts:Edit + D1:Edit scopes
#   CLOUDFLARE_ACCOUNT_ID  — your Cloudflare account ID
#
# Exit codes:
#   0  — all checks passed and server is up
#   1  — one or more checks failed
#   2  — Docker is not running
#   3  — Cloudflare credentials missing (when using --remote)
#   4  — port 8787 already in use
#   5  — npm ci failed

set -uo pipefail

# ============================================================================
# Parse args + show help
# ============================================================================
CHECKS_ONLY=0
SERVER_ONLY=0
NO_BUILD=0
PROFILE="remote"
COMPOSE_FILE="docker/docker-compose.yml"

show_help() {
  sed -n '2,18p' "$0" | sed 's/^# \{0,1\}//'
  exit 0
}

for arg in "$@"; do
  case "$arg" in
    --checks-only) CHECKS_ONLY=1 ;;
    --server-only) SERVER_ONLY=1 ;;
    --no-build)    NO_BUILD=1 ;;
    --local)       PROFILE="local" ;;
    --remote)      PROFILE="remote" ;;
    --help|-h)     show_help ;;
    *) echo "Unknown arg: $arg. Try --help." ; exit 1 ;;
  esac
done

# ============================================================================
# Pretty output
# ============================================================================
if [ -t 1 ]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  BLUE='\033[0;34m'
  BOLD='\033[1m'
  NC='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' BOLD='' NC=''
fi

PASS=0
FAIL=0
START_TIME=$(date +%s)

ok()   { echo -e "  ${GREEN}✓${NC} $1"; ((PASS++)); }
fail() { echo -e "  ${RED}✗${NC} $1"; ((FAIL++)); }
warn() { echo -e "  ${YELLOW}⚠${NC}  $1"; }
info() { echo -e "${BLUE}${BOLD}==>${NC} $1"; }
hr()   { echo -e "${BOLD}───────────────────────────────────────────────${NC}"; }

run_check() {
  local name="$1"
  shift
  local start=$(date +%s)
  if "$@" > /tmp/check-output.log 2>&1; then
    local dur=$(($(date +%s) - start))
    ok "$name (${dur}s)"
    return 0
  else
    local dur=$(($(date +%s) - start))
    fail "$name (${dur}s) — see /tmp/check-output.log"
    echo "    --- last 10 lines of output ---"
    tail -10 /tmp/check-output.log | sed 's/^/    /'
    return 1
  fi
}

# ============================================================================
# Resolve project root
# ============================================================================
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
cd "$ROOT_DIR"

# ============================================================================
# Pre-flight: must be in a clean-ish state
# ============================================================================
info "Pre-flight checks"
hr
echo ""

# Node version check — fail fast with a clear message
if command -v node >/dev/null 2>&1; then
  NODE_MAJOR=$(node -v | sed -E 's/^v([0-9]+).*/\1/')
  NODE_FULL=$(node -v)
  if [ "$NODE_MAJOR" = "23" ]; then
    echo -e "  ${RED}✗${NC} Node $NODE_FULL detected (odd-numbered = 'current' release, not LTS)"
    echo -e "    ${YELLOW}wrangler + some eslint deps require ^20.19.0 || ^22.13.0 || >=24${NC}"
    echo -e "    Switch to Node 22 LTS:"
    echo -e "      nvm install 22 && nvm use 22"
    echo -e "    Or Node 24+ (if you prefer current LTS):"
    echo -e "      nvm install 24 && nvm use 24"
    echo ""
    exit 1
  elif [ "$NODE_MAJOR" = "20" ]; then
    NODE_MINOR=$(node -v | sed -E 's/^v([0-9]+)\.([0-9]+).*/\2/')
    if [ "$NODE_MINOR" -lt 19 ]; then
      echo -e "  ${YELLOW}⚠${NC} Node $NODE_FULL detected — package wants 20.19+"
      echo -e "    nvm install 20.19.0 && nvm use 20.19.0"
      echo ""
      exit 1
    else
      ok "Node $NODE_FULL"
    fi
  elif [ "$NODE_MAJOR" = "22" ]; then
    NODE_MINOR=$(node -v | sed -E 's/^v([0-9]+)\.([0-9]+).*/\2/')
    if [ "$NODE_MINOR" -lt 13 ]; then
      echo -e "  ${YELLOW}⚠${NC} Node $NODE_FULL detected — package wants 22.13+"
      echo -e "    nvm install 22 && nvm use 22"
      echo ""
      exit 1
    else
      ok "Node $NODE_FULL"
    fi
  elif [ "$NODE_MAJOR" -ge 24 ]; then
    ok "Node $NODE_FULL"
  else
    echo -e "  ${YELLOW}⚠${NC} Node $NODE_FULL — untested version, may not work"
    echo ""
  fi
else
  echo -e "  ${RED}✗${NC} Node not found — install Node 22 LTS from https://nodejs.org/"
  echo ""
  exit 1
fi

if [ ! -f "package.json" ]; then
  fail "package.json not found. Run from the repo root."
  exit 1
fi
ok "package.json found"

if [ ! -d "node_modules" ] && [ "$NO_BUILD" = "0" ]; then
  warn "node_modules missing. Running npm ci..."
  if npm ci --no-audit --no-fund > /tmp/npm-ci.log 2>&1; then
    ok "npm ci completed"
  else
    fail "npm ci failed — see /tmp/npm-ci.log"
    tail -10 /tmp/npm-ci.log | sed 's/^/    /'
    exit 5
  fi
else
  ok "node_modules present"
fi

# ============================================================================
# Run the 5 checks
# ============================================================================
if [ "$SERVER_ONLY" = "0" ]; then
  info "Automated checks"
  hr

  run_check "typecheck"           npm run --silent typecheck
  run_check "lint"                npm run --silent lint
  run_check "vitest"              npm test --silent -- --run
  run_check "smoke (curl)"       bash scripts/test-endpoints.sh
  run_check "readme sync"        bash scripts/sync-readme.sh --check
fi

# ============================================================================
# Summary
# ============================================================================
TOTAL_DUR=$(($(date +%s) - START_TIME))
hr
echo ""
if [ "$FAIL" -gt 0 ]; then
  echo -e "${RED}${BOLD}✗ ${FAIL} check(s) failed, ${PASS} passed (in ${TOTAL_DUR}s)${NC}"
  echo ""
  echo "Server not started. Fix the failing checks above and try again."
  exit 1
fi

if [ "$CHECKS_ONLY" = "1" ]; then
  echo -e "${GREEN}${BOLD}✓ All ${PASS} checks passed (in ${TOTAL_DUR}s)${NC}"
  exit 0
fi

# ============================================================================
# Check port 8787 is free
# ============================================================================
info "Pre-server checks"
hr

if command -v lsof >/dev/null 2>&1; then
  if lsof -iTCP:8787 -sTCP:LISTEN >/dev/null 2>&1; then
    fail "Port 8787 is already in use. Stop the other process or use a different port."
    lsof -iTCP:8787 -sTCP:LISTEN | sed 's/^/    /'
    exit 4
  fi
elif command -v netstat >/dev/null 2>&1; then
  if netstat -an 2>/dev/null | grep -E ":8787.*LISTEN" >/dev/null; then
    fail "Port 8787 is already in use (Windows netstat). Stop the other process."
    exit 4
  fi
fi
ok "Port 8787 is free"

# ============================================================================
# Check Docker is running
# ============================================================================
if ! command -v docker >/dev/null 2>&1; then
  fail "docker not found. Install Docker Desktop: https://www.docker.com/products/docker-desktop"
  exit 2
fi

if ! docker info >/dev/null 2>&1; then
  fail "Docker daemon not running. Start Docker Desktop."
  exit 2
fi
ok "Docker is running"

# ============================================================================
# Check Cloudflare credentials (for remote mode)
# ============================================================================
if [ "$PROFILE" = "remote" ]; then
  if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
    fail "CLOUDFLARE_API_TOKEN env var is required for remote mode."
    echo "    Create at https://dash.cloudflare.com/profile/api-tokens"
    echo "    Required scopes: Workers Scripts:Edit, D1:Edit, Workers KV Storage:Edit"
    echo "    Then: export CLOUDFLARE_API_TOKEN=..."
    exit 3
  fi
  if [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
    fail "CLOUDFLARE_ACCOUNT_ID env var is required for remote mode."
    echo "    Find in the Cloudflare dashboard right sidebar on the Workers page."
    echo "    Then: export CLOUDFLARE_ACCOUNT_ID=..."
    exit 3
  fi
  ok "CLOUDFLARE_API_TOKEN is set"
  ok "CLOUDFLARE_ACCOUNT_ID is set"
fi

# ============================================================================
# Build the Docker image (skip if --no-build)
# ============================================================================
info "Docker setup (profile: $PROFILE)"
hr

if [ "$NO_BUILD" = "0" ]; then
  echo "Building Docker image..."
  if docker compose -f "$COMPOSE_FILE" --profile "$PROFILE" build > /tmp/docker-build.log 2>&1; then
    ok "Docker image built"
  else
    fail "Docker build failed — see /tmp/docker-build.log"
    tail -15 /tmp/docker-build.log | sed 's/^/    /'
    exit 1
  fi
else
  ok "Skipping Docker build (--no-build)"
fi

# ============================================================================
# Start the server (foreground so user can see logs + Ctrl+C to stop)
# ============================================================================
info "Starting server in Docker (profile: $PROFILE)"
hr
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop the server.${NC}"
echo ""

# Trap Ctrl+C to clean up the container
cleanup() {
  echo ""
  echo ""
  info "Stopping server..."
  docker compose -f "$COMPOSE_FILE" --profile "$PROFILE" down >/dev/null 2>&1
  echo "  Done."
  exit 0
}
trap cleanup INT TERM

# Start the server (blocks until Ctrl+C)
docker compose -f "$COMPOSE_FILE" --profile "$PROFILE" up
