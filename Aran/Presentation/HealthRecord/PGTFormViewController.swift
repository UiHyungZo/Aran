import RxCocoa
import RxSwift
import UIKit

final class PGTFormViewController: UIViewController {
    private let viewModel: PGTFormViewModel
    private let onSaved: () -> Void
    private let disposeBag = DisposeBag()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // 항목 선택 chip
    private var itemChipButtons: [UIButton] = []
    private let selectedItemRelay = BehaviorRelay<TestItem>(value: .pgt)
    private let nonNumericItems = TestItem.allCases.filter { !$0.isNumeric }

    // Stepper 카운트
    private let normalCountRelay = BehaviorRelay<Int>(value: 0)
    private let abnormalCountRelay = BehaviorRelay<Int>(value: 0)
    private let mosaicCountRelay = BehaviorRelay<Int>(value: 0)

    private let normalCountLabel = UILabel()
    private let abnormalCountLabel = UILabel()
    private let mosaicCountLabel = UILabel()

    private let normalStepper = UIStepper()
    private let abnormalStepper = UIStepper()
    private let mosaicStepper = UIStepper()

    // 날짜, 메모
    private let datePicker = UIDatePicker()
    private let noteField = UITextField()

    // 저장 버튼
    private let saveButton = UIButton(type: .system)
    private let saveTappedRelay = PublishRelay<Void>()

