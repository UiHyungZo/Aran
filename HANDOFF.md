# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `feat/test`
- **전체 진행도**: Domain·Data·Application 계층 완료. Presentation 4탭 기본 구현. CycleRecord 탭 UI·캘린더 2단계 시트 미구현.
- **다음 단계**: 캘린더 탭 나머지 입력 시트 + 시술 기록 탭 Presentation 계층

### 레이어별 진척율

| 계층 / 탭 | 진척율 |
|-----------|--------|
| Domain 계층 | 100% |
| Data 계층 | 95% |
| Application 계층 | 100% |
| 📅 Calendar 탭 UI | 60% |
| 💊 Medication 탭 UI | 100% |
| 🧪 HealthRecord 탭 UI | 75% |
| 🔍 DrugInfo 탭 UI | 95% |
| 🗂 CycleRecord 탭 UI | 0% (Domain / Data는 100%) |
| 단위 테스트 | 60% |
| UI 테스트 | 0% |

---

## 캘린더 탭 PRD Gap 분석 (2026-05-27)

> PRD v14.0 업데이트 후 확인된 미구현 항목. Codex가 이 섹션을 참고해 구현한다.

### Gap 1 — 신규 Entity 4개 미존재

아래 4개 Entity와 각각의 Repository / UseCase / SwiftData Model / Mapper가 **모두 없음**.

#### 1-A. `HospitalVisit`
```swift
// Domain/Entities/HospitalVisit.swift
struct HospitalVisit: Identifiable {
    let id: UUID
    var visitDate: Date
    var visitTypes: [String]   // ["내원", "채혈", "초음파"] 복수 선택
    var memo: String?
}
```
- 현재 코드: `DayEvent.hospitalVisit(note: String?)` — visitTypes 배열 없음
- 필요 파일:
  - `Domain/Entities/HospitalVisit.swift`
  - `Domain/Repositories/HospitalVisitRepositoryProtocol.swift`
  - `Domain/UseCases/HospitalVisitUseCase.swift`
  - `Data/Local/HospitalVisitModel.swift` (SwiftData `@Model`)
  - `Data/Local/Mappers/HospitalVisitMapper.swift`
  - `Data/Repositories/HospitalVisitRepository.swift`

#### 1-B. `MenstrualCycle`
```swift
// Domain/Entities/MenstrualCycle.swift
struct MenstrualCycle: Identifiable {
    let id: UUID
    var startDate: Date
    var cycleLength: Int   // 기본 28
    // 배란 예정일 = startDate + (cycleLength - 14) — UseCase에서 계산
}
```
- 현재 코드: `DayEvent.periodStart` 이벤트만 존재 — cycleLength 없음
- `CycleRecordUseCase.estimateOvulation()` 고정 14일 사용 → cycleLength 반영하도록 수정
- 필요 파일: HospitalVisit과 동일 구조 (5파일)

#### 1-C. `MedicationLog`
```swift
// Domain/Entities/MedicationLog.swift
struct MedicationLog: Identifiable {
    let id: UUID
    var medicationId: UUID
    var logDate: Date    // 날짜만 사용, 시간 무시
    var isTaken: Bool
}
```
- 현재 코드: 완전 미존재
- 규칙: (medicationId, logDate) 쌍은 DB에 1개만 존재 — upsert 로직 필요
- `Medication` 삭제 시 해당 `MedicationLog`도 함께 삭제
- 필요 파일: 동일 구조 (5파일)

#### 1-D. `DiaryEntry` 독립 분리
```swift
// Domain/Entities/DiaryEntry.swift  ← 현재 CycleRecord.swift 안에 embedded
struct DiaryEntry: Identifiable {
    let id: UUID
    var date: Date
    var emoji: String?
    var content: String   // 최대 500자
}
```
- 현재 코드: `CycleRecord` 내부 nested struct (id, date 없음)
- `CycleRecord.diary: DiaryEntry?` 제거 → 별도 Repository로 관리
- 필요 파일: 동일 구조 (5파일)

