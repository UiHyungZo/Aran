# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `develop1`
- **전체 진행도**: 전체 기능 구현 완료. 테스트 보강 및 앱 완성도(다크모드·아이콘) 작업 중.
- **현재 작업**: 테스트 보강 → 앱 완성도 → 배포 준비

### 레이어별 진척율

| 계층 / 탭 | 진척율 |
|-----------|--------|
| Domain 계층 | 100% |
| Data 계층 | 100% |
| Application 계층 | 100% |
| 📅 Calendar 탭 UI | 100% |
| 💊 Medication 탭 UI | 100% |
| 🏥 HealthRecord 탭 UI | 100% |
| 🔍 DrugInfo 탭 UI | 100% |
| 🗂 ProcedureRecord 탭 UI | 100% |
| 단위 테스트 | 60% |
| UI 테스트 | 0% |

---

## 최근 완료 작업 (develop1 머지 기준)

| 작업 | 파일 | 상태 |
|------|------|------|
| TransferInputFormView 머지 버그 수정 | `Presentation/ProcedureRecord/TransferInputFormView.swift` | ✅ |
| Swift Charts Line Chart (검사 탭) | `Presentation/HealthRecord/ExamChartView.swift` (신규) | ✅ |
| 수치 히스토리 화면 완성 | `Presentation/HealthRecord/ExamHistoryViewController.swift` | ✅ |
| 알림 개별 ON/OFF | `Presentation/Medication/MedicationListViewController.swift` | ✅ |
| 최근 검색어 (UserDefaults) | `Presentation/DrugInfo/DrugInfoViewModel.swift` | ✅ |
| build-debug.sh 시뮬레이터 버전 수정 | `scripts/build-debug.sh` | ✅ |
| 전체 화면 키보드 Dismiss UX 개선 | `DrugSearchView`, `CalendarView`, `DateDetailSheet`, `CycleRecordFormView`, `ProcedurePGTFormView`, `TransferInputFormView`, `MedicationFormViewController`, `HealthRecordFormViewController` | ✅ |

---

## 완료된 기능 전체

| Feature | 스택 | 상태 |
|---------|------|------|
| Calendar | SwiftUI + Combine | ✅ 완료 |
| Medication / Injection | UIKit + RxSwift | ✅ 완료 (알림 ON/OFF 포함) |
| Health Record | UIKit + RxSwift + Swift Charts | ✅ 완료 (차트 + 히스토리 포함) |
| Procedure Record | SwiftUI + Combine + Swift Charts | ✅ 완료 |
| Drug Info | SwiftUI + Combine | ✅ 완료 (최근 검색어 포함) |

---

## 알려진 이슈

- CalendarView.swift: SourceKit 경고 다수 — 빌드/테스트는 정상. 무시해도 됨.
- `.scrollDismissesKeyboard(.interactively)` iOS 26 시뮬레이터에서 미작동 확인. `keyboard.md` v3 기준으로 `.immediately` 교체 필요 (Codex 작업 예정).

---

## 테스트 현황

**71개 PASS (마지막 실행 기준)**

### 미작성 테스트

| 대상 | 파일 경로 |
|------|-----------|
| `TransferRecordUseCaseTests` | `AranTests/UseCases/TransferRecordUseCaseTests.swift` |
| `CycleRecordRepositoryTests` | `AranTests/Repositories/CycleRecordRepositoryTests.swift` |
| `TransferRecordRepositoryTests` | `AranTests/Repositories/TransferRecordRepositoryTests.swift` |
| `CalendarViewModelTests` | `AranTests/ViewModels/CalendarViewModelTests.swift` |
| `DrugInfoViewModelTests` | `AranTests/ViewModels/DrugInfoViewModelTests.swift` |
| `ExamHistoryViewModelTests` | `AranTests/ViewModels/ExamHistoryViewModelTests.swift` |
| `HealthRecordFormViewModelTests` | `AranTests/ViewModels/HealthRecordFormViewModelTests.swift` |
| `HealthRecordViewModelTests` | `AranTests/ViewModels/HealthRecordViewModelTests.swift` |
| UI Test 전체 | 캘린더 / 약 등록 / 약 검색 / 채취·이식 / 검사 수치 플로우 |

테스트 작성 시 `AranTests/Mocks/` 하위 Mock 파일과 `MedicationFormViewModelTests` 패턴 참조.

---

## 다음 작업 우선순위

1. **테스트** — TransferRecordUseCase → Repository (Cycle·Transfer) → ViewModel 5개 → UI Test
2. **앱 완성도** — 다크모드 커스텀 컬러 Assets Light/Dark, Swift Charts 다크모드 색상
3. **앱 아이콘** — 1024×1024 마스터 에셋, Xcode AppIcon 슬롯 전체
4. **스플래시** — LaunchScreen.storyboard 앱 아이콘 중앙 배치
5. **배포 준비** — 개인정보처리방침 URL, 앱 메타데이터, 스크린샷 5장, TestFlight 제출

---

## 빌드 / 테스트

```bash
# 빌드
bash scripts/build-debug.sh

# 테스트
xcodebuild test -scheme Aran \
  -destination 'platform=iOS Simulator,OS=18.4,name=iPhone 16 Pro'
```
