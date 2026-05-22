import UIKit

final class ExamListCell: UITableViewCell {
    static let reuseIdentifier = "ExamListCell"

    private let itemLabel = UILabel()
    private let valueLabel = UILabel()
    private let trendLabel = UILabel()
    private let dateLabel = UILabel()

    // PGT 전용 chip 컨테이너
    private let chipStack = UIStackView()
    private let normalChip = PGTChipView(title: "정상", color: .systemGreen)
    private let abnormalChip = PGTChipView(title: "이상", color: .systemRed)
    private let mosaicChip = PGTChipView(title: "모자이크", color: .systemOrange)

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

        // PGT chip 스택
        chipStack.axis = .horizontal
        chipStack.spacing = 6
        chipStack.alignment = .center
        chipStack.addArrangedSubview(normalChip)
        chipStack.addArrangedSubview(abnormalChip)
        chipStack.addArrangedSubview(mosaicChip)

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

    func configure(with summary: TestItemSummary) {
        itemLabel.text = summary.item.rawValue

        trailingStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        if summary.item.isNumeric {
            configureNumeric(summary: summary)
        } else {
            configurePGT(summary: summary)
        }

        trailingStack.addArrangedSubview(dateLabel)

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM.dd"
        dateLabel.text = formatter.string(from: summary.latestRecord.date)
    }

    private func configureNumeric(summary: TestItemSummary) {
        let unit = summary.item.unit
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

    private func configurePGT(summary: TestItemSummary) {
        if let pgt = summary.latestRecord.pgtResult {
            normalChip.update(count: pgt.normal)
            abnormalChip.update(count: pgt.abnormal)
            mosaicChip.update(count: pgt.mosaic)
            normalChip.isHidden = pgt.normal == 0 && pgt.abnormal == 0 && pgt.mosaic == 0
            trailingStack.addArrangedSubview(chipStack)
        } else {
            valueLabel.text = "\(Int(summary.latestRecord.value))개"
            valueLabel.textColor = .label
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

// MARK: - PGTChipView

private final class PGTChipView: UIView {
    private let label = UILabel()
    private let countLabel = UILabel()
    private let chipColor: UIColor

    init(title: String, color: UIColor) {
        chipColor = color
        super.init(frame: .zero)
        layer.cornerRadius = 10
        backgroundColor = color.withAlphaComponent(0.12)

        label.text = title
        label.font = .systemFont(ofSize: 10, weight: .medium)
        label.textColor = color

        countLabel.font = .systemFont(ofSize: 11, weight: .bold)
        countLabel.textColor = color

        let stack = UIStackView(arrangedSubviews: [label, countLabel])
        stack.axis = .horizontal
        stack.spacing = 3
        stack.alignment = .center
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -7),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func update(count: Int) {
        countLabel.text = "\(count)"
        isHidden = count == 0
    }
}