---

### ✅ Gap 1 — 구현 완료 (2026-05-27)

아래 4개 Entity 세트는 **모두 생성 완료**. Codex는 재구현하지 않는다.

| Entity | Domain | Data | 상태 |
|--------|--------|------|------|
| `HospitalVisit` | Entity + Protocol + UseCase | SwiftData Model + Mapper + Repository | ✅ |
| `MenstrualCycle` | Entity + Protocol + UseCase | SwiftData Model + Mapper + Repository | ✅ |
| `MedicationLog` | Entity + Protocol + UseCase | SwiftData Model + Mapper + Repository | ✅ |
| `DiaryEntry` | Entity + Protocol + UseCase | SwiftData Model + Mapper + Repository | ✅ |

---

### ✅ Gap 2 — 1단계 시트 구현 완료 (2026-05-27)

`CalendarView.swift` 내 `dateSummaryPanel`이 PRD 5섹션 구조로 완성되어 있음.

| 섹션 | 현재 상태 |
|------|-----------|
| 병원 일정 | 요약 표시 (`visitTypes` joined) + "추가" 탭 시 `CalendarHospitalVisitFormSheet` 열림 ✅ |
| 복용 약 체크박스 | 각 약 옆 체크박스, `toggleMedicationLog` 연결 ✅ |
| 감정 일기 | 이모지 + 텍스트 인라인 오버레이 패널 (`diaryEditPanel`) ✅ |
| 검사 수치 | 요약 표시 + "추가" 탭 시 `CalendarHealthRecordInputSheet` 열림 ✅ |
| 생리 시작일 | 요약 표시 + "기록" 탭 시 `MenstrualCycleFormSheet` 열림 ✅ |

---

### ✅ Gap 3 — 2단계 시트 구현 완료 (2026-05-27)

모두 `CalendarView.swift` 내 `private struct`로 구현됨.

| 시트 | struct 이름 | 상태 |
|------|-------------|------|
| 병원 일정 추가/수정/삭제 | `CalendarHospitalVisitFormSheet` | ✅ |
| 검사 수치 입력 | `CalendarHealthRecordInputSheet` | ✅ |
| 생리 주기 입력 | `MenstrualCycleFormSheet` | ✅ (cycleLength + 배란 예정일 계산 포함) |

---

### ✅ Gap 6 — 병원 일정 수정/삭제 플로우 구현 완료 (2026-05-27)

> PRD: "2단계 시트 — 수정 가능 · 삭제 가능"  
> 기존 일정이 있으면 수정 모드로 열리고, 수정 모드에서는 삭제 버튼을 제공한다.

#### 6-A. `HospitalVisitUseCase` — 메서드 추가

파일: `Domain/UseCases/HospitalVisitUseCase.swift`

```swift
func update(_ visit: HospitalVisit) async throws {
    let types = visit.visitTypes.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    guard !types.isEmpty else {
        throw AppError.invalidInput("방문 유형을 1개 이상 선택해주세요.")
    }
    try await repository.update(visit)
}

func delete(id: UUID) async throws {
    try await repository.delete(id: id)
}
```

> `repository.update`와 `repository.delete`는 이미 `HospitalVisitRepository`에 구현되어 있음.  
> Protocol(`HospitalVisitRepositoryProtocol`)에도 선언되어 있음.

---

#### 6-B. `CalendarViewModel` — 메서드 추가

파일: `Presentation/Calendar/CalendarViewModel.swift`

```swift
func updateHospitalVisit(_ visit: HospitalVisit) async {
    do {
        try await hospitalVisitUseCase.update(visit)
        await loadMonthRecords()
        await loadRecord(for: selectedDate)
    } catch {
        errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
    }
}

func deleteHospitalVisit(id: UUID) async {
    do {
        try await hospitalVisitUseCase.delete(id: id)
        await loadMonthRecords()
        await loadRecord(for: selectedDate)
    } catch {
        errorMessage = (error as? AppError)?.errorDescription ?? error.localizedDescription
    }
}
```

