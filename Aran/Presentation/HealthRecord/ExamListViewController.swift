import RxCocoa
import RxSwift
import UIKit

final class ExamListViewController: UIViewController {
    private let viewModel: HealthRecordViewModel
    private let actions: ExamListActions
    private let disposeBag = DisposeBag()

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)
    private let emptyLabel = UILabel()

    private let viewWillAppearSubject = PublishSubject<Void>()
    private let deleteRelay = PublishRelay<HealthRecord>()

    private var sections: [ExamSection] = []

    init(viewModel: HealthRecordViewModel, actions: ExamListActions) {
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
        view.backgroundColor = AranColor.backgroundUI
        title = "검사 기록"

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        addButton.accessibilityIdentifier = "exam.addButton"
        navigationItem.rightBarButtonItem = addButton

        tableView.register(ExamListCell.self, forCellReuseIdentifier: ExamListCell.reuseIdentifier)
        tableView.accessibilityIdentifier = "exam.table"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = AranColor.backgroundUI
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
        tableView.separatorStyle = .none

        emptyLabel.text = "기록된 검사 수치가 없습니다."
        emptyLabel.accessibilityIdentifier = "exam.emptyLabel"
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
        let input = HealthRecordViewModel.Input(
            viewWillAppear: viewWillAppearSubject.asObservable(),
            deleteRecord: deleteRelay.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.sections
            .drive(onNext: { [weak self] sections in
                self?.sections = sections
                let isEmpty = sections.allSatisfy { $0.summaries.isEmpty }
                self?.emptyLabel.isHidden = !isEmpty
                self?.tableView.reloadData()
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

    func reload() {
        viewWillAppearSubject.onNext(())
    }

    @objc private func addTapped() {
        actions.showAddForm()
    }

    private func summary(at indexPath: IndexPath) -> HealthRecordSummary {
        sections[indexPath.section].summaries[indexPath.row]
    }
}

// MARK: - UITableViewDataSource

extension ExamListViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        sections.count
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].summaries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ExamListCell.reuseIdentifier,
            for: indexPath
        ) as? ExamListCell else {
            return UITableViewCell()
        }
        cell.configure(with: summary(at: indexPath))
        return cell
    }

    func tableView(_: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }
}

// MARK: - UITableViewDelegate

extension ExamListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let s = summary(at: indexPath)
        actions.showHistory(s.type)
    }

    func tableView(
        _: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let s = summary(at: indexPath)
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] _, _, completion in
            self?.deleteRelay.accept(s.latestRecord)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = sections[section].title
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.backgroundColor = .clear

        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -6),
        ])
        return container
    }

    func tableView(_: UITableView, heightForHeaderInSection _: Int) -> CGFloat {
        34
    }
}
