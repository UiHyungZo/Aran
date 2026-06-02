# Phase 004: MVP 2순위 나머지 — 알림 미리보기 / 최근 검색어 / HealthRecord History

## 목표
- Phase 001 이후 남은 MVP 2순위 기능을 완성한다.

## 참조 문서
- `CLAUDE.md`
- `docs/features.md`

## 작업 범위

### 알림 미리보기
- `MedicationListViewController`에 알림 미리보기 섹션 또는 모달 추가
- 알림 내용 미리보기 + 개별 ON/OFF 토글

### 최근 검색어 (DrugInfo)
- `DrugInfoViewModel` — UseCase/Repository 경유 최근 검색어 저장/조회
- `DrugInfoView` 검색 바 아래 최근 검색어 목록 표시
- 검색어 선택 시 자동 검색 실행

### Health Record History View
- `ExamHistoryViewController` — 항목별 날짜순 히스토리 목록 (현재 구현 확인 후 보완)
- 항목 선택 → 히스토리 화면 이동 플로우 확인

## 변경 예정 파일
- `Aran/Presentation/Medication/MedicationListViewController.swift` (수정)
- `Aran/Presentation/DrugInfo/DrugInfoViewModel.swift` (수정)
- `Aran/Presentation/DrugInfo/DrugInfoView.swift` (수정)
- `Aran/Presentation/HealthRecord/ExamHistoryViewController.swift` (확인 및 보완)

## 완료 조건
- [ ] 알림 미리보기 — 개별 ON/OFF 동작
- [ ] 최근 검색어 — 저장/표시/선택 동작
- [ ] HealthRecord History — 항목별 날짜순 목록 표시

## 상태
pending