---

#### 6-C. `CalendarHospitalVisitFormSheet` — 추가/수정 모드 통합

파일: `Presentation/Calendar/CalendarView.swift` 내 `private struct CalendarHospitalVisitFormSheet`

**현재 시그니처:**
```swift
private struct CalendarHospitalVisitFormSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTypes: Set<String> = ["내원"]
    @State private var memo = ""
    ...
```

**변경 후 시그니처:**
```swift
private struct CalendarHospitalVisitFormSheet: View {
    @ObservedObject var viewModel: CalendarViewModel
    @Environment(\.dismiss) private var dismiss
    let existingVisit: HospitalVisit?   // nil = 추가 모드, non-nil = 수정 모드

    @State private var selectedTypes: Set<String> = []
    @State private var memo = ""

    init(viewModel: CalendarViewModel, existingVisit: HospitalVisit? = nil) {
        self.viewModel = viewModel
        self.existingVisit = existingVisit
        _selectedTypes = State(initialValue: existingVisit.map { Set($0.visitTypes) } ?? ["내원"])
        _memo = State(initialValue: existingVisit?.memo ?? "")
    }
```

**저장 버튼 동작:**
```swift
Button("저장") {
    Task {
        let note = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        let memoValue = note.isEmpty ? nil : note
        if var visit = existingVisit {
            visit.visitTypes = Array(selectedTypes).sorted()
            visit.memo = memoValue
            await viewModel.updateHospitalVisit(visit)
        } else {
            await viewModel.saveHospitalVisit(
                visitTypes: Array(selectedTypes).sorted(),
                memo: memoValue
            )
        }
        dismiss()
    }
}
```

**삭제 버튼 — 수정 모드에서만 표시:**
```swift
// Form 마지막 Section에 추가
if let visit = existingVisit {
    Section {
        Button(role: .destructive) {
            Task {
                await viewModel.deleteHospitalVisit(id: visit.id)
                dismiss()
            }
        } label: {
            Text("일정 삭제")
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}
```

**navigationTitle 분기:**
```swift
.navigationTitle(existingVisit == nil ? "병원 일정 추가" : "병원 일정 수정")
```

---

#### 6-D. `CalendarView.dateSummaryPanel` — 1단계 시트 병원 일정 섹션 수정

파일: `Presentation/Calendar/CalendarView.swift`

**추가할 State:**
```swift
@State private var editingVisit: HospitalVisit? = nil
```

**summaryRow 탭 액션 변경 (현재 → 수정 후):**

현재:
```swift
summaryRow(title: "병원 일정", subtitle: hospitalSubtitle, actionLabel: "추가") {
    isHospitalFormPresented = true
}
```

수정 후:
```swift
let visits = viewModel.hospitalVisits(for: viewModel.selectedDate)
summaryRow(
    title: "병원 일정",
    subtitle: hospitalSubtitle,
    actionLabel: visits.isEmpty ? "추가" : "수정 >"
) {
    editingVisit = visits.first   // 없으면 nil → 추가 모드, 있으면 첫 번째 일정 → 수정 모드
    isHospitalFormPresented = true
}
```

**sheet 바인딩 변경:**

현재:
```swift
.sheet(isPresented: $isHospitalFormPresented) {
    CalendarHospitalVisitFormSheet(viewModel: viewModel)
}
```

수정 후:
```swift
.sheet(isPresented: $isHospitalFormPresented, onDismiss: { editingVisit = nil }) {
    CalendarHospitalVisitFormSheet(viewModel: viewModel, existingVisit: editingVisit)
}
```

---

### Gap 2 — 1단계 시트 (`DateDetailSheet`) UI 수정 (기존 메모)

> ✅ 완료됨 — 위 Gap 2 완료 현황 참고.

