import RxCocoa
import RxSwift
import UIKit

final class HealthRecordFormViewController: UIViewController {
    private let viewModel: HealthRecordFormViewModel
    private let mode: HealthRecordFormViewModel.FormMode
    private let onSaved: () -> Void
    private let disposeBag = DisposeBag()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let chipFlowView = ChipFlowView()
    private var itemChipButtons: [UIButton] = []
    private var itemTypes = HealthRecordType.defaults
    private var customUnits: [String: String] = [:]
    private var selectedChipIndex: Int?
    private let selectedTypeRelay: BehaviorRelay<String>

    private let typeDisplayField = UITextField()
    private let valueField = UITextField()
    private let unitField = UITextField()
    private let datePicker = UIDatePicker()
    private let dateTextField = UITextField()
    private let memoField = UITextField()
    private let saveButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let saveTappedRelay = PublishRelay<Void>()
    private let deleteTappedRelay = PublishRelay<Void>()

    init(
        viewModel: HealthRecordFormViewModel,
        mode: HealthRecordFormViewModel.FormMode = .add,
        onSaved: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.mode = mode
        self.onSaved = onSaved
        selectedTypeRelay = BehaviorRelay<String>(value: Self.initialType(for: mode))
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        refreshChipStyles()
    }

    private func setupUI() {
        view.backgroundColor = AranColor.backgroundUI
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        let titleLabel = UILabel()
        titleLabel.text = isEditMode ? "검사 수치 수정" : "검사 수치 추가"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        let closeButton = UIButton(type: .system)
        if !isEditMode{
            closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        closeButton.accessibilityIdentifier = "healthForm.close"
        closeButton.tintColor = .secondaryLabel
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        closeButton.widthAnchor.constraint(equalToConstant: 32).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let spacer = UIView()
        spacer.widthAnchor.constraint(equalToConstant: 32).isActive = true

        let headerRow = UIStackView(arrangedSubviews: [closeButton, titleLabel, spacer])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.distribution = .fill
        view.addSubview(headerRow)
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerRow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        setupScrollView(below: headerRow)
        contentStack.addArrangedSubview(makeTypeValueRow())
        contentStack.addArrangedSubview(makeDateUnitRow())
        contentStack.addArrangedSubview(makeMemoSection())
        contentStack.addArrangedSubview(makeSaveButton())
        if isEditMode {
            contentStack.addArrangedSubview(makeDeleteButton())
        }
        if !mode.isTypeLocked {
            contentStack.addArrangedSubview(makeChipSection())
        }
        configureInitialValues()
    }

    private func setupScrollView(below anchor: UIView) {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
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

    private func makeTypeValueRow() -> UIView {
        let typeLabel = sectionTitle("검사 항목")
        configureTextField(typeDisplayField, placeholder: "항목")
        typeDisplayField.isUserInteractionEnabled = false
        if !mode.isTypeLocked {
            let chevronContainer = UIView(frame: CGRect(x: 0, y: 0, width: 28, height: 16))
            let chevron = UIImageView(image: UIImage(systemName: "chevron.down"))
            chevron.frame = CGRect(x: 4, y: 0, width: 14, height: 16)
            chevron.tintColor = AranColor.healthRecordUI
            chevron.contentMode = .scaleAspectFit
            chevronContainer.addSubview(chevron)
            typeDisplayField.rightView = chevronContainer
            typeDisplayField.rightViewMode = .always
        }

        let valueLabel = sectionTitle("수치")
        configureTextField(valueField, placeholder: "예: 8.2")
        valueField.keyboardType = .decimalPad
        valueField.accessibilityIdentifier = "healthForm.value"

        let typeCol = UIStackView(arrangedSubviews: [typeLabel, typeDisplayField])
        typeCol.axis = .vertical
        typeCol.spacing = 6

        let valueCol = UIStackView(arrangedSubviews: [valueLabel, valueField])
        valueCol.axis = .vertical
        valueCol.spacing = 6

        let row = UIStackView(arrangedSubviews: [typeCol, valueCol])
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return row
    }

    private func makeDateUnitRow() -> UIView {
        let dateLabel = sectionTitle("측정일")
        datePicker.datePickerMode = .date
        datePicker.accessibilityIdentifier = "healthForm.date"
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.tintColor = AranColor.healthRecordUI
        datePicker.maximumDate = Date()

        configureTextField(dateTextField, placeholder: "날짜")
        dateTextField.accessibilityIdentifier = "healthForm.dateDisplay"
        dateTextField.tintColor = .clear
        dateTextField.inputView = datePicker

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let done = UIBarButtonItem(title: "완료", style: .done, target: self, action: #selector(dismissKeyboard))
        done.tintColor = AranColor.healthRecordUI
        toolbar.setItems([.flexibleSpace(), done], animated: false)
        dateTextField.inputAccessoryView = toolbar

        let unitLabel = sectionTitle("단위")
        configureTextField(unitField, placeholder: "단위")
        unitField.accessibilityIdentifier = "healthForm.unit"

        let dateCol = UIStackView(arrangedSubviews: [dateLabel, dateTextField])
        dateCol.axis = .vertical
        dateCol.spacing = 6

        let unitCol = UIStackView(arrangedSubviews: [unitLabel, unitField])
        unitCol.axis = .vertical
        unitCol.spacing = 6

        let row = UIStackView(arrangedSubviews: [dateCol, unitCol])
        row.axis = .horizontal
        row.spacing = 8
        row.distribution = .fillEqually
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)
        return row
    }

    private func makeChipSection() -> UIView {
        let label = sectionTitle("항목 선택")
        rebuildChipButtons()

        let container = UIStackView(arrangedSubviews: [label, chipFlowView])
        container.axis = .vertical
        container.spacing = 8
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 24, trailing: 0)
        return container
    }

    private func makeMemoSection() -> UIView {
        let label = sectionTitle("메모 (선택)")
        configureTextField(memoField, placeholder: "참고사항을 입력하세요")
        memoField.accessibilityIdentifier = "healthForm.memo"

        let container = UIStackView(arrangedSubviews: [label, memoField])
        container.axis = .vertical
        container.spacing = 6
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 16, trailing: 0)
        return container
    }

