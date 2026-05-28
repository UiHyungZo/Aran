import RxCocoa
import RxSwift
import UserNotifications
import UIKit

final class MedicationFormViewController: UIViewController {
    private let viewModel: MedicationFormViewModel
    private let actions: MedicationFormActions
    private let initialMedication: Medication?
    private let initialDrugName: String
    private let initialComponent: String
    private let initialDosage: String
    private let disposeBag = DisposeBag()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let drugNameField = UITextField()
    private let typeSegment = UISegmentedControl(
        items: MedicationType.allCases.map { $0.rawValue }
    )
    private let dosageField = UITextField()

    private let startDatePicker = UIDatePicker()
    private let startDateRelay = BehaviorRelay<Date>(value: Date())
    private let endDatePicker = UIDatePicker()
    private let endDateSwitch = UISwitch()
    private let endDateRelay = BehaviorRelay<Date?>(value: nil)

    private let timePickerContainer = UIStackView()
    private var timePickers: [UIDatePicker] = []
    private let timesRelay = BehaviorRelay<[Date]>(value: [])
    private let notificationSwitch = UISwitch()

    private let saveButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    private let saveTappedRelay = PublishRelay<Void>()

    init(viewModel: MedicationFormViewModel,
         actions: MedicationFormActions,
         initialMedication: Medication? = nil,
         initialDrugName: String = "",
         initialComponent: String = "",
         initialDosage: String = "")
    {
        self.viewModel = viewModel
        self.actions = actions
        self.initialMedication = initialMedication
        self.initialDrugName = initialMedication?.drugName ?? initialDrugName
        self.initialComponent = initialMedication?.component ?? initialComponent
        self.initialDosage = initialMedication?.dosage ?? initialDosage
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
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        title = initialMedication == nil ? "약 등록" : "약 수정"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(cancelTapped)
        )

        setupScrollView()
        contentStack.addArrangedSubview(makeInfoFields())
        contentStack.addArrangedSubview(makeDateRangeSection())
        contentStack.addArrangedSubview(makeTimeRows())
        contentStack.addArrangedSubview(makeNotificationRow())
        contentStack.addArrangedSubview(saveButton)
        if initialMedication != nil {
            contentStack.addArrangedSubview(deleteButton)
        }

