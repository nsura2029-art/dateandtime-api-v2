#!/usr/bin/env bash
# sync-readme.sh — Regenerate the endpoint table in README.md.
#
# Usage:
#   bash scripts/sync-readme.sh              # update README.md
#   bash scripts/sync-readme.sh --check      # exit 1 if out of sync (for CI)
#
# The extractor parses src/routes/*.ts and rewrites the block between
# <!-- ENDPOINTS_START --> and <!-- ENDPOINTS_END --> markers.

set -uo pipefail

# Find the project root (parent of scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

cd "$ROOT_DIR"

# Find a TS runner (prefer tsx, fall back to node --experimental-strip-types)
if command -v tsx >/dev/null 2>&1; then
  RUNNER="tsx"
elif node --experimental-strip-types -e "" >/dev/null 2>&1; then
  RUNNER="node --experimental-strip-types"
else
  echo "❌ Need 'tsx' or Node 22+ (for --experimental-strip-types)"
  echo "   Install: npm install -g tsx"
  exit 1
fi

if [[ "${1:-}" == "--check" ]]; then
  $RUNNER scripts/extract-endpoints.ts --check
  exit $?
else
  $RUNNER scripts/extract-endpoints.ts --update README.md
  exit $?
fi
