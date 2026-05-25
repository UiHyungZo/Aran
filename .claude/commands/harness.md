# /harness

TODO.md의 첫 번째 미완료 작업을 기준으로 프로젝트 하네스 워크플로우를 실행한다.

## 실행 원칙
- 먼저 `CLAUDE.md`를 확인한다.
- 필요한 `docs/` 문서만 선별해서 읽는다.
- 비사소한 수정 전에는 반드시 계획과 변경 예정 파일을 사용자에게 설명하고 승인을 기다린다.
- 구현 범위가 모호하면 질문한다.
- 작업 완료 후 `HANDOFF.md`를 갱신한다.

## 실행 흐름
1. `TODO.md`에서 첫 번째 미완료 작업을 찾는다.
2. `HANDOFF.md`에서 이전 상태와 주의사항을 확인한다.
3. 작업 성격에 맞는 문서를 읽는다.
   - 요구사항: `docs/PRD.md`, `docs/features.md`
   - 구조 변경: `docs/architecture.md`, `docs/ADR.md`
   - API: `docs/api.md`
   - 테스트: `docs/testing.md`
   - UI: `docs/UI_GUIDE.md`
4. 작업을 Phase로 나눈다.
5. 필요하면 `phases/`에 Phase 파일을 생성한다.
6. 사용자 승인 후 구현한다.
7. `/review` 기준으로 자체 리뷰한다.
8. 필요 시 `scripts/build-debug.sh` 실행을 제안한다.
9. `TODO.md`와 `HANDOFF.md`를 갱신한다.

## 출력 형식
- 현재 작업
- 참조한 문서
- 구현 계획
- 변경 예정 파일
- 위험 요소
- 승인 요청
