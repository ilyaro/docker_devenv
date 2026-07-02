#!/bin/bash
set -euo pipefail

WATCH_DIR="/Volumes/RAMDisk"

fswatch -0 -r --event Updated "$WATCH_DIR" | while read -d "" file; do
  [ -f "$file" ] || continue
  dir=$(dirname "$file")
  cd "$dir" || continue

  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || continue
  git diff --quiet -- "$file" && [ -z "$(git status --porcelain -- "$file")" ] && continue

  msg=$(git diff -U0 -- "$file" | tail -1)
  [ -z "$msg" ] && msg="update ${file##*/}"

  git add -A -- "$file"
  git commit -m "$msg" -- "$file" && git push
done
