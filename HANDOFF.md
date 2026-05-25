# Aran · Project HANDOFF

## 현재 상태

- **활성 브랜치**: `feat/Calendar`
- **전체 진행도**: MVP 1순위 기능 구현 완료 / 안정화 단계 진입
- **다음 단계**: UseCase 테스트 작성 → 구조 버그 수정 → UI 폴리시

---

## 완료된 기능

| Feature | 스택 | 상태 |
|---------|------|------|
| Calendar | SwiftUI + Combine | ✅ 완료 |
| Medication / Injection | UIKit + RxSwift | ✅ 완료 |
| Health Record | UIKit + RxSwift | ✅ 완료 |
| Drug Information | SwiftUI + Combine | ✅ 완료 |
| Transfer / Retrieval Record | Domain + Data 계층 | ✅ 완료 (Calendar에 표시) |

---

## 미커밋 변경사항

| 파일 | 내용 |
|------|------|
| `Aran/Application/SceneDelegate.swift` | `.modelContainer(modelContainer)` 중복 제거 — DI에서 이미 관리하므로 삭제 |

---

## 알려진 이슈

### 🔴 구조 버그

**MedicationFormViewController.dismissSelf()**

- 위치: `Aran/Presentation/Medication/MedicationFormViewController.swift:343`
- 문제: ViewController가 pop/dismiss를 직접 판단 → Coordinator 패턴 위반
- 수정 방향: `MedicationFormActions` 패턴 도입 (onCancel, onSaveCompleted 콜백)
- 영향 파일: `MedicationFlowCoordinator.swift`, `MedicationFormViewController.swift`, `MedicationSceneDIContainer.swift`

**MedicationFormSheet Coordinator 미연결**

- 위치: `Aran/Presentation/Common/Bridging/MedicationFormSheet.swift`
- 문제: VC를 Coordinator 없이 직접 생성
- 수정 방향: `UIViewControllerRepresentable.Coordinator` 구현 + `@Environment(\.dismiss)` 연결

### 🟡 미확인 구현

- `ExamListViewController` — 구현 완성도 확인 필요
- UseCase 테스트 커버리지 부족 (MedicationUseCase, HealthRecordUseCase, CycleRecordUseCase)

---

## 브랜치 현황

| 브랜치 | 역할 | 상태 |
|--------|------|------|
| `feat/Calendar` | 캘린더 기능 | 진행 중 (현재) |
| `feat/coordinator` | Coordinator 패턴 개선 | 작업 준비 중 (워크트리) |
| `develop` | 통합 브랜치 | `dfdd6fc` 기준 |

---

## 다음 작업 순서

```
1. SceneDelegate.swift 미커밋 변경 커밋
2. UseCase Unit Test 작성
3. MedicationFormActions 패턴 적용 (Coordinator 버그 수정)
4. MedicationFormSheet Coordinator 연결
5. ExamListViewController 구현 확인/완성
6. MVP 2순위 기능 (감정일기, 병원 일정 등)
```

→ 자세한 목록은 `TODO.md` 참고

---

## 빌드 / 테스트

```bash
# 빌드
xcodebuild -scheme Aran

# 테스트
xcodebuild test -scheme Aran
```
