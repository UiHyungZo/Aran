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

## 완료된 기능

| Feature | 스택 | 진척율 | 상태 |
|---------|------|--------|------|
| Calendar | SwiftUI + Combine | 60% | ⚠️ 2단계 시트 미구현 |
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
3. 검사 탭 (1순위: 수치 수정, 커스텀 항목 추가 / 2순위: Swift Charts Line Chart + 정상 범위 레퍼런스 라인, 수치 히스토리 화면, 캘린더 연동)
4. 약/주사 탭 — 알림 미리보기
5. 약 정보 탭 — 최근 검색어
6. 테스트 — Repository / ViewModel / UI Test 전 레이어
7. 앱 완성도 — 다크모드, 앱 아이콘, 스플래시
8. 앱스토어 배포

---

## 빌드 / 테스트

```bash
# 빌드
bash scripts/build-debug.sh

# 테스트
xcodebuild test -scheme Aran \
  -destination 'platform=iOS Simulator,OS=18.4,name=iPhone 16 Pro'
```