        let saveTitle = initialMedication == nil ? "저장하기" : "수정 저장"
        saveButton.setTitle(saveTitle, for: .normal)
        saveButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.setTitleColor(.secondaryLabel, for: .disabled)
        saveButton.backgroundColor = AranColor.primaryUI
        saveButton.layer.cornerRadius = 10
        saveButton.isEnabled = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        deleteButton.setTitle("이 약 삭제", for: .normal)
        deleteButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        deleteButton.setTitleColor(UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1), for: .normal)
        deleteButton.backgroundColor = UIColor(red: 1.0, green: 0.92, blue: 0.92, alpha: 1)
        deleteButton.layer.cornerRadius = 10
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
    }

    private func setupScrollView() {
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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
            contentStack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])
    }

    // MARK: - Section Builders

    private func makeInfoFields() -> UIView {
        drugNameField.placeholder = "약 검색으로 자동 입력"
        drugNameField.text = initialDrugName
        drugNameField.borderStyle = .none
        drugNameField.font = AranFont.bodyUI()
        drugNameField.clearButtonMode = .whileEditing
        drugNameField.returnKeyType = .next

        dosageField.placeholder = "예) 300IU/0.5mL"
        dosageField.text = initialDosage
        dosageField.borderStyle = .none
        dosageField.font = AranFont.bodyUI()
        dosageField.clearButtonMode = .whileEditing
        dosageField.returnKeyType = .done

        drugNameField.delegate = self
        dosageField.delegate = self

        let selectedType = initialMedication?.type ?? .oral
        typeSegment.selectedSegmentIndex = MedicationType.allCases.firstIndex(of: selectedType) ?? 0

        return makeStack(rows: [
            makeFieldRow(label: "약 이름 *", control: drugNameField, isPrefilled: !initialDrugName.isEmpty),
            makeFieldRow(label: "종류", control: typeSegment, isPrefilled: false),
            makeFieldRow(label: "용량/메모", control: dosageField, isPrefilled: false),
        ])
    }

    private func makeDateRangeSection() -> UIView {
        startDatePicker.datePickerMode = .date
        startDatePicker.preferredDatePickerStyle = .compact
        startDatePicker.tintColor = AranColor.primaryUI
        startDatePicker.locale = Locale(identifier: "ko_KR")
        let startDate = initialMedication?.schedule.startDate ?? Date()
        startDatePicker.date = startDate
        startDateRelay.accept(startDate)

        endDatePicker.datePickerMode = .date
        endDatePicker.preferredDatePickerStyle = .compact
        endDatePicker.tintColor = AranColor.primaryUI
        endDatePicker.locale = Locale(identifier: "ko_KR")
        if let endDate = initialMedication?.schedule.endDate {
            endDatePicker.date = endDate
            endDatePicker.isEnabled = true
            endDatePicker.alpha = 1.0
            endDateSwitch.isOn = true
            endDateRelay.accept(endDate)
        } else {
            endDatePicker.isEnabled = false
            endDatePicker.alpha = 0.4
        }

        endDateSwitch.onTintColor = AranColor.primaryUI

        let startLabel = UILabel()
        startLabel.text = "시작일"
        startLabel.font = AranFont.bodyUI()

        let startRow = UIStackView(arrangedSubviews: [startLabel, startDatePicker])
        startRow.axis = .horizontal
        startRow.alignment = .center
        startRow.distribution = .equalSpacing
        startRow.isLayoutMarginsRelativeArrangement = true
        startRow.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

        let endLabel = UILabel()
        endLabel.text = "종료일"
        endLabel.font = AranFont.bodyUI()

        let endRow = UIStackView(arrangedSubviews: [endLabel, endDatePicker, endDateSwitch])
        endRow.axis = .horizontal
        endRow.alignment = .center
        endRow.distribution = .equalSpacing
        endRow.isLayoutMarginsRelativeArrangement = true
        endRow.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0)

        let title = sectionTitle("복용 기간")
        return makeStack(rows: [title, startRow, endRow])
    }

    private func makeTimeRows() -> UIView {
        timePickerContainer.axis = .vertical
        timePickerContainer.spacing = 0
        let initialTimes = (initialMedication?.schedule.times ?? []).sorted {
            let cal = Calendar.current
            return cal.component(.hour, from: $0) * 60 + cal.component(.minute, from: $0)
                 < cal.component(.hour, from: $1) * 60 + cal.component(.minute, from: $1)
        }
        if initialTimes.isEmpty {
            addTimePickerRow()
        } else {
            initialTimes.forEach { addTimePickerRow(date: $0) }
        }

        let addButton = UIButton(type: .system)
        addButton.setTitle("+ 시간 추가", for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        addButton.setTitleColor(AranColor.primaryUI, for: .normal)
        addButton.contentHorizontalAlignment = .leading
        addButton.heightAnchor.constraint(equalToConstant: 36).isActive = true
        addButton.addTarget(self, action: #selector(addTimeTapped), for: .touchUpInside)

        let title = sectionTitle("복용 시간 *")
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

        let freqLabel = UILabel()
        freqLabel.text = "매일"
        freqLabel.font = AranFont.bodyUI()
        freqLabel.textColor = .secondaryLabel

        let deleteButton = UIButton(type: .system)
        deleteButton.setImage(UIImage(systemName: "minus.circle.fill"), for: .normal)
        deleteButton.tintColor = .systemRed
        deleteButton.isHidden = true
        deleteButton.addTarget(self, action: #selector(deleteTimeTapped(_:)), for: .touchUpInside)
        deleteButton.widthAnchor.constraint(equalToConstant: 24).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 24).isActive = true

        let row = UIStackView(arrangedSubviews: [picker, freqLabel, deleteButton])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 8
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
        notificationSwitch.isOn = initialMedication?.isEnabled ?? false

        let titleLabel = UILabel()
        titleLabel.text = "알림 설정"
        titleLabel.font = AranFont.bodyUI()
        titleLabel.textColor = .label

        return makePlainRow(labelView: titleLabel, detailView: notificationSwitch)
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
            ? UIColor(red: 0.933, green: 0.929, blue: 0.996, alpha: 1)
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

        startDatePicker.rx.date
            .bind(to: startDateRelay)
            .disposed(by: disposeBag)

        endDateSwitch.rx.isOn
            .subscribe(onNext: { [weak self] isOn in
                guard let self else { return }
                endDatePicker.isEnabled = isOn
                endDatePicker.alpha = isOn ? 1.0 : 0.4
                endDateRelay.accept(isOn ? endDatePicker.date : nil)
            })
            .disposed(by: disposeBag)

        endDatePicker.rx.date
            .filter { [weak self] _ in self?.endDateSwitch.isOn == true }
            .map { Optional($0) }
            .bind(to: endDateRelay)
            .disposed(by: disposeBag)

        notificationSwitch.rx.isOn
            .skip(1)
            .filter { $0 }
            .subscribe(onNext: { [weak self] _ in
                self?.checkNotificationPermission()
            })
            .disposed(by: disposeBag)

        let input = MedicationFormViewModel.Input(
            drugNameChanged: drugNameField.rx.text.orEmpty.asObservable(),
            typeSelected: typeSelected.asObservable(),
            componentChanged: Observable.just(initialComponent),
            dosageChanged: dosageField.rx.text.orEmpty.asObservable(),
            timesChanged: timesRelay.asObservable(),
            startDateChanged: startDateRelay.asObservable(),
            endDateChanged: endDateRelay.asObservable(),
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
                self?.actions.onSaveCompleted()
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

        deleteButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.deleteTapped()
            })
            .disposed(by: disposeBag)
    }

    @objc private func cancelTapped() {
        actions.onCancel()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    private func deleteTapped() {
        guard let initialMedication else { return }
        let alert = UIAlertController(
            title: "이 약을 삭제할까요?",
            message: "삭제한 약 정보는 복구할 수 없습니다.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.actions.onDelete(initialMedication)
        })
        present(alert, animated: true)
    }

    private func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard settings.authorizationStatus == .denied else { return }
            DispatchQueue.main.async {
                self?.notificationSwitch.setOn(false, animated: true)
                self?.presentPermissionDeniedAlert()
            }
        }
    }

    private func presentPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "알림 권한이 필요해요",
            message: "설정에서 알림을 허용해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        })
        present(alert, animated: true)
    }
}

extension MedicationFormViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case drugNameField:
            dosageField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
