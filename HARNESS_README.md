# Aran Harness 변환 안내

이 패키지는 기존 Claude Code 프로젝트 구조에 하네스 레이어를 추가한 버전이다.

## 추가된 핵심 파일
- `.claude/commands/harness.md`: `/harness` 실행 흐름
- `.claude/commands/review.md`: `/review` 규칙 기반 리뷰
- `docs/PRD.md`: 무엇을 만드는지
- `docs/ADR.md`: 왜 이렇게 만드는지
- `docs/UI_GUIDE.md`: 어떻게 보여야 하는지
- `phases/`: Phase 상태 관리
- `scripts/execute.py`: 다음 Phase 확인 및 실행 프롬프트 출력
- `scripts/hooks/`: 안전장치 스크립트

## 추천 사용 순서
1. `docs/PRD.md`, `docs/ADR.md`, `docs/UI_GUIDE.md`를 프로젝트 실제 내용에 맞게 보강한다.
2. Claude Code에서 `/harness`를 실행한다.
3. 생성된 Phase를 확인한다.
4. 필요 시 `python3 scripts/execute.py <task-name>`로 다음 Phase를 확인한다.
5. 작업 후 `/review`로 점검한다.

## 주의
`scripts/execute.py`는 안전하게 Phase 진행 상태를 관리하는 최소 버전이다. 실제 무인 자동 실행은 프로젝트 안정화 후에만 확장하는 것을 권장한다.