#### 2-B. 복용 약 체크박스 구현 상세
```swift
// 체크박스 외관
// 미선택: 회색 테두리 원
// 선택:   AranColor.dotMedication(Purple) fill + 흰색 내부 원
// 탭 시:  MedicationLogUseCase.toggle(medicationId:, date:) 호출
```

---

### Gap 3 — 2단계 시트 보완 (기존 메모)

> ✅ 완료됨 — 위 Gap 3 완료 현황 참고.

#### 3-A. 검사 수치 입력 시트
- 저장: `HealthRecordUseCase.save()` 재사용
- 삭제: `HealthRecordUseCase.delete(id:)` 재사용 (현재 미연결)

#### 3-C. 병원 일정 시트
- `visitTypes: [String]` chip 복수 선택 ✅ 구현됨
- 수정/삭제: ✅ 구현됨

---

### Gap 4 — 캘린더 도트 로직 업데이트

`CalendarView.swift` 내 `DayCell` 도트 표시 로직 수정 필요.

| 도트 | 색상 Asset | 현재 데이터 소스 | 변경 후 데이터 소스 |
|------|-----------|----------------|------------------|
| 병원 ● | `dotHospital` (Pink) | `DayEvent.hospitalVisit` | `HospitalVisit` entity |
| 약 ● | `dotMedication` (Purple) | Medication 스케줄 | 동일 유지 (MedicationLog 반영 불필요) |
| 이식 ● | `dotTransfer` (Teal) | `TransferRecord` ✅ | 변경 없음 |
| 배란 ● | `dotOvulation` (Amber) | 고정 14일 계산 | `MenstrualCycle.cycleLength` 기반 계산 |
| 생리 ■ | `dotPeriod` (Pink 50%) | periodStart 1일만 | startDate~startDate+cycleLength 기간 전체 |

`CalendarViewModel`에 `HospitalVisitUseCase`, `MenstrualCycleUseCase` 의존성 추가 필요.

---

### Gap 5 — DI Container 업데이트

`Application/DIContainer/CalendarSceneDIContainer.swift` 수정:
- `HospitalVisitUseCase` 인스턴스 생성 + `CalendarViewModel` 주입
- `MenstrualCycleUseCase` 인스턴스 생성 + `CalendarViewModel` 주입
- `MedicationLogUseCase` 인스턴스 생성 + `CalendarViewModel` 주입
- `DiaryUseCase` (DiaryEntry 분리 후) 인스턴스 생성 + 주입

---

### 구현 순서 (Codex 참고, 2026-05-27 기준)

> ✅ = 완료, ❌ = 미구현

1. ✅ **Entity + Repository + UseCase + SwiftData Model** 4세트 신규 파일 생성
2. ✅ `CalendarViewModel` — UseCase 8개 의존성 추가, save/toggle 메서드
3. ✅ `CalendarSceneDIContainer` — UseCase 주입
4. ✅ `dateSummaryPanel` (1단계 시트) — 5섹션 구조
5. ✅ `CalendarHospitalVisitFormSheet` — visitTypes chip 선택 + 수정/삭제 모드
6. ✅ `CalendarHealthRecordInputSheet` — 검사 수치 입력
7. ✅ `MenstrualCycleFormSheet` — cycleLength stepper + 배란 예정일
8. ✅ **Gap 6 — 병원 일정 수정/삭제** (상세 내용은 Gap 6 섹션 참고)
   - `HospitalVisitUseCase.update / delete` 추가
   - `CalendarViewModel.updateHospitalVisit / deleteHospitalVisit` 추가
   - `CalendarHospitalVisitFormSheet` 수정/삭제 모드 추가
   - `CalendarView.dateSummaryPanel` 병원 일정 탭 액션 분기

---

## 완료된 기능

