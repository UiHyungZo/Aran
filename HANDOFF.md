# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `feat/drugInjection`
- **전체 진행도**: Domain·Data·Application 계층 완료. Presentation 4탭 기본 구현. CycleRecord 탭 UI·캘린더 2단계 시트 미구현.
- **다음 단계**: 캘린더 탭 나머지 입력 시트 + 시술 기록 탭 Presentation 계층

### 레이어별 진척율

| 계층 / 탭 | 진척율 |
|-----------|--------|
| Domain 계층 | 100% |
| Data 계층 | 95% |
| Application 계층 | 100% |
| 📅 Calendar 탭 UI | 60% |
| 💊 Medication 탭 UI | 85% |
| 🧪 HealthRecord 탭 UI | 85% |
| 🔍 DrugInfo 탭 UI | 95% |
| 🗂 CycleRecord 탭 UI | 0% (Domain / Data는 100%) |
| 단위 테스트 | 60% |
| UI 테스트 | 0% |

---

## 완료된 기능

| Feature | 스택 | 진척율 | 상태 |
|---------|------|--------|------|
| Calendar | SwiftUI + Combine | 60% | ⚠️ 2단계 시트 미구현 |
| Medication / Injection | UIKit + RxSwift | 85% | ⚠️ 약 셀 탭 수정 화면 미구현 |
| Health Record | UIKit + RxSwift | 85% | ⚠️ Swift Charts 미구현 |
| Drug Information | SwiftUI + Combine | 95% | ⚠️ 최근 검색어 미구현 |
| CycleRecord / TransferRecord / PGTRecord | Domain + Data 계층 | 0% UI | ❌ Presentation 전체 미구현 |

> ⚠️ **중요**: 시술 기록 탭은 Domain Entity, Repository, UseCase, SwiftData 모델까지는 구현되어 있으나 Presentation 계층(화면, ViewModel, DIContainer)은 미구현 상태입니다.

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
| `feat/drugInjection` | 현재 작업 브랜치 | 진행 중 |
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
