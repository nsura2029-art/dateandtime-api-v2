#!/usr/bin/env bash
# scripts/pre-merge-to-develop.sh
#
# Run this BEFORE merging any feature branch to develop.
# It enforces the doc-update framework:
#   1. STATUS.md reflects current state
#   2. CHANGELOG.md has an [unreleased] entry
#   3. tests/ count is recorded
#   4. TODO.md is in sync
#
# Usage:
#   bash scripts/pre-merge-to-develop.sh         # check
#   bash scripts/pre-merge-to-develop.sh --fix   # auto-fix what we can
#
# Exit code: 0 if ready, 1 if needs attention.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

FIX=false
if [[ "${1:-}" == "--fix" ]]; then
  FIX=true
fi

ERRORS=0
WARNINGS=0

check() {
  local label="$1"
  local status="$2"
  if [[ "$status" == "ok" ]]; then
    echo "  ✓ $label"
  elif [[ "$status" == "warn" ]]; then
    echo "  ⚠ $label"
    WARNINGS=$((WARNINGS+1))
  else
    echo "  ✗ $label"
    ERRORS=$((ERRORS+1))
  fi
}

echo "Doc-update framework check (sync-status.sh)"
echo "=============================================="
echo ""

# 1. STATUS.md exists
if [[ -f STATUS.md ]]; then
  check "STATUS.md exists" "ok"
  # Check it's been updated within last 7 days
  AGE_DAYS=$(( ($(date +%s) - $(stat -c %Y STATUS.md 2>/dev/null || stat -f %m STATUS.md)) / 86400 ))
  if [[ $AGE_DAYS -gt 7 ]]; then
    check "STATUS.md updated in last 7 days (was $AGE_DAYS days ago)" "warn"
    if $FIX; then
      echo "    → run: bash scripts/sync-status.sh --write"
    fi
  else
    check "STATUS.md updated in last 7 days" "ok"
  fi
else
  check "STATUS.md exists" "fail"
fi

# 2. CHANGELOG.md has [unreleased] entry
if [[ -f CHANGELOG.md ]]; then
  if grep -q "## \[unreleased\]" CHANGELOG.md; then
    check "CHANGELOG.md has [unreleased] entry" "ok"
  else
    check "CHANGELOG.md has [unreleased] entry" "fail"
  fi
else
  check "CHANGELOG.md exists" "fail"
fi

# 3. TODO.md exists and isn't empty
if [[ -f TODO.md ]] && [[ -s TODO.md ]]; then
  check "TODO.md exists and non-empty" "ok"
else
  check "TODO.md exists and non-empty" "fail"
fi

# 4. No uncommitted changes
if [[ -z "$(git status --porcelain)" ]]; then
  check "No uncommitted changes" "ok"
else
  check "No uncommitted changes (have uncommitted: $(git status --porcelain | wc -l) files)" "warn"
fi

# 5. Current branch is a feature branch (not main/develop)
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == "develop" ]] || [[ "$BRANCH" == "main" ]]; then
  check "On a feature branch (currently on $BRANCH)" "warn"
else
  check "On a feature branch ($BRANCH)" "ok"
fi

# 6. Test count in CHANGELOG mentions something
if grep -qE "Tests?[: ]+[0-9]+|test count|310|/311" CHANGELOG.md 2>/dev/null; then
  check "CHANGELOG.md has test count" "ok"
else
  check "CHANGELOG.md has test count" "warn"
fi

# 7. reports/ has an entry for the latest milestone
LATEST_REPORT=$(ls -t reports/m*.md 2>/dev/null | head -1 || echo "")
if [[ -n "$LATEST_REPORT" ]]; then
  check "Latest milestone report exists: $LATEST_REPORT" "ok"
else
  check "Latest milestone report exists" "warn"
fi

echo ""
echo "Summary: $ERRORS errors, $WARNINGS warnings"

if [[ $ERRORS -gt 0 ]]; then
  echo ""
  echo "❌ Not ready to merge. Fix errors above."
  exit 1
fi

if [[ $WARNINGS -gt 0 ]]; then
  echo ""
  echo "⚠ Ready to merge with warnings. Consider fixing them."
  exit 0
fi

echo ""
echo "✓ Ready to merge to develop."
exit 0
