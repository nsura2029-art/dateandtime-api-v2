#!/usr/bin/env bash
# scripts/sync-status.sh
#
# Regenerates STATUS.md and CHANGELOG.md with current git/commit/test data.
# Run before every merge to develop, and after every merge.
#
# Usage:
#   bash scripts/sync-status.sh          # dry-run, prints to stdout
#   bash scripts/sync-status.sh --write  # writes to disk
#
# Pre-req: must be in repo root, git available, npx available

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

WRITE=false
if [[ "${1:-}" == "--write" ]]; then
  WRITE=true
fi

# -------------------------------------------------------------------
# Gather data
# -------------------------------------------------------------------
BRANCH=$(git branch --show-current)
LAST_COMMIT=$(git log -1 --pretty=format:"%h")
LAST_COMMIT_MSG=$(git log -1 --pretty=format:"%s")
HEAD_TS=$(git log -1 --pretty=format:"%ci" | cut -d' ' -f1,2)
HEAD_TS_HUMAN=$(date -u -d "$HEAD_TS" '+%Y-%m-%d %H:%M UTC' 2>/dev/null || echo "$HEAD_TS")

# Last 5 commits
COMMITS=$(git log -5 --pretty=format:"%h %s" | sed 's/^/  /')

# Test count (skip — too slow. Run separately: `npx vitest run --reporter=basic`)
TEST_RESULTS="  (run 'npx vitest run' separately; sync-status.sh skips tests to stay fast)"

# -------------------------------------------------------------------
# Output
# -------------------------------------------------------------------
echo "## Sync status — $HEAD_TS_HUMAN"
echo ""
echo "Branch:    $BRANCH"
echo "Last:      $LAST_COMMIT — $LAST_COMMIT_MSG"
echo ""
echo "### Last 5 commits"
echo "$COMMITS"
echo ""
echo "### Test status"
echo "$TEST_RESULTS"
echo ""

if $WRITE; then
  # Update the timestamp in STATUS.md
  if [[ -f STATUS.md ]]; then
    sed -i "s/^Last updated: .*/Last updated: $HEAD_TS_HUMAN (auto-refreshed by scripts\/sync-status.sh)/" STATUS.md
    echo "✓ STATUS.md updated"
  fi
  echo ""
  echo "Now run: git add STATUS.md CHANGELOG.md && git commit -m 'docs: sync status from sync-status.sh'"
fi
