import Foundation
import Combine

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
                if trimmed.isEmpty {
                    viewState = .initial
                } else {
                    Task { await self.search(keyword: trimmed) }
                }
            }
            .store(in: &cancellables)
    }

    func search(keyword: String) async {
        viewState = .loading
        showDebugChip = false
        do {
            let drugs = try await searchDrugUseCase.execute(keyword: keyword, pageNo: 1)
            viewState = deduplicated(drugs).isEmpty ? .empty : .results(deduplicated(drugs))
        } catch {
            do {
                let drugs = try await searchDrugUseCase.execute(keyword: keyword, pageNo: 1)
                viewState = deduplicated(drugs).isEmpty ? .empty : .results(deduplicated(drugs))
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
            saveRecentSearch(searchText)
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

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: recentSearchesKey) ?? []
    }

    private func saveRecentSearch(_ keyword: String) {
        var searches = recentSearches.filter { $0 != keyword }
        searches.insert(keyword, at: 0)
        if searches.count > 10 { searches = Array(searches.prefix(10)) }
        recentSearches = searches
        UserDefaults.standard.set(searches, forKey: recentSearchesKey)
    }
}
