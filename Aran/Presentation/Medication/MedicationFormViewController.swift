import UIKit
import RxSwift
import RxCocoa

final class MedicationFormViewController: UIViewController {
    private let viewModel: MedicationFormViewModel
    private let initialDrugName: String
    private let initialDosage: String
    private let disposeBag = DisposeBag()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let drugNameField = UITextField()
    private let typeSegment = UISegmentedControl(
        items: MedicationType.allCases.map { $0.rawValue }
    )
    private let dosageField = UITextField()
    private let timePickerContainer = UIStackView()
    private var timePickers: [UIDatePicker] = []
    private let timesRelay = BehaviorRelay<[Date]>(value: [])
    private let notificationSwitch = UISwitch()

    private let saveButton = UIButton(type: .system)
    private let saveTappedRelay = PublishRelay<Void>()

    init(viewModel: MedicationFormViewModel, initialDrugName: String = "", initialDosage: String = "") {
        self.viewModel = viewModel
        self.initialDrugName = initialDrugName
        self.initialDosage = initialDosage
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "약 등록"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(cancelTapped)
        )

        setupScrollView()
        contentStack.addArrangedSubview(makeInfoFields())
        contentStack.addArrangedSubview(makeTimeRows())
        contentStack.addArrangedSubview(makeNotificationRow())
        contentStack.addArrangedSubview(saveButton)

