# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `feat/record`
- **전체 진행도**: Domain·Data·Application 계층 완료. Presentation 4탭 기본 구현. CycleRecord 탭 UI 전체 미구현.
- **현재 작업**: 시술 기록 탭 Presentation 계층 구현

### 레이어별 진척율

| 계층 / 탭 | 진척율 |
|-----------|--------|
| Domain 계층 | 100% |
| Data 계층 | 95% |
| Application 계층 | 100% |
| 📅 Calendar 탭 UI | 60% |
| 💊 Medication 탭 UI | 100% |
| 🏥 HealthRecord 탭 UI | 85% |
| 🔍 DrugInfo 탭 UI | 95% |
| 🗂 CycleRecord 탭 UI | 0% (Domain / Data는 100%) |
| 단위 테스트 | 60% |
| UI 테스트 | 0% |

---

## PRD v14.0 시술기록 변경사항

이번 구현에서 반드시 반영해야 할 3가지 변경:

| # | 변경 내용 | 영향 |
|---|-----------|------|
| 1 | **PGT / 염색체 / 반착검사** → 검사 탭에서 시술 기록 탭으로 완전 이동 | PGT 입력 폼을 시술 기록 탭에서 구현. 검사 탭에서는 제거 |
| 2 | **차수 상세 화면 신규 추가** | 차수 카드 탭 → 상세 화면 (채취→수정→동결→이식→PGT 흐름 한눈에) |
| 3 | **이식 결과 별도 입력 화면 추가** | 이식 기록 저장 후 나중에 결과(성공/실패/진행중)만 별도 업데이트 가능 |

---

## 구현 목표: 시술 기록 탭 (TAB 4)

**기술 스택**: SwiftUI + Combine + Swift Charts

### 화면 구조

```
CycleRecordListView          ← 탭 루트 화면
├── CycleRecordDetailView    ← 차수 카드 탭 시 진입
│   ├── TransferFormView     ← 이식 기록 입력
│   ├── TransferResultView   ← 이식 결과 업데이트
│   └── PGTFormView          ← PGT/염색체/반착검사 입력
├── CycleRecordFormView      ← 새 차수(채취) 등록
└── CycleChartView           ← Swift Charts Bar Chart
```

---

## 구현할 파일 목록

모두 `Aran/Presentation/CycleRecord/` 경로에 생성한다.

### 1. `CycleRecordListView.swift`

**역할**: 탭 루트. 차수별 카드 목록.

구현 내용:
- `NavigationStack` 루트
- 차수별 카드 리스트 (`List` 또는 `ScrollView + LazyVStack`)
- 각 카드: 차수 번호, 채취/수정/동결 개수 요약, 이식 결과 배지
- 상태 배지: 진행중(황색 `#F59E0B`), 성공(녹색 `#1D9E75`), 실패(적색 `#EF4444`)
- toolbar `+` 버튼 → `CycleRecordFormView` sheet 표시
- Empty 상태: "첫 번째 차수를 기록해보세요" 안내
- 카드 탭 → `CycleRecordDetailView` NavigationLink

### 2. `CycleRecordDetailView.swift`

**역할**: 차수 상세. 해당 차수 전체 이력 타임라인 표시.

구현 내용:
- 상단: 차수 번호 + 시작일
- 섹션 1 — 채취/수정/동결: retrievalCount / fertilizedCount / frozenCount 수치 표시
- 섹션 2 — 이식 기록 목록: TransferRecord 리스트 (이식일, 등급, 신선/동결, 결과 배지)
  - 각 이식 행 탭 → `TransferResultView` sheet (결과 업데이트)
  - 이식 추가 버튼 → `TransferFormView` sheet
- 섹션 3 — PGT/검사 기록 목록: PGTRecord 리스트 (검사일, 종류, 정상/비정상/모자이크 개수)
  - PGT 추가 버튼 → `PGTFormView` sheet
- 하단: `CycleChartView` 삽입

### 3. `CycleRecordFormView.swift`