    init(viewModel: PGTFormViewModel, onSaved: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onSaved = onSaved
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

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let grabber = UIView()
        grabber.backgroundColor = UIColor.systemGray4
        grabber.layer.cornerRadius = 2.5
        view.addSubview(grabber)
        grabber.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            grabber.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            grabber.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            grabber.widthAnchor.constraint(equalToConstant: 36),
            grabber.heightAnchor.constraint(equalToConstant: 5),
        ])

        let titleLabel = UILabel()
        titleLabel.text = "PGT / 염색체 기록"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .systemGray3
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let headerRow = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.distribution = .equalSpacing
        view.addSubview(headerRow)
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerRow.topAnchor.constraint(equalTo: grabber.bottomAnchor, constant: 12),
            headerRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        setupScrollView(below: headerRow)
        contentStack.addArrangedSubview(makeChipSection())
        contentStack.addArrangedSubview(makeStepperSection())
        contentStack.addArrangedSubview(makeDateSection())
        contentStack.addArrangedSubview(makeNoteSection())
        contentStack.addArrangedSubview(makeSaveButton())

        selectChip(at: 0)
    }

    private func setupScrollView(below anchor: UIView) {
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: anchor.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)

        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    private func makeChipSection() -> UIView {
        let label = sectionTitle("검사 항목")
        let chipStack = UIStackView()
        chipStack.axis = .horizontal
        chipStack.spacing = 8
        chipStack.alignment = .center

        for (i, item) in nonNumericItems.enumerated() {
            let btn = makeChipButton(title: item.rawValue, tag: i)
            chipStack.addArrangedSubview(btn)
            itemChipButtons.append(btn)
        }

        let container = UIStackView(arrangedSubviews: [label, chipStack])
        container.axis = .vertical
        container.spacing = 8
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return container
    }

    private func makeChipButton(title: String, tag: Int) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        btn.tag = tag
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        btn.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        setChipStyle(btn, selected: false)
        return btn
    }

    private func setChipStyle(_ btn: UIButton, selected: Bool) {
        if selected {
            btn.backgroundColor = AranColor.primaryUI
            btn.setTitleColor(.white, for: .normal)
            btn.layer.borderColor = AranColor.primaryUI.cgColor
        } else {
            btn.backgroundColor = .systemBackground
            btn.setTitleColor(.label, for: .normal)
            btn.layer.borderColor = UIColor.systemGray4.cgColor
        }
    }

    @objc private func chipTapped(_ sender: UIButton) {
        selectChip(at: sender.tag)
    }

    private func selectChip(at index: Int) {
        for (i, btn) in itemChipButtons.enumerated() {
            setChipStyle(btn, selected: i == index)
        }
        selectedItemRelay.accept(nonNumericItems[index])
    }

    private func makeStepperSection() -> UIView {
        let label = sectionTitle("배아 결과 입력")

        configureStepper(normalStepper)
        configureStepper(abnormalStepper)
        configureStepper(mosaicStepper)

        normalStepper.addTarget(self, action: #selector(normalStepperChanged), for: .valueChanged)
        abnormalStepper.addTarget(self, action: #selector(abnormalStepperChanged), for: .valueChanged)
        mosaicStepper.addTarget(self, action: #selector(mosaicStepperChanged), for: .valueChanged)

        updateCountLabel(normalCountLabel, value: 0, color: .systemGreen)
        updateCountLabel(abnormalCountLabel, value: 0, color: .systemRed)
        updateCountLabel(mosaicCountLabel, value: 0, color: .systemOrange)

        let normalRow = makeStepperRow(title: "정상", color: .systemGreen, label: normalCountLabel, stepper: normalStepper)
        let abnormalRow = makeStepperRow(title: "이상", color: .systemRed, label: abnormalCountLabel, stepper: abnormalStepper)
        let mosaicRow = makeStepperRow(title: "모자이크", color: .systemOrange, label: mosaicCountLabel, stepper: mosaicStepper)

        let rowStack = UIStackView(arrangedSubviews: [normalRow, abnormalRow, mosaicRow])
        rowStack.axis = .vertical
        rowStack.spacing = 0
        rowStack.backgroundColor = .secondarySystemGroupedBackground
        rowStack.layer.cornerRadius = 10
        rowStack.clipsToBounds = true

        let container = UIStackView(arrangedSubviews: [label, rowStack])
        container.axis = .vertical
        container.spacing = 8
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 16, trailing: 0)
        return container
    }

    private func configureStepper(_ stepper: UIStepper) {
        stepper.minimumValue = 0
        stepper.maximumValue = 100
        stepper.stepValue = 1
        stepper.value = 0
        stepper.tintColor = AranColor.primaryUI
    }

    private func makeStepperRow(title: String, color: UIColor, label: UILabel, stepper: UIStepper) -> UIView {
        let dot = UIView()
        dot.backgroundColor = color.withAlphaComponent(0.8)
        dot.layer.cornerRadius = 5
        dot.translatesAutoresizingMaskIntoConstraints = false
        dot.widthAnchor.constraint(equalToConstant: 10).isActive = true
        dot.heightAnchor.constraint(equalToConstant: 10).isActive = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = AranFont.bodyUI()
        titleLabel.textColor = .label

        let leftStack = UIStackView(arrangedSubviews: [dot, titleLabel])
        leftStack.axis = .horizontal
        leftStack.spacing = 8
        leftStack.alignment = .center

        let row = UIStackView(arrangedSubviews: [leftStack, label, stepper])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 14, bottom: 12, trailing: 14)
        return row
    }

    private func updateCountLabel(_ label: UILabel, value: Int, color: UIColor) {
        label.text = "\(value)개"
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.textColor = value > 0 ? color : .secondaryLabel
    }

    @objc private func normalStepperChanged() {
        let v = Int(normalStepper.value)
        normalCountRelay.accept(v)
        updateCountLabel(normalCountLabel, value: v, color: .systemGreen)
    }

    @objc private func abnormalStepperChanged() {
        let v = Int(abnormalStepper.value)
        abnormalCountRelay.accept(v)
        updateCountLabel(abnormalCountLabel, value: v, color: .systemRed)
    }

    @objc private func mosaicStepperChanged() {
        let v = Int(mosaicStepper.value)
        mosaicCountRelay.accept(v)
        updateCountLabel(mosaicCountLabel, value: v, color: .systemOrange)
    }

    private func makeDateSection() -> UIView {
        let label = sectionTitle("검사일")

        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.tintColor = AranColor.primaryUI
        datePicker.maximumDate = Date()

        let row = UIStackView(arrangedSubviews: [label, datePicker])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0)
        return row
    }

    private func makeNoteSection() -> UIView {
        let label = sectionTitle("메모 (선택)")

        noteField.placeholder = "참고사항을 입력하세요"
        noteField.borderStyle = .none
        noteField.font = AranFont.bodyUI()
        noteField.backgroundColor = .secondarySystemGroupedBackground
        noteField.layer.cornerRadius = 8
        noteField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        noteField.leftViewMode = .always
        noteField.translatesAutoresizingMaskIntoConstraints = false
        noteField.heightAnchor.constraint(equalToConstant: 42).isActive = true

        let container = UIStackView(arrangedSubviews: [label, noteField])
        container.axis = .vertical
        container.spacing = 6
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 16, trailing: 0)
        return container
    }

    private func makeSaveButton() -> UIView {
        saveButton.setTitle("저장", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.secondaryLabel, for: .disabled)
        saveButton.backgroundColor = .secondarySystemGroupedBackground
        saveButton.layer.cornerRadius = 10
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return saveButton
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        let input = PGTFormViewModel.Input(
            selectedItem: selectedItemRelay.asObservable(),
            normalCount: normalCountRelay.asObservable(),
            abnormalCount: abnormalCountRelay.asObservable(),
            mosaicCount: mosaicCountRelay.asObservable(),
            date: datePicker.rx.date.asObservable(),
            note: noteField.rx.text.asObservable(),
            saveTap: saveTappedRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isSaveEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.saveButton.isEnabled = isEnabled
                self?.saveButton.backgroundColor = isEnabled
                    ? AranColor.primaryUI
                    : .secondarySystemGroupedBackground
            })
            .disposed(by: disposeBag)

        output.saved
            .drive(onNext: { [weak self] in
                self?.dismiss(animated: true) {
                    self?.onSaved()
                }
            })
            .disposed(by: disposeBag)

        output.error
            .filter { !$0.isEmpty }
            .drive(onNext: { [weak self] message in
                let alert = UIAlertController(title: "저장 실패", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)

        saveButton.rx.tap
            .bind(to: saveTappedRelay)
            .disposed(by: disposeBag)
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