        saveButton.setTitle("저장", for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.secondaryLabel, for: .disabled)
        saveButton.backgroundColor = AranColor.primaryUI
        saveButton.layer.cornerRadius = 10
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 0
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 14, bottom: 24, trailing: 14)

        scrollView.addSubview(contentStack)
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    // MARK: - Section Builders

    private func makeInfoFields() -> UIView {
        drugNameField.placeholder = "예: 프로게스테론"
        drugNameField.text = initialDrugName
        drugNameField.borderStyle = .none
        drugNameField.font = AranFont.bodyUI()
        drugNameField.clearButtonMode = .whileEditing
        drugNameField.returnKeyType = .next

        dosageField.placeholder = "예: 100mg / 1정"
        dosageField.text = initialDosage
        dosageField.borderStyle = .none
        dosageField.font = AranFont.bodyUI()
        dosageField.clearButtonMode = .whileEditing
        dosageField.returnKeyType = .done

        typeSegment.selectedSegmentIndex = 0

        return makeStack(rows: [
            makeFieldRow(label: "약 이름", control: drugNameField, isPrefilled: !initialDrugName.isEmpty),
            makeFieldRow(label: "종류", control: typeSegment, isPrefilled: false),
            makeFieldRow(label: "용량 / 메모", control: dosageField, isPrefilled: false)
        ])
    }

    private func makeTimeRows() -> UIView {
        timePickerContainer.axis = .vertical
        timePickerContainer.spacing = 0
        addTimePickerRow()

        let addButton = UIButton(type: .system)
        addButton.setTitle("+ 시간 추가", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        addButton.setTitleColor(AranColor.primaryUI, for: .normal)
        addButton.contentHorizontalAlignment = .leading
        addButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        addButton.addTarget(self, action: #selector(addTimeTapped), for: .touchUpInside)

        let title = sectionTitle("복용 시간")
        return makeStack(rows: [title, timePickerContainer, addButton])
    }

    private func addTimePickerRow(date: Date = Date()) {
        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .compact
        picker.tintColor = AranColor.primaryUI
        picker.locale = Locale(identifier: "ko_KR")
        picker.date = date
        picker.addTarget(self, action: #selector(pickerValueChanged), for: .valueChanged)
        timePickers.append(picker)

        let label = UILabel()
        label.text = "복용 시간"
        label.font = AranFont.bodyUI()

        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.isHidden = true
        deleteButton.addTarget(self, action: #selector(deleteTimeTapped(_:)), for: .touchUpInside)
        deleteButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let row = UIStackView(arrangedSubviews: [label, picker, deleteButton])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

        timePickerContainer.addArrangedSubview(row)
        updateTimesRelay()
        refreshDeleteButtons()
    }

    private func refreshDeleteButtons() {
        let showDelete = timePickers.count > 1
        for row in timePickerContainer.arrangedSubviews {
            row.subviews.last?.isHidden = !showDelete
        }
    }

    private func updateTimesRelay() {
        timesRelay.accept(timePickers.map { $0.date })
    }

    @objc private func addTimeTapped() {
        guard timePickers.count < 4 else { return }
        addTimePickerRow()
    }

    @objc private func deleteTimeTapped(_ sender: UIButton) {
        guard let row = sender.superview,
              let rowIndex = timePickerContainer.arrangedSubviews.firstIndex(of: row),
              timePickers.count > 1 else { return }

        timePickerContainer.removeArrangedSubview(row)
        row.removeFromSuperview()
        timePickers.remove(at: rowIndex)

        updateTimesRelay()
        refreshDeleteButtons()
    }

    @objc private func pickerValueChanged() {
        updateTimesRelay()
    }

    private func makeNotificationRow() -> UIView {
        notificationSwitch.onTintColor = AranColor.primaryUI

        let titleLabel = UILabel()
        titleLabel.text = "알림 받기"
        titleLabel.font = AranFont.bodyUI()
        titleLabel.textColor = .label

        let subLabel = UILabel()
        subLabel.text = "복용 시간에 알림"
        subLabel.font = AranFont.captionUI()
        subLabel.textColor = .secondaryLabel

        let labelStack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        labelStack.axis = .vertical
        labelStack.spacing = 2

        return makePlainRow(labelView: labelStack, detailView: notificationSwitch)
    }

    // MARK: - Layout Helpers

    private func makeStack(rows: [UIView]) -> UIStackView {
        let stack = UIStackView(arrangedSubviews: rows)
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.heightAnchor.constraint(equalToConstant: 34).isActive = true
        return label
    }

    private func makeFieldRow(label: String, control: UIView, isPrefilled: Bool) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = label
        titleLabel.font = AranFont.captionUI()
        titleLabel.textColor = .secondaryLabel

        control.backgroundColor = isPrefilled
            ? UIColor(red: 0.93, green: 0.93, blue: 1, alpha: 1)
            : .secondarySystemGroupedBackground
        control.layer.cornerRadius = 8

        let fieldStack = UIStackView(arrangedSubviews: [titleLabel, control])
        fieldStack.axis = .vertical
        fieldStack.spacing = 4
        fieldStack.isLayoutMarginsRelativeArrangement = true
        fieldStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0)

        control.translatesAutoresizingMaskIntoConstraints = false
        control.heightAnchor.constraint(greaterThanOrEqualToConstant: 36).isActive = true
        if let textField = control as? UITextField {
            textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 1))
            textField.leftViewMode = .always
        }

        return fieldStack
    }

    private func makePlainRow(label: String, detailView: UIView) -> UIView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = AranFont.bodyUI()
        return makePlainRow(labelView: labelView, detailView: detailView)
    }

    private func makePlainRow(labelView: UIView, detailView: UIView) -> UIView {
        let row = UIStackView(arrangedSubviews: [labelView, detailView])
        row.axis = .horizontal
        row.alignment = .center
        row.distribution = .equalSpacing
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

        return row
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        let typeSelected = typeSegment.rx.selectedSegmentIndex
            .map { MedicationType.allCases[$0] }

        let input = MedicationFormViewModel.Input(
            drugNameChanged: drugNameField.rx.text.orEmpty.asObservable(),
            typeSelected: typeSelected.asObservable(),
            dosageChanged: dosageField.rx.text.orEmpty.asObservable(),
            timesChanged: timesRelay.asObservable(),
            startDateChanged: Observable.just(Date()),
            isNotificationEnabled: notificationSwitch.rx.isOn.asObservable(),
            saveTapped: saveTappedRelay.asObservable()
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

        output.saveCompleted
            .drive(onNext: { [weak self] in
                self?.dismissSelf()
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

    @objc private func cancelTapped() {
        dismissSelf()
    }

    private func dismissSelf() {
        if let nav = navigationController, nav.viewControllers.first !== self {
            nav.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
}