**역할**: 새 차수(채취) 등록 폼.

입력 필드:
- 차수 번호 (`Stepper`, 1~20)
- 시작일 (`DatePicker`)
- 채취 개수 (`Stepper`, 0~50)
- 수정 개수 (`Stepper`, 0~50)
- 동결 개수 (`Stepper`, 0~50)
- 배아 등급 목록 (`TextField`, 쉼표 구분 입력 → `[String]` 변환)
- 저장 / 취소 버튼

저장 시: `CycleRecordViewModel.saveCycleRecord(...)` 호출

### 4. `TransferFormView.swift`

**역할**: 이식 기록 입력 폼.

입력 필드:
- 이식일 (`DatePicker`)
- 배아 등급 (`TextField`, 예: "3AA")
- 이식 개수 (`Stepper`, 1~5)
- 신선/동결 (`Picker`: 신선 / 동결)
- 초기 결과: 기본값 `.pending` (대기)
- 저장 / 취소

저장 시: `CycleRecordViewModel.saveTransferRecord(cycleRecordId:, ...)` 호출

### 5. `TransferResultView.swift`

**역할**: 이식 결과만 업데이트하는 전용 화면.

PRD v14.0 신규. 이식 후 나중에 결과를 기록할 때 사용.

구현 내용:
- 이식 정보 요약 표시 (읽기 전용: 이식일, 등급, 개수)
- 결과 선택 (`Picker` 또는 세그먼트): 대기 / 성공 / 실패
- 저장 버튼

저장 시: `CycleRecordViewModel.updateTransferResult(id:, result:)` 호출

### 6. `PGTFormView.swift`

**역할**: PGT / 염색체 / 반착검사 결과 입력.

PRD v14.0: 검사 탭에서 이동. PGTRecord 도메인 엔티티 사용.

입력 필드:
- 검사 종류 (`Picker`): PGT-A / PGT-M / 부부염색체 / 반착검사
  - `PGTType` enum: `.pgtA`, `.pgtM`, `.chromosomeCouple`, `.implantation`
- 검사일 (`DatePicker`)
- 정상 개수 (`Stepper`, 0~30) — PGT-A/M일 때만 표시
- 비정상 개수 (`Stepper`, 0~30) — PGT-A/M일 때만 표시
- 모자이크 개수 (`Stepper`, 0~30) — PGT-A/M일 때만 표시
- 메모 (`TextField`, 선택)
- 저장 / 취소

저장 시: `CycleRecordViewModel.savePGTRecord(cycleRecordId:, ...)` 호출

### 7. `CycleChartView.swift`

**역할**: 차수별 채취→수정→동결→이식 흐름 Bar Chart.

구현 내용:
- Swift Charts `BarMark`
- X축: 차수 번호 (1차, 2차, ...)
- Y축: 개수
- 시리즈: 채취(mint) / 수정(teal) / 동결(blue) / 이식(purple)
- 범례 표시
- 데이터 없을 때 Empty 상태

---

## ViewModel

### `CycleRecordViewModel.swift`

경로: `Aran/Presentation/CycleRecord/CycleRecordViewModel.swift`

```swift
@MainActor
final class CycleRecordViewModel: ObservableObject {
    @Published var cycleRecords: [CycleRecord] = []
    @Published var transferRecords: [TransferRecord] = []
    @Published var pgtRecords: [PGTRecord] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private let cycleRecordUseCase: CycleRecordUseCase
    private let transferRecordUseCase: TransferRecordUseCase
    private let pgtRecordUseCase: PGTRecordUseCase

    // 주요 메서드
    func loadAll() async { ... }
    func saveCycleRecord(cycleNumber:, startDate:, retrievalCount:, fertilizedCount:, frozenCount:, embryoGrades:) async { ... }
    func saveTransferRecord(cycleRecordId:, transferDate:, embryoGrade:, embryoCount:, isFresh:) async { ... }
    func updateTransferResult(id:, result: TransferResult) async { ... }
    func savePGTRecord(cycleRecordId:, testDate:, type: PGTType, normalCount:, abnormalCount:, mosaicCount:, memo:) async { ... }
    func deleteCycleRecord(id:) async { ... }

    // 차트용 집계
    func chartData() -> [CycleChartEntry] { ... }
}
```

