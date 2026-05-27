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
    private let chipScrollView = UIScrollView()
    private let chipStackView = UIStackView()
    private var itemChipButtons: [UIButton] = []
    private var itemTypes = HealthRecordType.defaults
    private var customUnits: [String: String] = [:]
    private let selectedTypeRelay = BehaviorRelay<String>(value: HealthRecordType.fsh)

    private let valueField = UITextField()
    private let unitField = UITextField()
    private let datePicker = UIDatePicker()
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

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = isEditMode ? "검사 수치 수정" : "검사 수치 추가"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(systemName: isEditMode ? "chevron.left" : "xmark.circle.fill"), for: .normal)
        closeButton.tintColor = .systemGray3
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)

        let headerRow = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        headerRow.axis = .horizontal
        headerRow.alignment = .center
        headerRow.distribution = .equalSpacing
        view.addSubview(headerRow)
        headerRow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerRow.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])

        setupScrollView(below: headerRow)
        contentStack.addArrangedSubview(makeChipSection())
        contentStack.addArrangedSubview(makeValueSection())
        contentStack.addArrangedSubview(makeDateSection())
        contentStack.addArrangedSubview(makeMemoSection())
        contentStack.addArrangedSubview(makeSaveButton())
        if isEditMode {
            contentStack.addArrangedSubview(makeDeleteButton())
        }
        configureInitialValues()
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
        chipScrollView.showsHorizontalScrollIndicator = false
        chipStackView.axis = .horizontal
        chipStackView.spacing = 8
        chipStackView.alignment = .center
        rebuildChipButtons()

        chipScrollView.addSubview(chipStackView)
        chipStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            chipStackView.topAnchor.constraint(equalTo: chipScrollView.contentLayoutGuide.topAnchor, constant: 4),
            chipStackView.leadingAnchor.constraint(equalTo: chipScrollView.contentLayoutGuide.leadingAnchor),
            chipStackView.trailingAnchor.constraint(equalTo: chipScrollView.contentLayoutGuide.trailingAnchor),
            chipStackView.bottomAnchor.constraint(equalTo: chipScrollView.contentLayoutGuide.bottomAnchor, constant: -4),
            chipStackView.heightAnchor.constraint(equalTo: chipScrollView.frameLayoutGuide.heightAnchor),
        ])
        chipScrollView.heightAnchor.constraint(equalToConstant: 40).isActive = true

        let container = UIStackView(arrangedSubviews: [label, chipScrollView])
        container.axis = .vertical
        container.spacing = 8
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)
        return container
    }

    private func makeValueSection() -> UIView {
        let label = sectionTitle("수치")
        configureTextField(valueField, placeholder: "예: 8.2")
        valueField.keyboardType = .decimalPad
        configureTextField(unitField, placeholder: "단위")
        unitField.widthAnchor.constraint(equalToConstant: 110).isActive = true

        let fieldRow = UIStackView(arrangedSubviews: [valueField, unitField])
        fieldRow.axis = .horizontal
        fieldRow.spacing = 8

        let container = UIStackView(arrangedSubviews: [label, fieldRow])
        container.axis = .vertical
        container.spacing = 6
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 8, trailing: 0)
        return container
    }

    private func makeDateSection() -> UIView {
        let label = sectionTitle("측정일")
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

    private func makeMemoSection() -> UIView {
        let label = sectionTitle("메모 (선택)")
        configureTextField(memoField, placeholder: "참고사항을 입력하세요")

        let container = UIStackView(arrangedSubviews: [label, memoField])
        container.axis = .vertical
        container.spacing = 6
        container.isLayoutMarginsRelativeArrangement = true
        container.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 4, leading: 0, bottom: 16, trailing: 0)
        return container
    }

    private func makeSaveButton() -> UIView {
        saveButton.setTitle(isEditMode ? "수정 저장" : "+ 추가하기", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.secondaryLabel, for: .disabled)
        saveButton.backgroundColor = AranColor.primaryUI
        saveButton.layer.cornerRadius = 10
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return saveButton
    }

    private func makeDeleteButton() -> UIView {
        deleteButton.setTitle("이 기록 삭제", for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.layer.cornerRadius = 10
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.systemRed.cgColor
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        return deleteButton
    }

    private func configureTextField(_ textField: UITextField, placeholder: String) {
        textField.placeholder = placeholder
        textField.borderStyle = .none
        textField.font = AranFont.bodyUI()
        textField.backgroundColor = .secondarySystemGroupedBackground
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
                    ? AranColor.primaryUI
                    : .secondarySystemGroupedBackground
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
        chipStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        itemChipButtons.removeAll()

        for (index, type) in itemTypes.enumerated() {
            let button = makeChipButton(title: type, tag: index)
            chipStackView.addArrangedSubview(button)
            itemChipButtons.append(button)
        }

        guard !isEditMode else { return }
        let addButton = makeChipButton(title: "+ 직접 추가", tag: itemTypes.count)
        chipStackView.addArrangedSubview(addButton)
        itemChipButtons.append(addButton)
    }

    private func makeChipButton(title: String, tag: Int) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .medium)
        button.tag = tag
        button.layer.cornerRadius = 14
        button.layer.borderWidth = 1
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 14, bottom: 6, right: 14)
        button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
        button.isEnabled = !isEditMode || title == currentRecord?.type
        setChipStyle(button, selected: false)
        return button
    }

    private func setChipStyle(_ button: UIButton, selected: Bool) {
        if selected {
            button.backgroundColor = AranColor.primaryUI
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = AranColor.primaryUI.cgColor
        } else {
            button.backgroundColor = .systemBackground
            button.setTitleColor(button.isEnabled ? .label : .tertiaryLabel, for: .normal)
            button.layer.borderColor = UIColor.systemGray4.cgColor
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
        for (buttonIndex, button) in itemChipButtons.enumerated() {
            setChipStyle(button, selected: buttonIndex == index)
        }
        let type = itemTypes[index]
        selectedTypeRelay.accept(type)
        let unit = customUnits[type] ?? HealthRecordType.defaultUnits[type] ?? ""
        unitField.text = unit
        unitField.sendActions(for: .editingChanged)
    }

    private func configureInitialValues() {
        switch mode {
        case .add:
            selectChip(at: 0)
        case let .edit(record):
            if !itemTypes.contains(record.type) {
                itemTypes.append(record.type)
                customUnits[record.type] = record.unit
                rebuildChipButtons()
            }
            valueField.text = formatValue(record.value)
            unitField.text = record.unit
            datePicker.date = record.recordDate
            memoField.text = record.memo
            if let index = itemTypes.firstIndex(of: record.type) {
                selectChip(at: index)
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
        if isEditMode {
            navigationController?.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var currentRecord: HealthRecord? {
        if case let .edit(record) = mode { return record }
        return nil
    }

    private func formatValue(_ value: Double) -> String {
        if value == value.rounded() {
            return String(format: "%.0f", value)
        }
        return String(format: "%.2f", value)
    }
}
