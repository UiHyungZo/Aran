# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `develop`
- **전체 진행도**: 전체 기능 + 단위/UI 테스트 + 앱 완성도(다크모드·아이콘·스플래시) 완료.
- **현재 작업**: 앱스토어 배포 준비 (개인정보처리방침, 메타데이터, 스크린샷, TestFlight)

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
| 단위 테스트 | 100% (UseCase/ViewModel/Repository/Mapper/Network) |
| UI 테스트 | 100% (탭 네비게이션 + 5개 플로우) |

---

## 최근 완료 작업 (main 기준)

| 작업 | 파일 | 상태 |
|------|------|------|
| Repository async/await 전환 | `Data/Repositories/` | ✅ |
| 단위 테스트 보강 (DiaryEntry/HospitalVisit UseCase, Medication/ProcedureRecord ViewModel 등) | `AranTests/` | ✅ |
| UI Test 작성 (탭 네비게이션 + 캘린더/약 검색/약·주사/검사/시술 기록 플로우) | `AranUITests/TabNavigationUITests.swift`, `AranUITests/Flows/` | ✅ |
| 앱 아이콘 (single-size 1024 universal) / 스플래시 (LaunchScreen + SplashContainerView) | `Assets.xcassets/AppIcon.appiconset`, `Base.lproj/LaunchScreen.storyboard`, `Presentation/Common/SplashContainerView.swift` | ✅ |
| 다크모드 커스텀 컬러 Light/Dark 정의 | `Assets.xcassets/*.colorset` | ✅ |
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

## 알려진 이슈

- CalendarView.swift: SourceKit 경고 다수 — 빌드/테스트는 정상. 무시해도 됨.
- ~~`.scrollDismissesKeyboard(.interactively)` iOS 26 시뮬레이터에서 미작동~~ → `.immediately`로 교체 완료 (해결됨).

---

## 테스트 현황

**마지막 실행 기준 전체 PASS (정확한 수는 `xcodebuild test` 실행 후 확인)**

- 단위 테스트: UseCase 13 / ViewModel 8 / Repository 12 / Mapper 13 / Network 4 테스트 파일
- UI 테스트: `TabNavigationUITests` + `Flows/` 5개 (캘린더 / 약 검색 / 약·주사 / 검사 / 시술 기록)

미작성 테스트 없음. 테스트 추가 시 `AranTests/Mocks/` 하위 Mock 파일과 `MedicationFormViewModelTests` 패턴 참조.

---

## 다음 작업 우선순위

1. **개인정보처리방침 URL** — GitHub Pages 또는 Notion
2. **앱 메타데이터** — 이름, 설명, 키워드, 카테고리 (의료/건강)
3. **앱스토어 스크린샷** — iPhone 6.5인치 / 5.5인치 규격, 주요 화면 5장
4. **TestFlight 내부 테스트 → 심사 제출**

---

## 빌드 / 테스트

```bash
# 빌드
bash scripts/build-debug.sh

# 테스트
xcodebuild test -scheme Aran \
  -destination 'platform=iOS Simulator,OS=26.4.1,name=iPhone 17'
```
