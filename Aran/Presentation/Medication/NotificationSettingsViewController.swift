import RxCocoa
import RxSwift
import UIKit

final class NotificationSettingsViewController: UIViewController {
    private struct TimeSlotRow {
        let medication: Medication
        let slot: MedicationTimeSlot
    }

    private let viewModel: MedicationViewModel
    private let disposeBag = DisposeBag()

    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let toggleTimeSlotRelay = PublishRelay<MedicationViewModel.TimeSlotToggleRequest>()
    private let viewWillAppearSubject = PublishSubject<Void>()

    private var medications: [Medication] = []
    private var slotRows: [TimeSlotRow] {
        medications.flatMap { medication in
            medication.schedule.sortedTimeSlots.map { TimeSlotRow(medication: medication, slot: $0) }
        }
    }

    init(viewModel: MedicationViewModel) {
        self.viewModel = viewModel
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
        title = "알림 설정"
        view.backgroundColor = .systemGroupedBackground

        tableView.register(NotificationToggleCell.self, forCellReuseIdentifier: NotificationToggleCell.reuseIdentifier)
        tableView.register(NotificationPreviewCell.self, forCellReuseIdentifier: NotificationPreviewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.sectionHeaderTopPadding = 8

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func bindViewModel() {
        let input = MedicationViewModel.Input(
            viewDidLoad: viewWillAppearSubject.asObservable(),
            toggleMedication: .empty(),
            toggleTimeSlot: toggleTimeSlotRelay.asObservable(),
            deleteMedication: .empty()
        )
        let output = viewModel.transform(input: input)

        output.medications
            .drive(onNext: { [weak self] medications in
                self?.medications = medications
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource

extension NotificationSettingsViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int { 2 }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? slotRows.count : 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationToggleCell.reuseIdentifier,
                for: indexPath
            ) as? NotificationToggleCell else { return UITableViewCell() }
            let row = slotRows[indexPath.row]
            cell.configure(
                medicationName: row.medication.drugName,
                time: row.slot.time,
                isEnabled: row.slot.isEnabled
            )
            cell.onToggle = { [weak self] in
                self?.toggleTimeSlotRelay.accept(
                    MedicationViewModel.TimeSlotToggleRequest(
                        medication: row.medication,
                        timeSlotID: row.slot.id
                    )
                )
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: NotificationPreviewCell.reuseIdentifier,
                for: indexPath
            ) as? NotificationPreviewCell else { return UITableViewCell() }
            let next = nextUpcoming(from: medications)
            cell.configure(medication: next?.medication, nextTime: next?.time)
            return cell
        }
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 1 ? "미리보기" : nil
    }
}

// MARK: - UITableViewDelegate

extension NotificationSettingsViewController: UITableViewDelegate {
    func tableView(_: UITableView, shouldHighlightRowAt _: IndexPath) -> Bool { false }
}

// MARK: - Next Upcoming Helper

private extension NotificationSettingsViewController {
    struct UpcomingEntry {
        let medication: Medication
        let time: Date
    }

    func nextUpcoming(from medications: [Medication]) -> UpcomingEntry? {
        let now = Date()
        let calendar = Calendar.current
        var candidates: [(Medication, Date)] = []

        for med in medications {
            for slot in med.schedule.timeSlots where slot.isEnabled {
                var components = calendar.dateComponents([.hour, .minute], from: slot.time)
                let base = calendar.dateComponents([.year, .month, .day], from: now)
                components.year = base.year
                components.month = base.month
                components.day = base.day

                guard let todayTime = calendar.date(from: components) else { continue }
                if todayTime > now {
                    candidates.append((med, todayTime))
                } else if let tomorrowTime = calendar.date(byAdding: .day, value: 1, to: todayTime) {
                    candidates.append((med, tomorrowTime))
                }
            }
        }

        guard let closest = candidates.min(by: { $0.1 < $1.1 }) else { return nil }
        return UpcomingEntry(medication: closest.0, time: closest.1)
    }
}

// MARK: - NotificationToggleCell

private final class NotificationToggleCell: UITableViewCell {
    static let reuseIdentifier = "NotificationToggleCell"

    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let toggle = UISwitch()

    var onToggle: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    private func setupUI() {
        selectionStyle = .none
        toggle.onTintColor = AranColor.primaryUI
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)

        nameLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let row = UIStackView(arrangedSubviews: [textStack, toggle])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing

        contentView.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }

    func configure(medicationName: String, time: Date, isEnabled: Bool) {
        nameLabel.text = medicationName
        toggle.isOn = isEnabled

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        subtitleLabel.text = "\(formatter.string(from: time)) · 매일"
    }

    @objc private func toggleChanged() {
        onToggle?()
    }
}

// MARK: - NotificationPreviewCell

private final class NotificationPreviewCell: UITableViewCell {
    static let reuseIdentifier = "NotificationPreviewCell"

    private let cardView = UIView()
    private let appIconLabel = UILabel()
    private let appNameLabel = UILabel()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) { fatalError() }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 12

        appIconLabel.text = "💊"
        appIconLabel.font = .systemFont(ofSize: 20)

        appNameLabel.text = "아란"
        appNameLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        appNameLabel.textColor = .label

        let headerStack = UIStackView(arrangedSubviews: [appIconLabel, appNameLabel])
        headerStack.axis = .horizontal
        headerStack.spacing = 6
        headerStack.alignment = .center

        messageLabel.font = .systemFont(ofSize: 14, weight: .medium)
        messageLabel.textColor = .label
        messageLabel.numberOfLines = 2

        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel

        let contentStack = UIStackView(arrangedSubviews: [headerStack, messageLabel, timeLabel])
        contentStack.axis = .vertical
        contentStack.spacing = 4

        cardView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 14),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -14),
        ])

        contentView.addSubview(cardView)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
        ])
    }

    func configure(medication: Medication?, nextTime: Date?) {
        guard let medication else {
            messageLabel.text = "복용 중인 약이 없습니다"
            timeLabel.text = nil
            return
        }

        messageLabel.text = "\(medication.drugName) 복용 시간이에요"

        if let time = nextTime {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "a h:mm"
            timeLabel.text = formatter.string(from: time)
        } else {
            timeLabel.text = nil
        }
    }
}
