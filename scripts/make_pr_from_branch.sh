#!/usr/bin/env bash
set -e
BRANCH_PREFIX="${1:-copilot}"
MSG="${2:-chore: changes by copilot}"
BRANCH="${BRANCH_PREFIX}/$(date +%Y%m%d%H%M%S)"
git checkout -b "$BRANCH"
git add -A
git commit -m "$MSG" || { echo "Nothing to commit"; exit 0; }
git push -u origin "$BRANCH"
gh pr create --fill --label "copilot" --assignee @me
echo "PR created: $BRANCH"