| Feature | 스택 | 진척율 | 상태 |
|---------|------|--------|------|
| Calendar | SwiftUI + Combine | 65% | ⚠️ 도트/남은 PRD Gap 정리 필요 |
| Medication / Injection | UIKit + RxSwift | 100% | ✅ 완료 |
| Health Record | UIKit + RxSwift | 75% | ⚠️ 수정·커스텀 항목·Swift Charts·캘린더 연동 미구현 |
| Drug Information | SwiftUI + Combine | 95% | ⚠️ 최근 검색어 미구현 |
| CycleRecord / TransferRecord / PGTRecord | Domain + Data 계층 | 0% UI | ❌ Presentation 전체 미구현 |

> ⚠️ **중요**: 시술 기록 탭은 Domain Entity, Repository, UseCase, SwiftData 모델까지는 구현되어 있으나 Presentation 계층(화면, ViewModel, DIContainer)은 미구현 상태입니다.

---

## 🧪 검사 탭 — PRD 기준 미구현 항목

`PRD.md` / `features.md` 요구사항과 현재 구현 상태 대조 결과.

| # | PRD 요구사항 | 현재 상태 | 우선순위 |
|---|------------|---------|---------|
| 1 | 수치 **수정** | ❌ `ExamListViewController` swipe-to-delete만 구현, 수정 없음 | 1순위 |
| 2 | 커스텀 검사 항목 추가 (이름·단위 직접 입력) | ❌ `TestItem` 고정 enum (10개), 커스텀 추가 UI/로직 없음 | 1순위 |
| 3 | Swift Charts **Line Chart** (수치 변화) | ❌ `ExamHistoryViewController` 내 커스텀 `BarChartView(draw())` 사용 중 | 2순위 |
| 4 | 차트 **정상 범위 레퍼런스 라인** | ❌ 미구현 (FSH·AMH 등 항목별 기준값 없음) | 2순위 |
| 5 | 수치 **히스토리 화면** 완성 | ⚠️ `ExamHistoryViewController` 존재하나 Swift Charts 미적용, TODO 미완으로 마킹 | 2순위 |
| 6 | **캘린더 연동** (검사 수치) | ❌ 캘린더 2단계 시트 미구현 — 1단계 수치 요약·2단계 입력/수정 시트 모두 없음 | 2순위 |

### 관련 파일

| 파일 | 역할 |
|------|------|
| `Presentation/HealthRecord/ExamListViewController.swift` | 목록 화면 — 수정 진입점 추가 필요 |
| `Presentation/HealthRecord/HealthRecordFormViewController.swift` | 입력 폼 — 수정 모드(기존 record 주입) 지원 필요 |
| `Presentation/HealthRecord/ExamHistoryViewController.swift` | 히스토리 + 차트 — Swift Charts Line Chart로 교체 필요 |
| `Domain/Entities/HealthRecord.swift` | `TestItem` enum — 커스텀 항목 지원을 위한 `.custom(String)` 케이스 추가 필요 |
| `Application/HealthRecordFlowCoordinator.swift` | 수정 플로우 추가 필요 |

---

## 완료된 개선 사항

| 항목 | 내용 |
|------|------|
| CalendarView 약 도트 버그 | `DayCell`에 `hasMedication: Bool` 추가로 수정 |
| MedicationFormViewController | `MedicationFormActions` 패턴 적용 |
| MedicationFormSheet Coordinator | `UIViewControllerRepresentable.Coordinator` + `@Environment(\.dismiss)` 연결 |
| SceneDelegate | `.modelContainer` 중복 제거 |
| ExamListViewController | 구현 완성 확인 |
| UseCase Unit Tests | MedicationUseCase, HealthRecordUseCase, CycleRecordUseCase |

---

## 테스트 현황

**71개 PASS (2026-05-26 기준)**

