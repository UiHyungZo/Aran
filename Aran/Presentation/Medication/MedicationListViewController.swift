import RxCocoa
import RxSwift
import UIKit
import AranDomain

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
    private struct MedicationSection {
        let title: String
        let medications: [Medication]
    }

    private var alarmMedicationKeys: Set<String> {
        Set(medications.filter(\.isEnabled).map(groupKey(for:)))
    }

    private var alarmMedications: [Medication] {
        medications.filter { alarmMedicationKeys.contains(groupKey(for: $0)) }
    }

    private var nonAlarmMedications: [Medication] {
        medications.filter { !alarmMedicationKeys.contains(groupKey(for: $0)) }
    }

    private var sections: [MedicationSection] {
        [
            MedicationSection(title: "알림", medications: alarmMedications),
            MedicationSection(title: "미알림", medications: nonAlarmMedications),
        ].filter { !$0.medications.isEmpty }
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
        view.backgroundColor = AranColor.backgroundUI
        title = "약 / 주사"

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        addButton.accessibilityIdentifier = "medication.addButton"
        let bellButton = UIBarButtonItem(image: UIImage(systemName: "bell"), style: .plain, target: self, action: #selector(bellTapped))
        bellButton.accessibilityIdentifier = "medication.notificationButton"
        navigationItem.rightBarButtonItems = [addButton, bellButton]

        tableView.register(MedicationCell.self, forCellReuseIdentifier: MedicationCell.reuseIdentifier)
        tableView.accessibilityIdentifier = "medication.table"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = AranColor.backgroundUI
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 0

        emptyLabel.text = "등록된 약/주사가 없습니다."
        emptyLabel.accessibilityIdentifier = "medication.emptyLabel"
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
            toggleTimeSlot: .empty(),
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

    @objc private func bellTapped() {
        actions.showNotificationSettings()
    }

    private func medication(at indexPath: IndexPath) -> Medication {
        sections[indexPath.section].medications[indexPath.row]
    }

    private func groupKey(for medication: Medication) -> String {
        medication.drugName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    private func sectionTitle(at section: Int) -> String {
        let medicationSection = sections[section]
        return "\(medicationSection.title) (\(medicationSection.medications.count))"
    }
}

// MARK: - UITableViewDataSource

extension MedicationListViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].medications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: MedicationCell.reuseIdentifier,
            for: indexPath
        ) as? MedicationCell else {
            return UITableViewCell()
        }
        let medication = medication(at: indexPath)
        cell.configure(
            with: medication,
            isInAlarmGroup: alarmMedicationKeys.contains(groupKey(for: medication))
        )
        return cell
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionTitle(at: section)
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
        deleteAction.backgroundColor = AranColor.badgeFailedTextUI

        let toggleTitle = medication.isEnabled ? "알림 끄기" : "알림 켜기"
        let toggleAction = UIContextualAction(style: .normal, title: toggleTitle) { [weak self] _, _, completion in
            self?.toggleRelay.accept(medication)
            completion(true)
        }
        toggleAction.backgroundColor = .systemGray

        return UISwipeActionsConfiguration(actions: [deleteAction, toggleAction])
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = sectionTitle(at: section)
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel

        let container = UIView()
        container.backgroundColor = AranColor.backgroundUI
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
