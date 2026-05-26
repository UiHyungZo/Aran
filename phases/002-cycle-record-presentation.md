# Phase 002: 시술 기록 탭 — Presentation 계층 구현

## 목표
- CycleRecord / TransferRecord / PGTRecord의 Domain + Data는 이미 완료.
- Presentation 계층(화면, ViewModel, Coordinator, DIContainer)을 SwiftUI + Combine으로 구현한다.

## 참조 문서
- `CLAUDE.md`
- `docs/features.md`
- `docs/architecture.md`
- `docs/UI_GUIDE.md`
- `docs/data-model.md`

## 작업 범위

### ViewModel
- `CycleRecordViewModel` — 차수 목록 카드 데이터 바인딩, @Published
- `CycleFormViewModel` — 채취/이식 입력 유효성 검사
- `PGTFormViewModel` — 정상/이상/모자이크 입력 (이미 일부 구현 있음 — 확인 필요)

### View (SwiftUI)
- `CycleRecordView` — 차수 카드 목록 + 상태 배지(진행중/성공/실패)
- `CycleFormView` — 차수 선택 스테퍼, 개수 스테퍼, 배아 등급 chip, 동결/신선 선택
- `PGTFormView` — PGT 타입 chip, 정상/이상/모자이크 스테퍼, 날짜, 메모

### Swift Charts
- 차수별 채취 → 수정 → 동결 → 이식 흐름 Bar Chart
- `CycleChartView` — SwiftUI Charts, 다크모드 색상 별도 정의

### Application
- `CycleRecordSceneDIContainer` — factory 메서드
- `CycleRecordFlowCoordinator` (또는 NavigationStack으로 대체)

## 제외 범위
- HealthKit 연동
- 클라우드 동기화

## 변경 예정 파일
- `Aran/Presentation/CycleRecord/CycleRecordViewModel.swift` (신규)
- `Aran/Presentation/CycleRecord/CycleFormViewModel.swift` (신규)
- `Aran/Presentation/CycleRecord/CycleRecordView.swift` (신규)
- `Aran/Presentation/CycleRecord/CycleFormView.swift` (신규)
- `Aran/Presentation/CycleRecord/PGTFormView.swift` (신규 또는 이동)
- `Aran/Presentation/CycleRecord/CycleChartView.swift` (신규)
- `Aran/Application/DIContainer/CycleRecordSceneDIContainer.swift` (신규)
- `Aran/Presentation/Common/MainTabView.swift` (수정 — 시술 탭 연결)
- `AranTests/ViewModels/CycleRecordViewModelTests.swift` (신규)

## 완료 조건
- [ ] 차수 목록 화면 — 카드 표시, 상태 배지(진행중/성공/실패)
- [ ] 채취/이식 입력 화면 — 저장 후 목록 반영
- [ ] PGT 기록 화면 — 저장 동작
- [ ] Swift Charts Bar Chart — 차수별 흐름 시각화
- [ ] CycleRecordViewModel Unit Test 통과
- [ ] MainTabView 시술 탭 정상 연결

## 상태
pending
