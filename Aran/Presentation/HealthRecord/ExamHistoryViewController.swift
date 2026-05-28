import RxCocoa
import RxSwift
import UIKit

final class ExamHistoryViewController: UIViewController {
    private let viewModel: ExamHistoryViewModel
    private let actions: ExamHistoryActions
    private let disposeBag = DisposeBag()

    private let headerView = ExamHistoryHeaderView()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyLabel = UILabel()

    private let viewWillAppearSubject = PublishSubject<Void>()
    private var records: [HealthRecord] = []

    init(viewModel: ExamHistoryViewModel, actions: ExamHistoryActions) {
        self.viewModel = viewModel
        self.actions = actions
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reload()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutHeaderView()
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        headerView.autoresizingMask = [.flexibleWidth]

        tableView.register(ExamHistoryCell.self, forCellReuseIdentifier: ExamHistoryCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 68
        tableView.separatorStyle = .none
        tableView.tableHeaderView = headerView

        emptyLabel.text = "측정 기록이 없습니다."
        emptyLabel.font = AranFont.captionUI(13)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.isHidden = true

        activityIndicator.hidesWhenStopped = true

        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        view.addSubview(activityIndicator)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func bindViewModel() {
        let input = ExamHistoryViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.title
            .drive(onNext: { [weak self] title in
                self?.title = title
            })
            .disposed(by: disposeBag)

        Driver.combineLatest(output.latestSummary, output.trendText)
            .drive(onNext: { [weak self] summary, trend in
                self?.headerView.configure(latestSummary: summary, trend: trend)
            })
            .disposed(by: disposeBag)

        output.records
            .drive(onNext: { [weak self] records in
                guard let self else { return }
                self.records = records
                self.emptyLabel.isHidden = !records.isEmpty
                self.headerView.updateChart(records: records, type: self.viewModel.type)
                self.layoutHeaderView()
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        output.isLoading
            .drive(activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)

        output.error
            .filter { !$0.isEmpty }
            .drive(onNext: { [weak self] message in
                let alert = UIAlertController(title: "오류", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "확인", style: .default))
                self?.present(alert, animated: true)
            })
            .disposed(by: disposeBag)
    }

    private func layoutHeaderView() {
        tableView.layoutIfNeeded()
        guard tableView.bounds.width > 0 else { return }

        let targetWidth = tableView.bounds.width
        let currentHeader = tableView.tableHeaderView ?? headerView
        let widthChanged = abs(currentHeader.frame.width - targetWidth) > 0.5
        currentHeader.frame.size.width = targetWidth

        currentHeader.setNeedsLayout()
        currentHeader.layoutIfNeeded()
        let size = currentHeader.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        let heightChanged = abs(currentHeader.frame.height - size.height) > 0.5
        if widthChanged || heightChanged {
            currentHeader.frame = CGRect(
                x: 0,
                y: 0,
                width: targetWidth,
                height: size.height
            )
            tableView.tableHeaderView = currentHeader
        }
    }

    @objc private func addTapped() {
        actions.showAddForm()
    }

    func reload() {
        viewWillAppearSubject.onNext(())
    }
}

// MARK: - UITableViewDataSource

extension ExamHistoryViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        records.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExamHistoryCell.reuseIdentifier,
            for: indexPath
        ) as? ExamHistoryCell else {
            return UITableViewCell()
        }
        let record = records[indexPath.row]
        let prev = indexPath.row + 1 < records.count ? records[indexPath.row + 1] : nil
        cell.configure(record: record, previous: prev)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ExamHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        actions.showEditForm(records[indexPath.row])
    }
}

// MARK: - ExamHistoryHeaderView

final class ExamHistoryHeaderView: UIView {
    private let cardView = UIView()
    private let latestLabel = UILabel()
    private let trendLabel = UILabel()
    private let chartView = ExamChartHostingView()

    private(set) var currentLatest: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        backgroundColor = .systemGroupedBackground

        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 8

        latestLabel.font = .systemFont(ofSize: 16, weight: .bold)
        latestLabel.textColor = AranColor.healthRecordUI
        latestLabel.textAlignment = .left
        latestLabel.adjustsFontSizeToFitWidth = true
        latestLabel.minimumScaleFactor = 0.75
        latestLabel.lineBreakMode = .byTruncatingTail

        trendLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        trendLabel.textAlignment = .center
        trendLabel.layer.cornerRadius = 8
        trendLabel.layer.masksToBounds = true
        trendLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        trendLabel.setContentHuggingPriority(.required, for: .horizontal)

        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.heightAnchor.constraint(equalToConstant: 160).isActive = true

        let metricRow = UIStackView(arrangedSubviews: [latestLabel, trendLabel])
        metricRow.axis = .horizontal
        metricRow.alignment = .center
        metricRow.spacing = 8
        metricRow.distribution = .fill

