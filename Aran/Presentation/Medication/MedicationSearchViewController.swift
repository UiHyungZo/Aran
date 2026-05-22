import UIKit

final class MedicationSearchViewController: UIViewController {
    private let searchDrugUseCase: SearchDrugUseCase
    private let actions: MedicationSearchActions

    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let resultCountLabel = UILabel()
    private let fallbackButton = UIButton(type: .system)
    private let activityIndicator = UIActivityIndicatorView(style: .medium)

    private var drugs: [Drug] = []
    private var searchTask: Task<Void, Never>?

    init(searchDrugUseCase: SearchDrugUseCase, actions: MedicationSearchActions) {
        self.searchDrugUseCase = searchDrugUseCase
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
    }

    deinit {
        searchTask?.cancel()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "약 검색"

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        searchBar.placeholder = "약 이름을 검색하세요"
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self

        resultCountLabel.font = AranFont.captionUI()
        resultCountLabel.textColor = .secondaryLabel
        resultCountLabel.text = "약 이름으로 검색해 추가할 수 있습니다."

        tableView.register(SearchResultCell.self, forCellReuseIdentifier: SearchResultCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 76
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        fallbackButton.setTitle("찾는 약이 없나요? 직접 입력하기", for: .normal)
        fallbackButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        fallbackButton.backgroundColor = .secondarySystemGroupedBackground
        fallbackButton.layer.cornerRadius = 10
        fallbackButton.addTarget(self, action: #selector(directInputTapped), for: .touchUpInside)

        activityIndicator.hidesWhenStopped = true

        let stack = UIStackView(arrangedSubviews: [searchBar, resultCountLabel, tableView, fallbackButton])
        stack.axis = .vertical
        stack.spacing = 6

        view.addSubview(stack)
        view.addSubview(activityIndicator)
        stack.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
            fallbackButton.heightAnchor.constraint(equalToConstant: 44),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func search(keyword: String) {
        searchTask?.cancel()
        activityIndicator.startAnimating()

        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let result = try await searchDrugUseCase.execute(keyword: keyword)
                guard !Task.isCancelled else { return }
                drugs = result
                resultCountLabel.text = "검색 결과 \(result.count)건"
                tableView.reloadData()
                activityIndicator.stopAnimating()
            } catch {
                guard !Task.isCancelled else { return }
                drugs = []
                resultCountLabel.text = "검색 결과가 없습니다."
                tableView.reloadData()
                activityIndicator.stopAnimating()
            }
        }
    }

    private func pushForm(drugName: String = "", dosage: String = "") {
        actions.showForm(drugName, dosage)
    }

    @objc private func closeTapped() {
        actions.close()
    }

    @objc private func directInputTapped() {
        pushForm()
    }
}

extension MedicationSearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        search(keyword: searchBar.text ?? "")
    }
}

extension MedicationSearchViewController: UITableViewDataSource {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        drugs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchResultCell.reuseIdentifier,
            for: indexPath
        ) as? SearchResultCell else {
            return UITableViewCell()
        }
        cell.configure(with: drugs[indexPath.row])
        return cell
    }
}

extension MedicationSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let drug = drugs[indexPath.row]
        pushForm(drugName: drug.itemName)
    }
}

private final class SearchResultCell: UITableViewCell {
    static let reuseIdentifier = "SearchResultCell"

    private let nameLabel = UILabel()
    private let companyLabel = UILabel()
    private let addLabel = UILabel()

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

        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 2

        companyLabel.font = AranFont.captionUI()
        companyLabel.textColor = .secondaryLabel
        companyLabel.numberOfLines = 2

        addLabel.text = "이 약 추가하기"
        addLabel.font = .systemFont(ofSize: 12, weight: .medium)
        addLabel.textColor = AranColor.primaryUI
        addLabel.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 1, alpha: 1)
        addLabel.layer.cornerRadius = 11
        addLabel.clipsToBounds = true
        addLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [nameLabel, companyLabel, addLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 4

        contentView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            addLabel.widthAnchor.constraint(equalToConstant: 96),
            addLabel.heightAnchor.constraint(equalToConstant: 24),
        ])
    }

    func configure(with drug: Drug) {
        nameLabel.text = drug.itemName
        companyLabel.text = drug.entpName
    }
}
