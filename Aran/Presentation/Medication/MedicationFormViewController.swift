import UIKit
import RxSwift
import RxCocoa

final class MedicationFormViewController: UIViewController {
    private let viewModel: MedicationFormViewModel
    private let disposeBag = DisposeBag()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let drugNameField = UITextField()
    private let typeSegment = UISegmentedControl(
        items: MedicationType.allCases.map { $0.rawValue }
    )
    private let dosageField = UITextField()
    private let timePicker = UIDatePicker()
    private let notificationSwitch = UISwitch()

    private let saveBarButton = UIBarButtonItem(title: "저장", style: .done, target: nil, action: nil)
    private let saveTappedRelay = PublishRelay<Void>()

    init(viewModel: MedicationFormViewModel) {
        self.viewModel = viewModel
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
        view.backgroundColor = .systemGroupedBackground
        title = "약 추가"
        navigationItem.rightBarButtonItem = saveBarButton
        saveBarButton.isEnabled = false

        setupScrollView()
        contentStack.addArrangedSubview(makeInfoSection())
        contentStack.addArrangedSubview(makeTimeSection())
        contentStack.addArrangedSubview(makeNotificationSection())
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
        contentStack.spacing = 24
        contentStack.isLayoutMarginsRelativeArrangement = true
        contentStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 24, leading: 16, bottom: 24, trailing: 16)

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

    private func makeInfoSection() -> UIView {
        drugNameField.placeholder = "예: 프로게스테론"
        drugNameField.borderStyle = .none
        drugNameField.font = AranFont.bodyUI()
        drugNameField.clearButtonMode = .whileEditing
        drugNameField.returnKeyType = .next

        dosageField.placeholder = "예: 100mg / 1정"
        dosageField.borderStyle = .none
        dosageField.font = AranFont.bodyUI()
        dosageField.clearButtonMode = .whileEditing
        dosageField.returnKeyType = .done

        typeSegment.selectedSegmentIndex = 0

        return makeCard(title: "약 정보", rows: [
            ("약 이름", drugNameField),
            ("종류", typeSegment),
            ("용량", dosageField)
        ])
    }

    private func makeTimeSection() -> UIView {
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .compact
        timePicker.tintColor = AranColor.primaryUI
        timePicker.locale = Locale(identifier: "ko_KR")

        return makeCard(title: "복용 시간", rows: [
            ("복용 시간", timePicker)
        ])
    }

    private func makeNotificationSection() -> UIView {
        notificationSwitch.onTintColor = AranColor.primaryUI

        return makeCard(title: "알림", rows: [
            ("알림 설정", notificationSwitch)
        ])
    }

    // MARK: - Layout Helpers

    private func makeCard(title: String, rows: [(String, UIView)]) -> UIView {
        let headerLabel = UILabel()
        headerLabel.text = title
        headerLabel.font = AranFont.captionUI(13)
        headerLabel.textColor = .secondaryLabel

        let card = UIView()
        card.backgroundColor = .secondarySystemGroupedBackground
        card.layer.cornerRadius = 12
        card.clipsToBounds = true

        let rowStack = UIStackView()
        rowStack.axis = .vertical
        rowStack.spacing = 0

        for (index, (label, control)) in rows.enumerated() {
            rowStack.addArrangedSubview(makeRow(label: label, control: control))
            if index < rows.count - 1 {
                let sep = UIView()
                sep.backgroundColor = .separator
                sep.translatesAutoresizingMaskIntoConstraints = false
                sep.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
                rowStack.addArrangedSubview(sep)
            }
        }

        card.addSubview(rowStack)
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            rowStack.topAnchor.constraint(equalTo: card.topAnchor),
            rowStack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
            rowStack.bottomAnchor.constraint(equalTo: card.bottomAnchor)
        ])

        let section = UIStackView(arrangedSubviews: [headerLabel, card])
        section.axis = .vertical
        section.spacing = 8

        return section
    }

    private func makeRow(label: String, control: UIView) -> UIView {
        let labelView = UILabel()
        labelView.text = label
        labelView.font = AranFont.bodyUI()
        labelView.setContentHuggingPriority(.required, for: .horizontal)
        labelView.setContentCompressionResistancePriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [labelView, control])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)

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
            timesChanged: timePicker.rx.date.map { [$0] }.asObservable(),
            startDateChanged: Observable.just(Date()),
            isNotificationEnabled: notificationSwitch.rx.isOn.asObservable(),
            saveTapped: saveTappedRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.isSaveEnabled
            .drive(saveBarButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.saveCompleted
            .drive(onNext: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
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

        saveBarButton.rx.tap
            .bind(to: saveTappedRelay)
            .disposed(by: disposeBag)
    }
}
