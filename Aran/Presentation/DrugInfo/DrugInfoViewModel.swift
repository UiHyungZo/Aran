import Combine
import Foundation

@MainActor
final class DrugInfoViewModel: ObservableObject {
    enum ViewState {
        case initial
        case loading
        case results([Drug])
        case empty
        case error(String)
    }

    @Published var searchText: String = ""
    @Published var viewState: ViewState = .initial
    @Published var recentSearches: [String] = []
    @Published var selectedDrug: Drug?
    @Published var isDetailLoading: Bool = false
    @Published var showDebugChip: Bool = false
    @Published var detailError: String?

    private let searchDrugUseCase: SearchDrugUseCase
    private var cancellables = Set<AnyCancellable>()
    private let recentSearchesKey = "recentDrugSearches"

    init(searchDrugUseCase: SearchDrugUseCase) {
        self.searchDrugUseCase = searchDrugUseCase
        loadRecentSearches()
        bindSearch()
    }

    private func bindSearch() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] keyword in
                guard let self else { return }
                let trimmed = keyword.trimmingCharacters(in: .whitespaces)
                if trimmed.count < 2 {
                    viewState = .initial
                } else {
                    Task { await self.search(keyword: trimmed) }
                }
            }
            .store(in: &cancellables)
    }

    func search(keyword: String) async {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword.isEmpty else { return }

        viewState = .loading
        showDebugChip = false
        do {
            let drugs = try await searchDrugUseCase.execute(keyword: trimmedKeyword, pageNo: 1)
            viewState = deduplicated(drugs).isEmpty ? .empty : .results(deduplicated(drugs))
            saveRecentSearch(trimmedKeyword)
        } catch {
            do {
                let drugs = try await searchDrugUseCase.execute(keyword: trimmedKeyword, pageNo: 1)
                viewState = deduplicated(drugs).isEmpty ? .empty : .results(deduplicated(drugs))
                saveRecentSearch(trimmedKeyword)
            } catch {
                let message = (error as? AppError)?.errorDescription ?? error.localizedDescription
                viewState = .error(message)
            }
        }
        showDebugChip = true
    }

    private func deduplicated(_ drugs: [Drug]) -> [Drug] {
        drugs.reduce(into: [Drug]()) { acc, drug in
            if !acc.contains(where: { $0.itemSeq == drug.itemSeq }) { acc.append(drug) }
        }
    }

    func selectDrug(_ drug: Drug) async {
        isDetailLoading = true
        do {
            let detail = try await searchDrugUseCase.detail(itemSeq: drug.itemSeq)
            selectedDrug = detail
        } catch {
            let message = (error as? AppError)?.errorDescription ?? error.localizedDescription
            detailError = message
        }
        isDetailLoading = false
    }

    func clearSearch() {
        searchText = ""
        viewState = .initial
        showDebugChip = false
    }

    func removeRecentSearch(_ keyword: String) {
        recentSearches.removeAll { $0 == keyword }
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    func removeRecentSearch(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) where recentSearches.indices.contains(index) {
            recentSearches.remove(at: index)
        }
        UserDefaults.standard.set(recentSearches, forKey: recentSearchesKey)
    }

    func clearRecentSearches() {
        recentSearches = []
        UserDefaults.standard.removeObject(forKey: recentSearchesKey)
    }

    func searchRecentKeyword(_ keyword: String) {
        searchText = keyword
        Task { await search(keyword: keyword) }
    }

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }

    private func saveRecentSearch(_ keyword: String) {
        let trimmedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedKeyword.isEmpty else { return }

        var searches = recentSearches.filter { $0 != trimmedKeyword }
        searches.insert(trimmedKeyword, at: 0)
        if searches.count > 10 { searches = Array(searches.prefix(10)) }
        recentSearches = searches
        UserDefaults.standard.set(searches, forKey: recentSearchesKey)
    }
}
