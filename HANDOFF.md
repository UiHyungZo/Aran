# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `develop`
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
| 단위 테스트 | 100% (UseCase/ViewModel) |
| UI 테스트 | 0% |

---

## 최근 완료 작업 (develop 기준)

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

## 알려진 이슈

- CalendarView.swift: SourceKit 경고 다수 — 빌드/테스트는 정상. 무시해도 됨.
- `.scrollDismissesKeyboard(.interactively)` iOS 26 시뮬레이터에서 미작동 확인. `keyboard.md` v3 기준으로 `.immediately` 교체 필요.

---

## 테스트 현황

**마지막 실행 기준 PASS (정확한 수는 `xcodebuild test` 실행 후 확인)**

### 미작성 테스트

| 대상 | 파일 경로 |
|------|-----------|
| UI Test 전체 | 캘린더 / 약 등록 / 약 검색 / 채취·이식 / 검사 수치 플로우 |

테스트 작성 시 `AranTests/Mocks/` 하위 Mock 파일과 `MedicationFormViewModelTests` 패턴 참조.

---

## 다음 작업 우선순위

1. **테스트** — UI Test (캘린더 / 약 등록 / 약 검색 / 채취·이식 / 검사 수치 플로우)
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
