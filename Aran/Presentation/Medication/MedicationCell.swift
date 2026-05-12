import UIKit
import RxSwift
import RxCocoa

final class MedicationCell: UITableViewCell {
    static let reuseIdentifier = "MedicationCell"

    private let nameLabel = UILabel()
    private let dosageLabel = UILabel()
    private let typeLabel = UILabel()
    private let enabledSwitch = UISwitch()
    private let stackView = UIStackView()

    var disposeBag = DisposeBag()

    var onToggle: ((Bool) -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        onToggle = nil
    }

    private func setupUI() {
        nameLabel.font = AranFont.bodyUI()
        dosageLabel.font = AranFont.captionUI()
        dosageLabel.textColor = .secondaryLabel
        typeLabel.font = AranFont.captionUI()
        typeLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [nameLabel, dosageLabel, typeLabel])
        textStack.axis = .vertical
        textStack.spacing = 2

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 12
        stackView.addArrangedSubview(textStack)
        stackView.addArrangedSubview(enabledSwitch)

        contentView.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])

        enabledSwitch.rx.isOn
            .skip(1)
            .subscribe(onNext: { [weak self] isOn in self?.onToggle?(isOn) })
            .disposed(by: disposeBag)
    }

    func configure(with medication: Medication) {
        nameLabel.text = medication.drugName
        dosageLabel.text = medication.dosage
        typeLabel.text = medication.type.rawValue
        enabledSwitch.isOn = medication.isEnabled
        contentView.alpha = medication.isEnabled ? 1 : 0.5
    }
}
