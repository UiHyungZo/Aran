import RxCocoa
import RxSwift
import UIKit

final class MedicationCell: UITableViewCell {
    static let reuseIdentifier = "MedicationCell"

    private let iconContainer = UIView()
    private let iconLabel = UILabel()
    private let nameLabel = UILabel()
    private let dosageLabel = UILabel()
    private let timeLabel = UILabel()
    private let enabledSwitch = UISwitch()
    private let stackView = UIStackView()

    var disposeBag = DisposeBag()

    var onToggle: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        onToggle = nil
        bindSwitch()
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground

        iconContainer.layer.cornerRadius = 9
        iconContainer.clipsToBounds = true
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 36),
            iconContainer.heightAnchor.constraint(equalToConstant: 36),
        ])

        iconLabel.font = .systemFont(ofSize: 17)
        iconLabel.textAlignment = .center
        iconContainer.addSubview(iconLabel)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconLabel.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconLabel.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
        ])

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .label
        dosageLabel.font = AranFont.captionUI()
        dosageLabel.textColor = .secondaryLabel
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .secondaryLabel
        timeLabel.numberOfLines = 2
        timeLabel.textAlignment = .right

        enabledSwitch.onTintColor = AranColor.primaryUI
        enabledSwitch.transform = CGAffineTransform(scaleX: 0.78, y: 0.78)

        let textStack = UIStackView(arrangedSubviews: [nameLabel, dosageLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        let trailingStack = UIStackView(arrangedSubviews: [timeLabel, enabledSwitch])
        trailingStack.axis = .vertical
        trailingStack.alignment = .trailing
        trailingStack.spacing = 3
        trailingStack.setContentHuggingPriority(.required, for: .horizontal)

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 10
        stackView.addArrangedSubview(iconContainer)
        stackView.addArrangedSubview(textStack)
        stackView.addArrangedSubview(trailingStack)

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])

        bindSwitch()
    }

    private func bindSwitch() {
        enabledSwitch.rx.isOn
            .skip(1)
            .subscribe(onNext: { [weak self] isOn in self?.onToggle?(isOn) })
            .disposed(by: disposeBag)
    }

    func configure(with medication: Medication) {
        nameLabel.text = medication.drugName
        dosageLabel.text = "\(medication.dosage) · \(medication.type.rawValue)"
        iconLabel.text = medication.type == .injection ? "💉" : "💊"
        iconContainer.backgroundColor = iconBackgroundColor(for: medication.type)
        timeLabel.text = medication.isEnabled ? formattedTimes(medication.schedule.times) : nil
        enabledSwitch.isOn = medication.isEnabled
        contentView.alpha = medication.isEnabled ? 1 : 0.5
    }

    private func iconBackgroundColor(for type: MedicationType) -> UIColor {
        switch type {
        case .oral:
            return UIColor(red: 0.93, green: 0.93, blue: 1, alpha: 1)
        case .injection:
            return UIColor(red: 0.88, green: 0.96, blue: 0.93, alpha: 1)
        case .patch:
            return UIColor(red: 0.98, green: 0.94, blue: 0.86, alpha: 1)
        case .other:
            return .secondarySystemGroupedBackground
        }
    }

    private func formattedTimes(_ dates: [Date]) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a h시"
        return dates.prefix(2).map { formatter.string(from: $0) }.joined(separator: "\n")
    }
}
