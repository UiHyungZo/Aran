# phases/

작업을 작은 Phase 단위로 나누고 진행 상태를 기록하는 공간이다.

## 상태값
- `pending`: 아직 시작하지 않음
- `in_progress`: 진행 중
- `completed`: 완료
- `blocked`: 사용자 확인 필요
- `error`: 오류로 중단

## 권장 파일명
- `001-plan.md`
- `002-implement.md`
- `003-review.md`
- `004-verify.md`

`status.json`은 현재 진행 상태를 추적한다.
