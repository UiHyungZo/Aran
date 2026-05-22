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
        viewWillAppearSubject.onNext(())
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addTapped)
        )

        headerView.translatesAutoresizingMaskIntoConstraints = false

        tableView.register(ExamHistoryCell.self, forCellReuseIdentifier: ExamHistoryCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.backgroundColor = .systemGroupedBackground
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 56
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
                self.headerView.updateChart(records: records, item: self.viewModel.item)
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
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        let size = headerView.systemLayoutSizeFitting(
            CGSize(width: tableView.bounds.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        headerView.frame.size.height = size.height
        tableView.tableHeaderView = headerView
    }

    @objc private func addTapped() {
        actions.showAddForm()
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

// MARK: - ExamHistoryHeaderView

final class ExamHistoryHeaderView: UIView {
    private let latestLabel = UILabel()
    private let trendLabel = UILabel()
    private let chartView = BarChartView()

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

        latestLabel.font = .systemFont(ofSize: 28, weight: .bold)
        latestLabel.textColor = .label
        latestLabel.textAlignment = .center

        trendLabel.font = AranFont.captionUI(13)
        trendLabel.textColor = .secondaryLabel
        trendLabel.textAlignment = .center

        chartView.translatesAutoresizingMaskIntoConstraints = false
        chartView.heightAnchor.constraint(equalToConstant: 100).isActive = true

        let stack = UIStackView(arrangedSubviews: [latestLabel, trendLabel, chartView])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 16, trailing: 16)

        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    func configure(latestSummary: String, trend: String?) {
        currentLatest = latestSummary
        latestLabel.text = latestSummary
        trendLabel.text = trend
        trendLabel.isHidden = trend == nil

        if let trend {
            if trend.hasPrefix("↑") {
                trendLabel.textColor = .systemRed
            } else if trend.hasPrefix("↓") {
                trendLabel.textColor = .systemBlue
            } else {
                trendLabel.textColor = .secondaryLabel
            }
        }
    }

    func updateChart(records: [HealthRecord], item: TestItem) {
        guard item.isNumeric else {
            chartView.isHidden = true
            return
        }
        chartView.isHidden = false
        let recent = Array(records.prefix(5).reversed())
        let values = recent.map { $0.value }
        chartView.setValues(values)
    }
}

// MARK: - BarChartView

final class BarChartView: UIView {
    private var values: [Double] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func setValues(_ values: [Double]) {
        self.values = values
        setNeedsDisplay()
    }

    override func draw(_ rect: CGRect) {
        guard !values.isEmpty else { return }

        let maxVal = values.max() ?? 1
        let minVal = values.min() ?? 0
        let range = maxVal - minVal == 0 ? 1 : maxVal - minVal

        let barCount = values.count
        let spacing: CGFloat = 6
        let totalSpacing = spacing * CGFloat(barCount - 1)
        let barWidth = (rect.width - totalSpacing) / CGFloat(barCount)
        let maxBarHeight = rect.height - 20

        for (i, value) in values.enumerated() {
            let normalizedHeight = CGFloat((value - minVal) / range) * maxBarHeight
            let barHeight = max(normalizedHeight, 8)
            let x = CGFloat(i) * (barWidth + spacing)
            let y = rect.height - barHeight - 16

            let isLatest = i == values.count - 1
            let color = isLatest ? AranColor.primaryUI : UIColor.systemGray4

            let barRect = CGRect(x: x, y: y, width: barWidth, height: barHeight)
            let path = UIBezierPath(roundedRect: barRect, cornerRadius: 4)
            color.setFill()
            path.fill()

            // 값 레이블
            let formatted = value == value.rounded()
                ? String(format: "%.0f", value)
                : String(format: "%.1f", value)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 9, weight: isLatest ? .semibold : .regular),
                .foregroundColor: isLatest ? AranColor.primaryUI : UIColor.secondaryLabel,
            ]
            let str = NSAttributedString(string: formatted, attributes: attrs)
            let strSize = str.size()
            let strX = x + (barWidth - strSize.width) / 2
            str.draw(at: CGPoint(x: strX, y: rect.height - 14))
        }
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground

        dateLabel.font = AranFont.captionUI(12)
        dateLabel.textColor = .secondaryLabel

        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = .label
        valueLabel.textAlignment = .right

        trendLabel.font = .systemFont(ofSize: 11)
        trendLabel.textAlignment = .right

        noteLabel.font = AranFont.captionUI(12)
        noteLabel.textColor = .tertiaryLabel
        noteLabel.numberOfLines = 1

        separatorLine.backgroundColor = .separator

        let leftStack = UIStackView(arrangedSubviews: [dateLabel, noteLabel])
        leftStack.axis = .vertical
        leftStack.spacing = 2

        let rightStack = UIStackView(arrangedSubviews: [valueLabel, trendLabel])
        rightStack.axis = .vertical
        rightStack.alignment = .trailing
        rightStack.spacing = 2
        rightStack.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [leftStack, rightStack])
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
        dateLabel.text = formatter.string(from: record.date)
        noteLabel.text = record.note
        noteLabel.isHidden = record.note == nil || record.note?.isEmpty == true

        if record.testItem.isNumeric {
            let value = record.value
            let formatted = value == value.rounded() ? String(format: "%.0f", value) : String(format: "%.2f", value)
            valueLabel.text = "\(formatted) \(record.testItem.unit)"

            if let prev = previous {
                let diff = record.value - prev.value
                let diffFormatted = abs(diff) == abs(diff).rounded()
                    ? String(format: "%.0f", abs(diff))
                    : String(format: "%.2f", abs(diff))
                if diff > 0 {
                    trendLabel.text = "↑ \(diffFormatted)"
                    trendLabel.textColor = .systemRed
                } else if diff < 0 {
                    trendLabel.text = "↓ \(diffFormatted)"
                    trendLabel.textColor = .systemBlue
                } else {
                    trendLabel.text = "→"
                    trendLabel.textColor = .secondaryLabel
                }
                trendLabel.isHidden = false
            } else {
                trendLabel.isHidden = true
            }
        } else if let pgt = record.pgtResult {
            valueLabel.text = "정상 \(pgt.normal) · 이상 \(pgt.abnormal) · 모자이크 \(pgt.mosaic)"
            valueLabel.font = .systemFont(ofSize: 13, weight: .medium)
            trendLabel.isHidden = true
        } else {
            valueLabel.text = "\(Int(record.value))개"
            trendLabel.isHidden = true
        }
    }
}

// MARK: - ExamHistoryActions

struct ExamHistoryActions {
    let showAddForm: () -> Void
}
