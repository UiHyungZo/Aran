import UIKit

final class MedicationCell: UITableViewCell {
    static let reuseIdentifier = "MedicationCell"

    private let statusButton = UIButton(type: .system)
    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = AranColor.surfaceUI
        contentView.backgroundColor = AranColor.surfaceUI
        accessoryType = .disclosureIndicator

        statusButton.isUserInteractionEnabled = false
        statusButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusButton.widthAnchor.constraint(equalToConstant: 24),
            statusButton.heightAnchor.constraint(equalToConstant: 24),
        ])

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .label

        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.spacing = 3

        let row = UIStackView(arrangedSubviews: [statusButton, textStack])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12

        contentView.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            row.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
        ])
    }

    func configure(with medication: Medication, isInAlarmGroup: Bool) {
        accessibilityIdentifier = "medication.cell.\(medication.drugName)"
        accessibilityLabel = medication.drugName
        nameLabel.text = medication.drugName

        if isInAlarmGroup {
            statusButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            statusButton.tintColor = typeColor(for: medication.type)
            subtitleLabel.text = medication.isEnabled
                ? formattedTimes(medication.schedule.sortedTimeSlots.map(\.time))
                : "같은 약품 알림 켜짐"
            subtitleLabel.textColor = .secondaryLabel
            nameLabel.textColor = .label
        } else {
            statusButton.setImage(UIImage(systemName: "circle"), for: .normal)
            statusButton.tintColor = .tertiaryLabel
            subtitleLabel.text = "알림 없음"
            subtitleLabel.textColor = .tertiaryLabel
            nameLabel.textColor = .secondaryLabel
        }
    }

    private func formattedTimes(_ dates: [Date]) -> String {
        guard let first = dates.first else { return "· 매일" }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h:mm"
        let timeStr = formatter.string(from: first)
        let suffix = dates.count > 1 ? " 외 \(dates.count - 1)개" : ""
        return "\(timeStr)\(suffix) · 매일"
    }

    private func typeColor(for _: MedicationType) -> UIColor {
        AranColor.accentMedicationUI
    }
}
