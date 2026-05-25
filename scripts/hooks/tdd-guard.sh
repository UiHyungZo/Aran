#!/bin/bash
set -euo pipefail

# 구현 파일 변경 시 관련 테스트가 전혀 없으면 경고한다.
# 기본은 차단이 아니라 경고(exit 0)로 둔다. 엄격 모드는 STRICT_TDD_GUARD=1 사용.

CHANGED="$(git diff --name-only 2>/dev/null || true)"
if [ -z "$CHANGED" ]; then
  exit 0
fi

IMPLEMENTATION_CHANGED=$(echo "$CHANGED" | grep -E '\.swift$' | grep -v -E 'Tests/|Test\.swift|Tests\.swift' || true)
TEST_CHANGED=$(echo "$CHANGED" | grep -E 'Tests/|Test\.swift|Tests\.swift' || true)

if [ -n "$IMPLEMENTATION_CHANGED" ] && [ -z "$TEST_CHANGED" ]; then
  echo "WARNING: Swift implementation changed but no test file changed." >&2
  echo "Consider adding/updating XCTest/XCUITest before completing this task." >&2
  if [ "${STRICT_TDD_GUARD:-0}" = "1" ]; then
    exit 2
  fi
fi

exit 0
