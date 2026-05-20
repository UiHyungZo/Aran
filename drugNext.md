# 약/주사 탭 개발 이어하기

## 완료된 작업

| 파일 | 상태 |
|------|------|
| `Aran/DIContainer.swift` | ✅ Medication 의존성 추가 완료 |
| `Aran/Presentation/Medication/MedicationFormViewModel.swift` | ✅ 신규 생성 완료 |
| `Aran/Presentation/Medication/MedicationFormViewController.swift` | ✅ 신규 생성 완료 |

---

## 남은 작업

### 1. MedicationListViewController 완성
**파일**: `Aran/Presentation/Medication/MedicationListViewController.swift`

현재 17줄짜리 스켈레톤을 아래 코드로 **전체 교체**:

```swift
import UIKit
import RxSwift
import RxCocoa

final class MedicationListViewController: UIViewController {
    private let viewModel: MedicationViewModel
    private let medicationUseCase: MedicationUseCase
    private let disposeBag = DisposeBag()

    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private let toggleRelay = PublishRelay<Medication>()
    private let deleteRelay = PublishRelay<Medication>()
    private let viewWillAppearSubject = PublishSubject<Void>()

    private var medications: [Medication] = []

    init(viewModel: MedicationViewModel, medicationUseCase: MedicationUseCase) {
        self.viewModel = viewModel
        self.medicationUseCase = medicationUseCase
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewWillAppearSubject.onNext(())
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "약/주사"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        tableView.register(MedicationCell.self, forCellReuseIdentifier: MedicationCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        activityIndicator.hidesWhenStopped = true

        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func bindViewModel() {
        let input = MedicationViewModel.Input(
            viewDidLoad: viewWillAppearSubject.asObservable(),
            toggleMedication: toggleRelay.asObservable(),
            deleteMedication: deleteRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.medications
            .drive(onNext: { [weak self] medications in
                self?.medications = medications
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        output.error
            .filter { !$0.isEmpty }
            .drive(onNext: { [weak self] message in
                let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }

    @objc private func addTapped() {
        let formVM = MedicationFormViewModel(medicationUseCase: medicationUseCase)
        let formVC = MedicationFormViewController(viewModel: formVM)
        navigationController?.pushViewController(formVC, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension MedicationListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        medications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MedicationCell.reuseIdentifier,
            for: indexPath
        ) as? MedicationCell else {
            return UITableViewCell()
        }
        let medication = medications[indexPath.row]
        cell.configure(with: medication)
        cell.onToggle = { [weak self] _ in
            self?.toggleRelay.accept(medication)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MedicationListViewController: UITableViewDelegate {
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let medication = medications[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            self?.deleteRelay.accept(medication)
            completion(true)
        }

        let toggleTitle = medication.isEnabled ? "중단" : "재개"
        let toggleAction = UIContextualAction(style: .normal, title: toggleTitle) { [weak self] _, _, completion in
            self?.toggleRelay.accept(medication)
            completion(true)
        }
        toggleAction.backgroundColor = .systemOrange

        return UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
    }
}
```

---

### 2. MedicationListWrapper 수정
**파일**: `Aran/Presentation/Common/Bridging/MedicationListWrapper.swift`

```swift
import SwiftUI
import UIKit

struct MedicationListWrapper: UIViewControllerRepresentable {
    let container: DIContainer

    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: container.makeMedicationListViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
```

---

### 3. MainTabView 수정
**파일**: `Aran/Presentation/Common/MainTabView.swift`

`case .medication:` 부분을 아래처럼 변경:

```swift
// 변경 전
case .medication:
    MedicationListWrapper()

// 변경 후
case .medication:
    MedicationListWrapper(container: container)
```

---

### 4. Xcode 프로젝트에 신규 파일 추가 (중요!)

새로 생성된 파일 2개를 Xcode 프로젝트에 추가해야 빌드에 포함됨:
- `Presentation/Medication/MedicationFormViewModel.swift`
- `Presentation/Medication/MedicationFormViewController.swift`

Xcode에서: `Presentation/Medication` 그룹 우클릭 → **Add Files to "Aran"** → 두 파일 선택

---

### 5. 빌드 확인

```bash
xcodebuild -scheme Aran
```

---

## 검증 순서

1. 약/주사 탭 진입 → 빈 목록 확인
2. + 버튼 → 약 추가 화면 진입
3. 약 이름 + 용량 입력 → 저장 버튼 활성화 확인
4. 저장 → 목록으로 돌아와서 항목 추가됨 확인
5. 스위치 탭 → 비활성화(alpha 0.5) 확인
6. 왼쪽 스와이프 → "중단" / "삭제" 액션 확인

---

## 참고: 현재 구현된 파일 구조

```
Domain/UseCases/MedicationUseCase.swift         ← save, toggle, delete, fetchAll
Domain/Entities/Medication.swift                ← Medication, MedicationType, MedicationSchedule
Data/Repositories/MedicationRepository.swift    ← SwiftData CRUD
Data/Notification/NotificationManager.swift     ← UNUserNotificationCenter 래핑
Presentation/Medication/MedicationViewModel.swift     ← RxSwift Input/Output (완료)
Presentation/Medication/MedicationCell.swift          ← 셀 UI (완료)
Presentation/Medication/MedicationFormViewModel.swift ← 저장 로직 (완료)
Presentation/Medication/MedicationFormViewController.swift ← 약 추가 폼 (완료)
```