        let stack = UIStackView(arrangedSubviews: [chartView, metricRow])
        stack.axis = .vertical
        stack.spacing = 10
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 12, bottom: 12, trailing: 12)

        addSubview(cardView)
        cardView.addSubview(stack)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            stack.topAnchor.constraint(equalTo: cardView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
        ])
    }

    func configure(latestSummary: String, trend: String?) {
        currentLatest = latestSummary
        latestLabel.text = latestSummary
        trendLabel.text = trend
        trendLabel.isHidden = trend == nil

        if let trend {
            if trend.hasPrefix("↑") {
                trendLabel.textColor = AranColor.trendUpTextUI
                trendLabel.backgroundColor = AranColor.trendUpBackgroundUI
            } else if trend.hasPrefix("↓") {
                trendLabel.textColor = AranColor.trendDownTextUI
                trendLabel.backgroundColor = AranColor.trendDownBackgroundUI
            } else {
                trendLabel.textColor = .secondaryLabel
                trendLabel.backgroundColor = .tertiarySystemGroupedBackground
            }
        }
    }

    func updateChart(records: [HealthRecord], type: String) {
        chartView.isHidden = false
        chartView.configure(records: records, type: type)
    }
}

// MARK: - ExamHistoryCell

final class ExamHistoryCell: UITableViewCell {
    static let reuseIdentifier = "ExamHistoryCell"

    private let dateLabel = UILabel()
    private let valueLabel = UILabel()
    private let trendLabel = UILabel()
    private let noteLabel = UILabel()
    private let separatorLine = UIView()
    private let chevronView = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        selectionStyle = .default
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground

        dateLabel.font = AranFont.captionUI(12)
        dateLabel.textColor = .secondaryLabel

        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = AranColor.healthRecordUI
        valueLabel.textAlignment = .right

        trendLabel.font = .systemFont(ofSize: 11, weight: .semibold)
        trendLabel.textAlignment = .center
        trendLabel.layer.cornerRadius = 8
        trendLabel.layer.masksToBounds = true

        noteLabel.font = AranFont.captionUI(12)
        noteLabel.textColor = .tertiaryLabel
        noteLabel.numberOfLines = 1

        separatorLine.backgroundColor = .separator
        chevronView.tintColor = .tertiaryLabel
        chevronView.setContentHuggingPriority(.required, for: .horizontal)

        let leftStack = UIStackView(arrangedSubviews: [dateLabel, noteLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2

        let rightStack = UIStackView(arrangedSubviews: [valueLabel, trendLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 2
        rightStack.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [leftStack, rightStack, chevronView])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 12
        row.isLayoutMarginsRelativeArrangement = true
        row.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 14, leading: 16, bottom: 14, trailing: 16)

        contentView.addSubview(row)
        contentView.addSubview(separatorLine)
        row.translatesAutoresizingMaskIntoConstraints = false
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: contentView.topAnchor),
            row.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            row.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            row.bottomAnchor.constraint(equalTo: separatorLine.topAnchor),
            separatorLine.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorLine.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 0.5),
        ])
    }

    func configure(record: HealthRecord, previous: HealthRecord?) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = formatter.string(from: record.recordDate)
        noteLabel.text = record.memo
        noteLabel.isHidden = record.memo == nil || record.memo?.isEmpty == true

        let value = record.value
        let formatted = value == value.rounded() ? String(format: "%.0f", value) : String(format: "%.2f", value)
        valueLabel.text = "\(formatted) \(record.unit)"
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)

        if let prev = previous {
            let diff = record.value - prev.value
            let diffFormatted = abs(diff) == abs(diff).rounded()
                ? String(format: "%.0f", abs(diff))
                : String(format: "%.2f", abs(diff))
            if diff > 0 {
                trendLabel.text = "↑ \(diffFormatted)"
                trendLabel.textColor = AranColor.trendUpTextUI
                trendLabel.backgroundColor = AranColor.trendUpBackgroundUI
            } else if diff < 0 {
                trendLabel.text = "↓ \(diffFormatted)"
                trendLabel.textColor = AranColor.trendDownTextUI
                trendLabel.backgroundColor = AranColor.trendDownBackgroundUI
            } else {
                trendLabel.text = "→"
                trendLabel.textColor = .secondaryLabel
                trendLabel.backgroundColor = .secondarySystemGroupedBackground
            }
            trendLabel.isHidden = false
        } else {
            trendLabel.isHidden = true
        }
    }
}

// MARK: - ExamHistoryActions

struct ExamHistoryActions {
    let showAddForm: () -> Void
    let showEditForm: (_ record: HealthRecord) -> Void
}
