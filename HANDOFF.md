# Coordinator 개선 HANDOFF

3개 에이전트(ios-error-analyzer, swift-uikit-reviewer, uikit-feature-implementer) 병렬 분석 결과 종합.

---

## 현재 문제

| 문제 | 위치 | 심각도 |
|------|------|--------|
| `dismissSelf()`가 pop/dismiss를 직접 판단 | `MedicationFormViewController.swift:343` | 🔴 Coordinator 패턴 위반 |
| Coordinator 없이 VC를 직접 생성 | `MedicationFormSheet.swift:10` | 🟡 구조적 문제 |
| 프로토콜 시그니처 미동기화 | `MedicationSceneDIContainer.swift:58` | 🟡 Actions 추가 시 컴파일 에러 |

---

## 작업 1: MedicationFormActions 패턴

**변경 파일**: `MedicationFlowCoordinator.swift`, `MedicationFormViewController.swift`, `MedicationSceneDIContainer.swift`

### MedicationFlowCoordinator.swift

파일 상단(기존 Actions 구조체들 아래)에 추가:

```swift
struct MedicationFormActions {
    let onCancel: () -> Void
    let onSaveCompleted: () -> Void
}
```

프로토콜 시그니처 변경:

```swift
func makeMedicationFormViewController(
    drugName: String,
    dosage: String,
    actions: MedicationFormActions   // 추가
) -> MedicationFormViewController
```

`showForm()` 내 Actions 생성:

```swift
private func showForm(drugName: String, dosage: String) {
    let actions = MedicationFormActions(
        onCancel: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        },
        onSaveCompleted: { [weak self] in
            // Search → Form 2단계 push이므로 목록까지 한 번에 복귀
            self?.navigationController?.popToRootViewController(animated: true)
        }
    )
    let vc = dependencies.makeMedicationFormViewController(
        drugName: drugName, dosage: dosage, actions: actions
    )
    navigationController?.pushViewController(vc, animated: true)
}
```

### MedicationFormViewController.swift

```swift
// 추가
private let actions: MedicationFormActions

// init 변경 (viewModel 다음, initialDrugName 앞)
init(viewModel: MedicationFormViewModel,
     actions: MedicationFormActions,
     initialDrugName: String = "",
     initialDosage: String = "")

// cancelTapped 변경
@objc private func cancelTapped() {
    actions.onCancel()
}

// saveCompleted 바인딩 변경
output.saveCompleted
    .drive(onNext: { [weak self] in
        self?.actions.onSaveCompleted()
    })
    .disposed(by: disposeBag)

// dismissSelf() 메서드 전체 삭제
```

### MedicationSceneDIContainer.swift

```swift
func makeMedicationFormViewController(
    drugName: String,
    dosage: String,
    actions: MedicationFormActions   // 추가
) -> MedicationFormViewController {
    MedicationFormViewController(
        viewModel: MedicationFormViewModel(medicationUseCase: medicationUseCase),
        actions: actions,             // 추가
        initialDrugName: drugName,
        initialDosage: dosage
    )
}
```

---

## 작업 2: MedicationFormSheet Coordinator 연결

**변경 파일**: `MedicationFormSheet.swift` 단독  
**MainTabView.swift 변경 없음** — 기존 `isPresented` binding이 dismiss를 이미 처리

```swift
struct MedicationFormSheet: UIViewControllerRepresentable {
    let drugName: String
    let container: MedicationSceneDIContainer
    @Environment(\.dismiss) private var dismiss

    final class Coordinator {
        let dismiss: DismissAction
        init(dismiss: DismissAction) { self.dismiss = dismiss }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let actions = MedicationFormActions(
            onCancel: { context.coordinator.dismiss() },
            onSaveCompleted: { context.coordinator.dismiss() }
        )
        let vc = container.makeMedicationFormViewController(
            drugName: drugName, dosage: "", actions: actions
        )
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
```

> `MedicationFlowCoordinator.startFormSheet()` 신설 불필요.  
> Sheet는 단일 VC 흐름이므로 Coordinator 없이 Actions 직접 구성이 더 단순함.

---

## 작업 3: HealthRecord — 이번 범위 아님

`ExamListViewController`가 빈 껍데기 상태. 목록 구현 완료 후 아래 패턴 동일 적용:
- `ExamListActions(showDetail: (HealthRecord) -> Void)` 구조체 추가
- `HealthRecordFlowCoordinator.showDetail()` 메서드 추가
- `HealthRecordFlowCoordinatorDependencies` 프로토콜에 `makeExamDetailViewController(record:)` 추가

---

## 작업 순서 및 주의사항

```
작업 1 (3파일 동시) → 작업 2 → 빌드 검증
```

- 작업 1의 3파일은 **원자적으로 함께 변경**해야 중간 빌드 실패 없음
- 작업 2는 반드시 작업 1 완료 후 진행 (시그니처 의존)
- `MedicationFormViewModelTests` — 영향 없음 (ViewModel만 직접 테스트)

---

## 빌드 검증 명령어

```bash
DEVELOPER_DIR=/Applications/Xcode-26.4.1.app/Contents/Developer \
  xcodebuild -scheme Aran -destination 'generic/platform=iOS Simulator' build 2>&1 | tail -5
```

### 검증 시나리오

| 시나리오 | 기대 결과 |
|----------|-----------|
| 약 정보 탭 → 약 선택 → Sheet → 취소 | Sheet 닫힘 |
| 약 정보 탭 → 약 선택 → Sheet → 저장 | Sheet 닫힘 |
| 약 탭 → 검색 → 약 선택 → Form → 취소 | 검색 화면 복귀 |
| 약 탭 → 검색 → 약 선택 → Form → 저장 | 목록 화면 복귀 |
