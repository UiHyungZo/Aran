import RxCocoa
import RxSwift
import UIKit

final class MedicationListViewController: UIViewController {
    private let viewModel: MedicationViewModel
    private let actions: MedicationListActions
    private let disposeBag = DisposeBag()

    private let tableView = UITableView()
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyLabel = UILabel()

    private let toggleRelay = PublishRelay<Medication>()
    private let deleteRelay = PublishRelay<Medication>()
    private let viewWillAppearSubject = PublishSubject<Void>()

    private var medications: [Medication] = []
    private var activeMedications: [Medication] {
        medications.filter(\.isEnabled)
    }

    private var inactiveMedications: [Medication] {
        medications.filter { !$0.isEnabled }
    }

    init(viewModel: MedicationViewModel, actions: MedicationListActions) {
        self.viewModel = viewModel
        self.actions = actions
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

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
        view.backgroundColor = .secondarySystemGroupedBackground
        title = "약 / 주사"

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        tableView.register(MedicationCell.self, forCellReuseIdentifier: MedicationCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .secondarySystemGroupedBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0

        emptyLabel.text = "등록된 약/주사가 없습니다."
        emptyLabel.font = AranFont.captionUI(13)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true

        activityIndicator.hidesWhenStopped = true

        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(activityIndicator)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
                self?.emptyLabel.isHidden = !medications.isEmpty
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
        actions.showSearch()
    }

    private func medication(at indexPath: IndexPath) -> Medication {
        indexPath.section == 0 ? activeMedications[indexPath.row] : inactiveMedications[indexPath.row]
    }
}

// MARK: - UITableViewDataSource

extension MedicationListViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        inactiveMedications.isEmpty ? 1 : 2
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? activeMedications.count : inactiveMedications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MedicationCell.reuseIdentifier,
            for: indexPath
        ) as? MedicationCell else {
            return UITableViewCell()
        }
        let medication = medication(at: indexPath)
        cell.configure(with: medication)
        cell.onToggle = { [weak self] _ in
            self?.toggleRelay.accept(medication)
        }
        return cell
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "복용 중" : "중단됨"
    }
}

// MARK: - UITableViewDelegate

extension MedicationListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        actions.showEdit(medication(at: indexPath))
    }

    func tableView(
        _: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let medication = medication(at: indexPath)

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

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = section == 0 ? "복용 중" : "중단됨"
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel

        let container = UIView()
        container.backgroundColor = .secondarySystemGroupedBackground
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
        ])
        return container
    }

    func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        section == 0 ? 30 : 34
    }
}
