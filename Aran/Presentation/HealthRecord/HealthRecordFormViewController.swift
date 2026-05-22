import RxCocoa
import RxSwift
import UIKit

final class HealthRecordFormViewController: UIViewController {
    private let viewModel: HealthRecordFormViewModel
    private let onSaved: () -> Void
    private let disposeBag = DisposeBag()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    // 항목 선택 chip 스크롤
    private let chipScrollView = UIScrollView()
    private let chipStackView = UIStackView()
    private var itemChipButtons: [UIButton] = []
    private let selectedItemRelay = BehaviorRelay<TestItem>(value: .fsh)

    /// 수치 입력
    private let valueField = UITextField()

    /// 날짜 선택
    private let datePicker = UIDatePicker()

    /// 메모
    private let noteField = UITextField()

    // 저장 버튼
    private let saveButton = UIButton(type: .system)
    private let saveTappedRelay = PublishRelay<Void>()

    private let numericItems = TestItem.allCases.filter { $0.isNumeric }

    init(viewModel: HealthRecordFormViewModel, onSaved: @escaping () -> Void) {
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
        titleLabel.text = "검사 수치 입력"
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
        contentStack.addArrangedSubview(makeValueSection())
        contentStack.addArrangedSubview(makeDateSection())
        contentStack.addArrangedSubview(makeNoteSection())
        contentStack.addArrangedSubview(makeDebugChip())
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

        chipScrollView.showsHorizontalScrollIndicator = false
        chipStackView.axis = .horizontal
        chipStackView.spacing = 8
        chipStackView.alignment = .center

        for (i, item) in numericItems.enumerated() {
            let btn = makeChipButton(title: item.rawValue, tag: i)
            chipStackView.addArrangedSubview(btn)
            itemChipButtons.append(btn)
        }

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
        selectedItemRelay.accept(numericItems[index])
    }

    private func makeValueSection() -> UIView {
        let label = sectionTitle("수치")

        valueField.placeholder = "예: 8.2"
        valueField.keyboardType = .decimalPad
        valueField.borderStyle = .none
        valueField.font = AranFont.bodyUI()
        valueField.backgroundColor = .secondarySystemGroupedBackground
        valueField.layer.cornerRadius = 8
        valueField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        valueField.leftViewMode = .always
        valueField.translatesAutoresizingMaskIntoConstraints = false
        valueField.heightAnchor.constraint(equalToConstant: 42).isActive = true

        let container = UIStackView(arrangedSubviews: [label, valueField])
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

    private func makeDebugChip() -> UIView {
        let chip = UIView()
        chip.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 1, alpha: 1)
        chip.layer.cornerRadius = 8

        let label = UILabel()
        label.text = "RxSwift — 수치 입력 실시간 유효성 검사 / 숫자가 아닌 값 입력 시 저장 버튼 비활성화"
        label.font = .systemFont(ofSize: 11)
        label.textColor = AranColor.primaryUI
        label.numberOfLines = 0
        chip.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: chip.topAnchor, constant: 8),
            label.leadingAnchor.constraint(equalTo: chip.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: chip.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: chip.bottomAnchor, constant: -8),
        ])
        let wrapper = UIStackView(arrangedSubviews: [chip])
        wrapper.isLayoutMarginsRelativeArrangement = true
        wrapper.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 0)
        return wrapper
    }

    private func makeSaveButton() -> UIView {
        saveButton.setTitle("저장", for: .normal)
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

    private func sectionTitle(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        return label
    }

    // MARK: - ViewModel Binding

    private func bindViewModel() {
        let dateObservable = datePicker.rx.date.asObservable()
        let noteObservable = noteField.rx.text.asObservable()

        let input = HealthRecordFormViewModel.Input(
            selectedItem: selectedItemRelay.asObservable(),
            valueText: valueField.rx.text.orEmpty.asObservable(),
            date: dateObservable,
            note: noteObservable,
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