---

## 재사용할 기존 코드

Domain / Data 계층은 **건드리지 않는다**. 아래 파일들이 이미 완성되어 있다.

| 파일 | 경로 |
|------|------|
| `CycleRecordUseCase` | `Aran/Domain/UseCases/CycleRecordUseCase.swift` |
| `TransferRecordUseCase` | `Aran/Domain/UseCases/TransferRecordUseCase.swift` |
| `PGTRecordUseCase` | `Aran/Domain/UseCases/PGTRecordUseCase.swift` |
| `CycleRecord` entity | `Aran/Domain/Entities/CycleRecord.swift` |
| `TransferRecord` entity | `Aran/Domain/Entities/TransferRecord.swift` |
| `PGTRecord` entity | `Aran/Domain/Entities/PGTRecord.swift` |
| `CycleRecordRepository` | `Aran/Data/Repositories/CycleRecordRepository.swift` |
| `TransferRecordRepository` | `Aran/Data/Repositories/TransferRecordRepository.swift` |
| `ProcedureRecordSceneDIContainer` | `Aran/Application/DIContainer/ProcedureRecordSceneDIContainer.swift` |

DIContainer에 `PGTRecordUseCase` 주입이 빠져 있으면 추가한다.

---

## 아키텍처 규칙

1. **SwiftUI + Combine만 사용** — RxSwift 임포트 절대 금지
2. **Domain 레이어 변경 없음** — Presentation 파일만 신규 추가
3. **ViewModel → UseCase 경유** — Repository 직접 참조 금지
4. **UI 색상**: 시술 기록 탭 대표색 Teal `#1D9E75` (`AranColor.teal` 또는 `.procedureRecord`)
5. **Empty / Loading / Error 상태 필수** — 각 화면에 3가지 상태 구현
6. **삭제 시 확인 단계** — `confirmationDialog` 사용
7. **@MainActor** — ViewModel 전체에 선언

---

## 완료된 기능 (변경 없음)

| Feature | 스택 | 상태 |
|---------|------|------|
| Medication / Injection | UIKit + RxSwift | ✅ 완료 |
| Calendar (일부) | SwiftUI + Combine | ⚠️ 2단계 시트 미구현 |
| Health Record | UIKit + RxSwift | ⚠️ Swift Charts 미구현 |
| Drug Information | SwiftUI + Combine | ⚠️ 최근 검색어 미구현 |

---

## 테스트 현황

**71개 PASS (2026-05-26 기준)**

구현 완료 후 추가해야 할 테스트:
- `TransferRecordUseCaseTests` (Domain)
- `CycleRecordRepositoryTests` (Data)
- `TransferRecordRepositoryTests` (Data)
- `CycleRecordViewModelTests` (Presentation)

---

## 알려진 이슈

- CalendarView.swift: SourceKit 경고 다수 — 빌드/테스트는 정상. 무시해도 됨.

---

## 빌드 / 테스트

```bash
# 빌드
bash scripts/build-debug.sh

# 테스트
xcodebuild test -scheme Aran \
  -destination 'platform=iOS Simulator,OS=18.4,name=iPhone 16 Pro'
```

---

## 다음 작업 우선순위

1. **[현재]** 시술 기록 탭 Presentation 전체 구현 (이 HANDOFF)
2. 캘린더 탭 — 2단계 입력 시트 나머지
3. 검사 탭 — Swift Charts Line Chart, 수치 히스토리 화면
4. 약/주사 탭 — 알림 미리보기
5. 약 정보 탭 — 최근 검색어
6. 테스트 — Repository / ViewModel / UI Test
7. 앱 완성도 — 다크모드, 앱 아이콘, 스플래시
