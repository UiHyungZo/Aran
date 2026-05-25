#!/bin/bash
set -euo pipefail

INPUT="${1:-}"
if [ -z "$INPUT" ]; then
  INPUT="$(cat 2>/dev/null || true)"
fi

DANGEROUS_PATTERNS=(
  "rm -rf /"
  "rm -rf *"
  "git reset --hard"
  "git clean -fdx"
  "git push --force"
  "chmod -R 777"
)

for pattern in "${DANGEROUS_PATTERNS[@]}"; do
  if echo "$INPUT" | grep -Fq "$pattern"; then
    echo "BLOCKED: dangerous command detected: $pattern" >&2
    exit 2
  fi
done

exit 0