    private func makeSaveButton() -> UIView {
        saveButton.setTitle(isEditMode ? "수정 저장" : "+ 추가하기", for: .normal)
        saveButton.accessibilityIdentifier = "healthForm.save"
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.secondaryLabel, for: .disabled)
        saveButton.backgroundColor = AranColor.healthRecordUI
        saveButton.layer.cornerRadius = 10
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return saveButton
    }

    private func makeDeleteButton() -> UIView {
        deleteButton.setTitle("이 기록 삭제", for: .normal)
        deleteButton.accessibilityIdentifier = "healthForm.delete"
        deleteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        deleteButton.setTitleColor(AranColor.trendUpTextUI, for: .normal)
        deleteButton.backgroundColor = AranColor.trendUpBackgroundUI
        deleteButton.layer.cornerRadius = 10
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let wrapper = UIView()
        wrapper.addSubview(deleteButton)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalTo: wrapper.topAnchor, constant: 8),
            deleteButton.leadingAnchor.constraint(equalTo: wrapper.leadingAnchor),
            deleteButton.trailingAnchor.constraint(equalTo: wrapper.trailingAnchor),
            deleteButton.bottomAnchor.constraint(equalTo: wrapper.bottomAnchor),
        ])
        return wrapper
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.font = AranFont.bodyUI()
        textField.backgroundColor = AranColor.healthRecordFieldBackgroundUI
        textField.layer.cornerRadius = 8
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.heightAnchor.constraint(equalToConstant: 42).isActive = true
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    private func bindViewModel() {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 M월 d일"

        datePicker.rx.date
            .map { dateFormatter.string(from: $0) }
            .bind(to: dateTextField.rx.text)
            .disposed(by: disposeBag)

        let input = HealthRecordFormViewModel.Input(
            selectedType: selectedTypeRelay.asObservable(),
            valueText: valueField.rx.text.orEmpty.asObservable(),
            unitText: unitField.rx.text.orEmpty.asObservable(),
            date: datePicker.rx.date.asObservable(),
            memo: memoField.rx.text.asObservable(),
            saveTap: saveTappedRelay.asObservable(),
            deleteTap: deleteTappedRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isSaveEnabled
            .drive(onNext: { [weak self] isEnabled in
                self?.saveButton.isEnabled = isEnabled
                self?.saveButton.backgroundColor = isEnabled
                    ? AranColor.healthRecordUI
                    : AranColor.surfaceUI
            })
            .disposed(by: disposeBag)

        output.saved
            .drive(onNext: { [weak self] in self?.closeAfterMutation() })
            .disposed(by: disposeBag)

        output.deleted
            .drive(onNext: { [weak self] in self?.closeAfterMutation() })
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

        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                let alert = UIAlertController(title: "기록 삭제", message: "이 검사 기록을 삭제할까요?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "취소", style: .cancel))
                alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { _ in
                    self?.deleteTappedRelay.accept(())
                })
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func rebuildChipButtons() {
        chipFlowView.subviews.forEach { $0.removeFromSuperview() }
        itemChipButtons.removeAll()

        for (index, type) in itemTypes.enumerated() {
            let button = makeChipButton(title: type, tag: index)
            chipFlowView.addSubview(button)
            itemChipButtons.append(button)
        }

        let addButton = makeChipButton(title: "+ 직접 추가", tag: itemTypes.count)
        chipFlowView.addSubview(addButton)
        itemChipButtons.append(addButton)

        chipFlowView.setNeedsLayout()
        chipFlowView.layoutIfNeeded()
    }

    private func makeChipButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.accessibilityIdentifier = "healthForm.type.\(title)"
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.tag = tag
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        setChipStyle(button, selected: false)
        return button
    }

    private func setChipStyle(_ button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = AranColor.healthRecordUI
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = AranColor.healthRecordUI.resolvedColor(with: traitCollection).cgColor
        } else {
            button.backgroundColor = AranColor.surfaceUI
            button.setTitleColor(.label, for: .normal)
            button.layer.borderColor = UIColor.systemGray4.resolvedColor(with: traitCollection).cgColor
        }
    }

    @objc private func chipTapped(_ sender: UIButton) {
        if sender.tag == itemTypes.count {
            showCustomItemAlert()
            return
        }
        selectChip(at: sender.tag)
    }

    private func selectChip(at index: Int) {
        guard itemTypes.indices.contains(index) else { return }
        selectedChipIndex = index
        refreshChipStyles()
        let type = itemTypes[index]
        selectedTypeRelay.accept(type)
        typeDisplayField.text = type
        let unit = customUnits[type] ?? HealthRecordType.defaultUnits[type] ?? ""
        unitField.text = unit
        unitField.sendActions(for: .editingChanged)
    }

    private func refreshChipStyles() {
        for (buttonIndex, button) in itemChipButtons.enumerated() {
            setChipStyle(button, selected: buttonIndex == selectedChipIndex)
        }
    }

    private func configureInitialValues() {
        switch mode {
        case .add:
            selectChip(at: 0)
        case let .addLocked(type):
            typeDisplayField.text = type
            if !itemTypes.contains(type) {
                itemTypes.append(type)
            }
            if let index = itemTypes.firstIndex(of: type) {
                selectChip(at: index)
            } else {
                selectedTypeRelay.accept(type)
                unitField.text = customUnits[type] ?? HealthRecordType.defaultUnits[type] ?? ""
                unitField.sendActions(for: .editingChanged)
            }
        case let .edit(record):
            typeDisplayField.text = record.type
            if !itemTypes.contains(record.type) {
                itemTypes.append(record.type)
                customUnits[record.type] = record.unit
            }
            valueField.text = formatValue(record.value)
            unitField.text = record.unit
            datePicker.date = record.recordDate
            memoField.text = record.memo
            if let index = itemTypes.firstIndex(of: record.type) {
                selectedChipIndex = index
            }
        }
    }

    private func showCustomItemAlert() {
        let alert = UIAlertController(title: "직접 추가", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "항목 이름" }
        alert.addTextField { $0.placeholder = "단위" }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self else { return }
            let type = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let unit = alert.textFields?.last?.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            guard !type.isEmpty, !unit.isEmpty else { return }
            if !self.itemTypes.contains(type) {
                self.itemTypes.append(type)
            }
            self.customUnits[type] = unit
            self.rebuildChipButtons()
            if let index = self.itemTypes.firstIndex(of: type) {
                self.selectChip(at: index)
            }
        })
        present(alert, animated: true)
    }

    private func closeAfterMutation() {
        if presentingViewController != nil {
            dismiss(animated: true) { self.onSaved() }
        } else {
            navigationController?.popViewController(animated: true)
            onSaved()
        }
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    private func formatValue(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }

    private static func initialType(for mode: HealthRecordFormViewModel.FormMode) -> String {
        switch mode {
        case .add:
            return HealthRecordType.fsh
        case let .addLocked(type):
            return type
        case let .edit(record):
            return record.type
        }
    }
}

private extension HealthRecordFormViewModel.FormMode {
    var isTypeLocked: Bool {
        switch self {
        case .addLocked, .edit:
            return true
        case .add:
            return false
        }
    }
}

// MARK: - ChipFlowView

private final class ChipFlowView: UIView {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    override var intrinsicContentSize: CGSize {
        CGSize(width: bounds.width, height: totalHeight())
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyLayout()
        invalidateIntrinsicContentSize()
    }

    private func totalHeight() -> CGFloat {
        calculateLayout(in: bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width, apply: false)
    }

    @discardableResult
    private func calculateLayout(in width: CGFloat, apply: Bool) -> CGFloat {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowH: CGFloat = 0
        for sub in subviews {
            let sz = sub.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
            if x + sz.width > width, x > 0 {
                x = 0
                y += rowH + lineSpacing
                rowH = 0
            }
            if apply {
                sub.frame = CGRect(x: x, y: y, width: sz.width, height: sz.height)
            }
            x += sz.width + spacing
            rowH = max(rowH, sz.height)
        }
        return y + rowH
    }

    private func applyLayout() {
        calculateLayout(in: bounds.width, apply: true)
    }
}
