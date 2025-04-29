#!/usr/bin/env bash
# Quick gap report: lists domain folders with unchecked items in gaps.md
find exam-topics -name gaps.md | while read -r file; do
  if grep -q '\[ \]' "$file"; then
    domain=$(basename "$(dirname "$file")")
    echo "❌ Gaps detected in $domain"
    grep '\[ \]' "$file" | sed 's/^/- /'
  fi
done
