# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `main`
- **전체 진행도**: MVP 기능 구현 완료. 테스트 코드와 앱 완성도 작업도 코드 기준 반영됨.
- **현재 작업**: 빌드/테스트 재검증 및 배포 관련 보류 항목 확인

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
| 단위 테스트 | 100% (UseCase/ViewModel) |
| UI 테스트 | 작성 완료 (실행은 사용자 확인 기준) |

---

## 최근 완료 작업 (main 기준)

| 작업 | 파일 | 상태 |
|------|------|------|
| 전문의약품 API 추가 (e약은요 fallback) | `Data/Network/DrugApprovalAPIClient.swift`, `DrugApprovalRouter.swift`, `DTOs/DrugApprovalDTO.swift` | ✅ |
| 즐겨찾기 기능 전체 스택 | `Domain/UseCases/FavoriteDrugUseCase.swift`, `Data/Repositories/FavoriteDrugRepository.swift`, `Presentation/DrugInfo/FavoriteDrugListView.swift` | ✅ |
| 감정일기 전체 Sheet 완성 | `Presentation/Calendar/CalendarView.swift` | ✅ |
| 캘린더 검사 탭 detail 추가 | `Presentation/Calendar/CalendarView.swift`, `CalendarViewModel.swift` | ✅ |
| 생리 주기 색상 커스터마이징 | `Assets.xcassets/dotHospital`, `dotPeriod`, `dotPeriodPredicted` | ✅ |
| 병원일정 SceneDelegate modelContainer 정리 | `Application/SceneDelegate.swift` | ✅ |
| TransferRecordUseCaseTests | `AranTests/UseCases/TransferRecordUseCaseTests.swift` | ✅ |
| CycleRecordRepositoryTests / TransferRecordRepositoryTests | `AranTests/Data/Repositories/` | ✅ |
| FavoriteDrugUseCaseTests / FavoriteDrugRepositoryTests | `AranTests/UseCases/`, `AranTests/Data/Repositories/` | ✅ |
| MenstrualCycleUseCaseTests / PGTRecordUseCaseTests / MedicationLogUseCaseTests | `AranTests/UseCases/` | ✅ |
| DrugApprovalRouterTests / DrugApprovalMapperTests | `AranTests/Data/Network/`, `AranTests/Data/Mappers/` | ✅ |
| CalendarViewModelTests | `AranTests/ViewModels/CalendarViewModelTests.swift` | ✅ |
| DrugInfoViewModelTests / ExamHistoryViewModelTests | `AranTests/ViewModels/` | ✅ |
| HealthRecordFormViewModelTests / HealthRecordViewModelTests | `AranTests/ViewModels/` | ✅ |

---

## 완료된 기능 전체

| Feature | 스택 | 상태 |
|---------|------|------|
| Calendar | SwiftUI + Combine | ✅ 완료 (감정일기·병원일정·생리주기·검사 detail 포함) |
| Medication / Injection | UIKit + RxSwift | ✅ 완료 (알림 ON/OFF 포함) |
| Health Record | UIKit + RxSwift + Swift Charts | ✅ 완료 (차트 + 히스토리 포함) |
| Procedure Record | SwiftUI + Combine + Swift Charts | ✅ 완료 |
| Drug Info | SwiftUI + Combine | ✅ 완료 (즐겨찾기 + 전문의약품 API + 최근 검색어 포함) |


---

## 테스트 현황


작성된 UI Test:
- `AranUITests/Flows/CalendarFlowUITests.swift`
- `AranUITests/Flows/MedicationFlowUITests.swift`
- `AranUITests/Flows/DrugSearchFlowUITests.swift`
- `AranUITests/Flows/ProcedureRecordFlowUITests.swift`
- `AranUITests/Flows/HealthRecordFlowUITests.swift`
- `AranUITests/TabNavigationUITests.swift`


---

## 빌드 / 테스트

```bash
# 빌드
bash scripts/build-debug.sh

# 테스트
xcodebuild test -scheme Aran \
  -destination 'platform=iOS Simulator,OS=26.4.1,name=iPhone 17'
```
