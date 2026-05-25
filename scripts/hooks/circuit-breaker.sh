#!/bin/bash
set -euo pipefail

LOG_DIR=".claude/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/error-history.log"
WINDOW_SECONDS="${CIRCUIT_WINDOW_SECONDS:-60}"
THRESHOLD="${CIRCUIT_THRESHOLD:-5}"
NOW=$(date +%s)
MESSAGE="${1:-$(cat 2>/dev/null || true)}"

if echo "$MESSAGE" | grep -qE '(^error:|^fatal error:|^Build FAILED$|FAILED \(|xcodebuild: error)'; then
  echo "$NOW $MESSAGE" >> "$LOG_FILE"
fi

COUNT=$(awk -v now="$NOW" -v win="$WINDOW_SECONDS" '$1 >= now - win {count++} END {print count+0}' "$LOG_FILE" 2>/dev/null || echo 0)

if [ "$COUNT" -ge "$THRESHOLD" ]; then
  echo "CIRCUIT BREAKER: repeated errors detected ($COUNT within ${WINDOW_SECONDS}s). Stop and reassess strategy." >&2
  exit 2
fi

exit 0
