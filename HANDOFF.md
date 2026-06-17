# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `develop`
- **전체 진행도**: 전체 기능 + 단위/UI 테스트 + 앱 완성도 + 아키텍처 개선 완료.
- **현재 작업**: 없음 (앱스토어 배포는 MVP 결정상 제외)

### 레이어별 진척율

| 계층 / 탭 | 진척율 | 비고 |
|-----------|--------|------|
| Domain 계층 | 100% | `Packages/AranDomain/` SPM 패키지 |
| Data 계층 | 100% | `Packages/AranData/` SPM 패키지 |
| Application 계층 | 100% | |
| 📅 Calendar 탭 UI | 100% | |
| 💊 Medication 탭 UI | 100% | |
| 🏥 HealthRecord 탭 UI | 100% | |
| 🔍 DrugInfo 탭 UI | 100% | |
| 🗂 ProcedureRecord 탭 UI | 100% | |
| 단위 테스트 | 100% | UseCase/ViewModel/Repository/Mapper/Network |
| UI 테스트 | 100% | 탭 네비게이션 + 5개 플로우 |

---

## 최근 완료 작업 (spm 브랜치, 2026-06-17)

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
| AranDomain SPM 로컬 패키지 분리 (Phase 1) | `Packages/AranDomain/` | ✅ |
| AranData SPM 로컬 패키지 분리 (Phase 2) | `Packages/AranData/` | ✅ |
| AranDomain testTarget 추가 + UseCase 테스트 이동 (Phase 3) | `Packages/AranDomain/Package.swift`, `Packages/AranDomain/Tests/AranDomainTests/` | ✅ |
| GitHub Actions CI | `.github/workflows/ci.yml` | ✅ |
| MedicationFlowCoordinator delete 아키텍처 수정 | `Application/MedicationFlowCoordinator.swift`, `Presentation/Medication/MedicationFormViewModel.swift` | ✅ |
| DrugInfoViewModelTests:220 플레이키 수정 | `Presentation/DrugInfo/DrugInfoViewModel.swift` | ✅ |
| View save 로직 → ViewModel 이동 | `Presentation/ProcedureRecord/ProcedureRecordViewModel.swift`, `TransferInputFormView.swift`, `ProcedurePGTFormView.swift` | ✅ |
| API Key 보안 (Secrets.xcconfig 분리) | `Aran/Configuration/Secrets.xcconfig`, `.gitignore`, `project.pbxproj` | ✅ |

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

## 아키텍처 메모

### SPM 패키지 구조
```
Packages/
├── AranDomain/   — Domain Entity, UseCase 구현체, Repository Protocol (외부 프레임워크 의존 없음)
│   └── Tests/AranDomainTests/  — UseCase 13개 + Mock 23개 (swift test로 단독 실행 가능)
└── AranData/     — Repository 구현체, Network, SwiftData @Model, Mapper (Alamofire 의존)
```
`Presentation` 레이어가 Repository 구현체를 직접 import하면 컴파일 에러 발생 → 아키텍처 경계 컴파일러 강제.

### CI (GitHub Actions)
`.github/workflows/ci.yml` — push/PR 시 자동 실행:
- `domain-test`: `swift test --package-path Packages/AranDomain` (UseCase 96개, simulator 불필요)
- `unit-test`: `xcodebuild test -scheme AranTests` (Data + ViewModel 테스트)

### API Key 온보딩
새 맥북/클론 시 1회 필요:
```bash
cp Aran/Configuration/Secrets.xcconfig.example Aran/Configuration/Secrets.xcconfig
# DRUG_API_DECODING / ENCODING / PRDT_DECODING / PRDT_ENCODING 4개 키 입력
# 키 발급: 공공데이터포털(data.go.kr)
```
이후 git pull 시 재작업 불필요 (gitignore 처리됨).

---

## 알려진 이슈

- CalendarView.swift: SourceKit 경고 다수 — 빌드/테스트는 정상. 무시해도 됨.
- ~~`.scrollDismissesKeyboard(.interactively)` iOS 26 시뮬레이터에서 미작동~~ → `.immediately`로 교체 완료 (해결됨).

---

## 테스트 현황

**마지막 실행 기준 전체 PASS**

| 위치 | 실행 방법 | 포함 범위 | 결과 |
|------|-----------|-----------|------|
| `Packages/AranDomain/Tests/` | `swift test --package-path Packages/AranDomain` | UseCase 13개 (96 테스트) | ✅ PASS |
| `AranTests/` | `xcodebuild test -scheme AranTests` | Data Mapper/Repository/Network + ViewModel | ✅ PASS |
| `AranUITests/` | `xcodebuild test -scheme Aran` | 탭 네비게이션 + 5개 Flow | ✅ PASS |

**UseCase 테스트 위치 주의**: `AranTests/UseCases/`는 비어있음. UseCase 테스트는 `Packages/AranDomain/Tests/AranDomainTests/` 에 있음.
Mock 추가 시 `Packages/AranDomain/Tests/AranDomainTests/Mocks/` 참조.

---

## 다음 작업 우선순위

현재 추가 작업 없음. 프로젝트 완성 상태.

가능한 선택지:
- Phase 3: AranPresentation SPM 분리 (고난이도 — Coordinator/DI 경계 정리 필요)
- README 온보딩 절차 업데이트 (Secrets.xcconfig 설정 방법 추가)

---

## 빌드 / 테스트

```bash
# 빌드
bash scripts/build-debug.sh

# Domain 테스트 (simulator 없이, 빠름)
DEVELOPER_DIR=/Applications/Xcode-26.4.1.app/Contents/Developer \
  swift test --package-path Packages/AranDomain

# Unit 테스트 (AranTests scheme)
xcodebuild test -scheme AranTests \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=latest'

# 전체 테스트 (Unit + UI)
xcodebuild test -scheme Aran \
  -destination 'platform=iOS Simulator,OS=26.4.1,name=iPhone 17'
```

> **주의**: `xcode-select -p`가 CommandLineTools를 가리키면 `DEVELOPER_DIR` 설정 필요.
