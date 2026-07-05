#!/bin/bash
set -euo pipefail

WATCH_DIR="/Volumes/RAMDisk"

if command -v fswatch >/dev/null 2>&1; then
  FSWATCH_BIN="$(command -v fswatch)"
elif [ -x "/opt/homebrew/bin/fswatch" ]; then
  FSWATCH_BIN="/opt/homebrew/bin/fswatch"
elif [ -x "/usr/local/bin/fswatch" ]; then
  FSWATCH_BIN="/usr/local/bin/fswatch"
else
  echo "fswatch not found. Install it with 'brew install fswatch'." >&2
  exit 1
fi

"$FSWATCH_BIN" -0 -r --event Updated "$WATCH_DIR" | while read -d "" file; do
  [ -f "$file" ] || continue
  dir=$(dirname "$file")
  cd "$dir" || continue

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
  git diff --quiet -- "$file" && [ -z "$(git status --porcelain -- "$file")" ] && continue

  msg=$(git diff -U0 -- "$file" | tail -1)
  [ -z "$msg" ] && msg="update ${file##*/}"

  git ls-files --error-unmatch -- "$file" && \
  git commit -m "$msg" -- "$file" && \
  git symbolic-ref --short refs/remotes/origin/HEAD | grep -v "$(git branch --show-current)" > /dev/null 2>&1 && \
  git push
done
