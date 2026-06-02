import UIKit

final class ExamListCell: UITableViewCell {
    static let reuseIdentifier = "ExamListCell"

    private let itemLabel = UILabel()
    private let valueLabel = UILabel()
    private let trendLabel = UILabel()
    private let dateLabel = UILabel()
    private let unitLabel = UILabel()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))

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
        selectionStyle = .default
        backgroundColor = AranColor.surfaceUI
        contentView.backgroundColor = AranColor.surfaceUI

        itemLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        itemLabel.textColor = .label
        itemLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        valueLabel.font = .systemFont(ofSize: 16, weight: .bold)
        valueLabel.textColor = AranColor.healthRecordUI
        valueLabel.textAlignment = .right

        trendLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        trendLabel.textAlignment = .center
        trendLabel.layer.cornerRadius = 8
        trendLabel.layer.masksToBounds = true

        dateLabel.font = AranFont.captionUI(11)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .left

        unitLabel.font = AranFont.captionUI(10)
        unitLabel.textColor = .secondaryLabel
        unitLabel.textAlignment = .right

        chevronView.tintColor = .tertiaryLabel
        chevronView.setContentHuggingPriority(.required, for: .horizontal)

        trailingStack.axis = .vertical
        trailingStack.alignment = .trailing
        trailingStack.spacing = 3
        trailingStack.setContentHuggingPriority(.required, for: .horizontal)

        let leftStack = UIStackView(arrangedSubviews: [itemLabel, dateLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 4

        let row = UIStackView(arrangedSubviews: [leftStack, trailingStack, chevronView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 13, leading: 16, bottom: 13, trailing: 12)

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

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy-MM-dd"
        dateLabel.text = formatter.string(from: summary.latestRecord.recordDate)
    }

    private func configureNumeric(summary: HealthRecordSummary) {
        let unit = summary.latestRecord.unit
        valueLabel.text = formatValue(summary.latestRecord.value)
        unitLabel.text = unit

        if let trend = summary.trend {
            let trendText: String
            if trend > 0 {
                trendText = "↑ \(formatValue(trend))"
                trendLabel.textColor = AranColor.trendUpTextUI
                trendLabel.backgroundColor = AranColor.trendUpBackgroundUI
            } else if trend < 0 {
                trendText = "↓ \(formatValue(abs(trend)))"
                trendLabel.textColor = AranColor.trendDownTextUI
                trendLabel.backgroundColor = AranColor.trendDownBackgroundUI
            } else {
                trendText = "→ 변화없음"
                trendLabel.textColor = .secondaryLabel
                trendLabel.backgroundColor = AranColor.surfaceUI
            }
            trendLabel.text = trendText
            trendLabel.isHidden = false
            trailingStack.addArrangedSubview(valueLabel)
            trailingStack.addArrangedSubview(unitLabel)
            trailingStack.addArrangedSubview(trendLabel)
        } else {
            trendLabel.isHidden = true
            trailingStack.addArrangedSubview(valueLabel)
            trailingStack.addArrangedSubview(unitLabel)
        }
    }

    private func formatValue(_ value: Double) -> String {
        if value == value.rounded() && value < 1000 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }
}
