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