| 분류 | 파일 | 상태 |
|------|------|------|
| UseCase | MedicationUseCase, HealthRecordUseCase, CycleRecordUseCase, SearchDrugUseCase, MedicationNotificationUseCase | ✅ |
| ViewModel | MedicationFormViewModel (6개) | ✅ |
| Repository | MedicationRepository, HealthRecordRepository, DrugRepository | ✅ |
| Network | DrugAPIClient, DrugRouter | ✅ |
| Mapper | MedicationMapper, DrugMapper | ✅ |
| UseCase | TransferRecordUseCase | ❌ 미구현 |
| Repository | CycleRecordRepository, TransferRecordRepository | ❌ 미구현 |
| ViewModel | CalendarViewModel, DrugInfoViewModel, ExamHistoryViewModel, HealthRecordFormViewModel, HealthRecordViewModel, PGTFormViewModel | ❌ 미구현 |
| UI Test | AranUITests 전체 | ❌ 템플릿만 존재 |

---

## PRD v14.0 변경사항 — 약/주사 탭 영향

| 변경 항목 | 내용 | 코드 반영 여부 |
|-----------|------|----------------|
| 탭 순서 변경 | 💊 약/주사 TAB 3 → TAB 2 | ✅ UI 순서 변경됨 |
| 약 셀 탭 → 수정 화면 신규 추가 | 목록에서 셀 탭 시 수정 폼으로 진입 | ❌ 미구현 |
| 알림 미리보기 | 알림 내용 미리보기 + 개별 ON/OFF | ❌ 미구현 (기존 TODO 유지) |

### 약 셀 탭 → 수정 화면 구현 대상 파일

| 파일 | 변경 내용 |
|------|-----------|
| `MedicationFlowCoordinator.swift` | `MedicationListActions`에 `showEdit: (Medication) -> Void` 추가, `showEdit(medication:)` 메서드 구현 |
| `MedicationListViewController.swift` | `tableView(_:didSelectRowAt:)` 구현, `editRelay` 추가 |
| `MedicationFormViewController.swift` | `initialMedication: Medication?` 파라미터 추가, 모든 필드 초기값 바인딩 (type/startDate/endDate/times/isNotification), 타이틀 분기 |
| `MedicationFormViewModel.swift` | `Medication.id` 보유 여부로 `save()` / `update()` 분기 처리 |
| `MedicationSceneDIContainer.swift` | `makeEditFormViewController(medication:actions:)` 팩토리 메서드 추가 |

---

## 알려진 이슈

### 🟡 IDE 진단 경고 (CalendarView.swift)

- SourceKit 오류 다수 (`CalendarViewModel`, `AranFont`, `AranColor` 스코프 인식 실패)
- 빌드 및 테스트 자체는 정상 (`xcodebuild test` → TEST SUCCEEDED)
- 타겟 멤버십 또는 모듈 임포트 문제일 가능성 — Xcode에서 직접 확인 필요

---

## 브랜치 현황

| 브랜치 | 역할 | 상태 |
|--------|------|------|
| `feat/test` | 현재 작업 브랜치 | 진행 중 |
| `develop` | 통합 브랜치 | `dfdd6fc` 기준 |

---

## 다음 작업

`TODO.md` 미완료 항목 참고. 우선순위 순서:

1. 캘린더 탭 — 감정 일기 / 병원 일정 / 생리 주기 입력 시트
2. 시술 기록 탭 — Presentation 계층 전체 (SwiftUI + Combine + Swift Charts)
3. 검사 탭 — Swift Charts Line Chart, 수치 히스토리 화면
4. 약/주사 탭 — 약 셀 탭 → 수정 화면 (v14.0 신규, 미구현)
5. 약/주사 탭 — 알림 미리보기
6. 약 정보 탭 — 최근 검색어
7. 테스트 — Repository / ViewModel / UI Test 전 레이어
8. 앱 완성도 — 다크모드, 앱 아이콘, 스플래시
9. 앱스토어 배포

---

## 빌드 / 테스트

```bash
# 빌드
bash scripts/build-debug.sh

# 테스트
xcodebuild test -scheme Aran \
  -destination 'platform=iOS Simulator,OS=18.4,name=iPhone 16 Pro'
```
