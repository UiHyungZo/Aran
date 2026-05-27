import UIKit

final class ExamListCell: UITableViewCell {
    static let reuseIdentifier = "ExamListCell"

    private let itemLabel = UILabel()
    private let valueLabel = UILabel()
    private let trendLabel = UILabel()
    private let dateLabel = UILabel()

    private let trailingStack = UIStackView()

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
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground

        itemLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        itemLabel.textColor = .label
        itemLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        valueLabel.font = AranFont.bodyUI()
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right

        trendLabel.font = AranFont.captionUI(11)
        trendLabel.textAlignment = .right

        dateLabel.font = AranFont.captionUI(11)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .right

        // trailing 스택: 수치 or chips + 날짜
        trailingStack.axis = .vertical
        trailingStack.alignment = .trailing
        trailingStack.spacing = 4
        trailingStack.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [itemLabel, trailingStack])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)

        contentView.addSubview(row)
        row.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: contentView.topAnchor),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
        ])
    }

    func configure(with summary: HealthRecordSummary) {
        itemLabel.text = summary.type

        trailingStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        configureNumeric(summary: summary)
        trailingStack.addArrangedSubview(dateLabel)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM.dd"
        dateLabel.text = formatter.string(from: summary.latestRecord.recordDate)
    }

    private func configureNumeric(summary: HealthRecordSummary) {
        let unit = summary.latestRecord.unit
        valueLabel.text = "\(formatValue(summary.latestRecord.value)) \(unit)"
        valueLabel.textColor = .label

        if let trend = summary.trend {
            let trendText: String
            if trend > 0 {
                trendText = "↑ \(formatValue(trend))"
                trendLabel.textColor = .systemRed
            } else if trend < 0 {
                trendText = "↓ \(formatValue(abs(trend)))"
                trendLabel.textColor = .systemBlue
            } else {
                trendText = "→ 변화없음"
                trendLabel.textColor = .secondaryLabel
            }
            trendLabel.text = trendText
            trendLabel.isHidden = false
            trailingStack.addArrangedSubview(valueLabel)
            trailingStack.addArrangedSubview(trendLabel)
        } else {
            trendLabel.isHidden = true
            trailingStack.addArrangedSubview(valueLabel)
        }
    }

    private func formatValue(_ value: Double) -> String {
        if value == value.rounded() && value < 1000 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }
}
