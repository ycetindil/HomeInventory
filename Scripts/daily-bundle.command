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
# Ensure numeric
HAS_COMMITS_SINCE="${HAS_COMMITS_SINCE:-0}"

# Uncommitted change count (porcelain lines)
CHANGED_COUNT="$(git status --porcelain | wc -l | tr -d ' ')"
CHANGED_COUNT="${CHANGED_COUNT:-0}"

# Staged change count
STAGED_COUNT="$(git diff --cached --name-only | wc -l | tr -d ' ')"
STAGED_COUNT="${STAGED_COUNT:-0}"

# Heuristic warnings
WARN_COMMIT="false"
WARN_NOTES="false"

# If lots of changes and no commits since SINCE, suggest checkpoint
if [ "${CHANGED_COUNT}" -ge 15 ] && [ "${HAS_COMMITS_SINCE}" -eq 0 ]; then
  WARN_COMMIT="true"
fi

# If there are changes but no staged changes, remind user how to checkpoint
if [ "${CHANGED_COUNT}" -gt 0 ] && [ "${STAGED_COUNT}" -eq 0 ]; then
  WARN_COMMIT="true"
fi

print_doc() {
  local path="$1"
  echo "### ${path}"
  echo '```'
  if [ -f "${path}" ]; then
    cat "${path}"
  else
    echo "(missing file: ${path})"
  fi
  echo '```'
  echo
}

{
  echo "# Daily Bundle — HomeInventory"
  echo
  echo "- Date: $(date)"
  echo "- Branch: ${BRANCH}"
  echo "- HEAD: ${HEAD_LINE}"
  echo "- Mode: commits since \"${SINCE}\" (fallback: last ${N} commits if none)"
  echo

  echo "## Session Notes (fill these before pasting to the Architect)"
  echo
  echo "> Keep 3–8 bullets. Only decisions/corrections/known-issues that are NOT obvious from diffs."
  echo
  echo "- Decision:"
  echo "- Decision:"
  echo "- Correction:"
  echo "- Known issue (only if real):"
  echo

  echo "## Checkpoint Health"
  echo
  echo "- Uncommitted changes (porcelain lines): ${CHANGED_COUNT}"
  echo "- Staged files: ${STAGED_COUNT}"
  echo "- Commits since \"${SINCE}\": ${HAS_COMMITS_SINCE}"
  if [ "${WARN_COMMIT}" = "true" ]; then
    echo "- ⚠️ Suggestion: make a checkpoint commit before wrap-up."
    echo "  - Quick: \`git add -A && git commit -m \"wip(ui): checkpoint\"\`"
    echo "  - Or: \`Scripts/checkpoint.command \"wip(ui): <slice>\"\` (if you created it)"
  else
    echo "- ✅ Looks reasonably checkpointed."
  fi
  echo

  echo "## Current Docs Snapshots"
  echo
  print_doc "Docs/STATUS.md"
  print_doc "Docs/ROADMAP.md"
  print_doc "Docs/ARCHITECTURE.md"

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
