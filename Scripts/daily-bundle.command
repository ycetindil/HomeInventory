#!/bin/zsh
set -euo pipefail

# Run from repo root (assumes this script lives in Scripts/)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

mkdir -p .local

# Defaults:
#   SINCE="today" (git understands this)
#   N=10 (fallback to last N commits if there are no commits since SINCE)
SINCE="${SINCE:-today}"
N="${N:-10}"

OUT=".local/DAILY_BUNDLE.md"

BRANCH="$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")"
HEAD_LINE="$(git log -1 --pretty=format:'%h %ad %s' --date=short 2>/dev/null || echo "unknown")"

# Count commits since SINCE; fallback to last N commits if zero
HAS_COMMITS_SINCE="$(git rev-list --count --since="$SINCE" HEAD 2>/dev/null || echo "0")"

{
  echo "# Daily Bundle — HomeInventory"
  echo
  echo "- Date: $(date)"
  echo "- Branch: ${BRANCH}"
  echo "- HEAD: ${HEAD_LINE}"
  echo "- Mode: commits since \"${SINCE}\" (fallback: last ${N} commits if none)"
  echo

  echo "## Current Docs Snapshots"
  echo '```'
  sed '' Docs/STATUS.md
  echo
  sed '' Docs/ROADMAP.md
  echo
  sed '' Docs/ARCHITECTURE.md
  echo '```'
  echo

  echo "## Git Status (human)"
  echo '```'
  git status
  echo '```'
  echo

  echo "## Files Changed (porcelain)"
  echo '```'
  git status --porcelain
  echo '```'
  echo

  echo "## Uncommitted Diff Summary (stat)"
  echo '```'
  git diff --stat
  echo '```'
  echo

  echo "## Staged Diff Summary (stat)"
  echo '```'
  git diff --cached --stat
  echo '```'
  echo

  echo "## Commits (${SINCE} or last ${N})"
  echo '```'
  if [ "${HAS_COMMITS_SINCE}" -gt 0 ]; then
    git log --since="${SINCE}" --pretty=format:'%h %ad %s' --date=short
  else
    git log -n "${N}" --pretty=format:'%h %ad %s' --date=short
  fi
  echo '```'
  echo

  echo "## Full Uncommitted Diff (NO truncation)"
  echo '```diff'
  git diff
  echo '```'
  echo

  echo "## Full Staged Diff (NO truncation)"
  echo '```diff'
  git diff --cached
  echo '```'
  echo

  echo "## Full Patches (${SINCE} or last ${N})"
  echo '```diff'
  if [ "${HAS_COMMITS_SINCE}" -gt 0 ]; then
    git log --since="${SINCE}" -p
  else
    git log -n "${N}" -p
  fi
  echo '```'
  echo
} > "${OUT}"

echo "Wrote: ${OUT}"
open "${OUT}"
