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
    @Published var showDebugChip: Bool = false
    @Published var detailError: String?
    @Published var favoriteItemSeqs: Set<String> = []
    @Published var favoriteDrugs: [FavoriteDrug] = []
    @Published var isLoadingMore: Bool = false
    @Published var isDetailPresented = false
    @Published var isDetailLoading = false

    private let searchDrugUseCase: SearchDrugUseCaseProtocol
    private let favoriteDrugUseCase: FavoriteDrugUseCaseProtocol
    private let recentSearchUseCase: RecentDrugSearchUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()

    private var currentPage: Int = 1
    private(set) var totalCount: Int = 0
    private var currentKeyword: String = ""
    private var loadingDetailItemSeq: String?

    var hasMorePages: Bool { currentPage * 20 < totalCount }

    init(
        searchDrugUseCase: SearchDrugUseCaseProtocol,
        favoriteDrugUseCase: FavoriteDrugUseCaseProtocol,
        recentSearchUseCase: RecentDrugSearchUseCaseProtocol
    ) {
        self.searchDrugUseCase = searchDrugUseCase
        self.favoriteDrugUseCase = favoriteDrugUseCase
        self.recentSearchUseCase = recentSearchUseCase
        bindSearch()
        Task { await loadRecentSearches() }
        Task { await loadFavorites() }
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

        currentPage = 1
        currentKeyword = trimmedKeyword
        totalCount = 0

        viewState = .loading
        showDebugChip = false
        do {
            let result = try await searchDrugUseCase.execute(keyword: trimmedKeyword, pageNo: 1)
            totalCount = result.totalCount
            let drugs = deduplicated(result.drugs)
            viewState = drugs.isEmpty ? .empty : .results(drugs)
            await saveRecentSearch(trimmedKeyword)
        } catch {
            do {
                let result = try await searchDrugUseCase.execute(keyword: trimmedKeyword, pageNo: 1)
                totalCount = result.totalCount
                let drugs = deduplicated(result.drugs)
                viewState = drugs.isEmpty ? .empty : .results(drugs)
                await saveRecentSearch(trimmedKeyword)
            } catch {
                let message = (error as? AppError)?.errorDescription ?? error.localizedDescription
                viewState = .error(message)
            }
        }
        showDebugChip = true
    }

    func loadMore() async {
        guard !isLoadingMore && hasMorePages else { return }
        isLoadingMore = true
        let nextPage = currentPage + 1
        do {
            let result = try await searchDrugUseCase.execute(keyword: currentKeyword, pageNo: nextPage)
            if case .results(let existing) = viewState {
                let combined = deduplicated(existing + result.drugs)
                viewState = .results(combined)
            }
            totalCount = result.totalCount
        } catch {
            // 추가 로딩 실패 시 기존 결과 유지
        }
        currentPage = nextPage
        isLoadingMore = false
    }

    private func deduplicated(_ drugs: [Drug]) -> [Drug] {
        drugs.reduce(into: [Drug]()) { acc, drug in
            if !acc.contains(where: { $0.itemSeq == drug.itemSeq }) { acc.append(drug) }
        }
    }

    private var pendingFavoriteToggle = false

    func selectDrug(_ drug: Drug) {
        prepareForDetail(drug)
        isDetailPresented = true
    }

    func selectFavorite(_ favoriteDrug: FavoriteDrug) {
        prepareForDetail(favoriteDrug.drug)
    }

    private func prepareForDetail(_ drug: Drug) {
        pendingFavoriteToggle = false
        let shouldLoadDetail = needsDetailEnrichment(drug)
        loadingDetailItemSeq = shouldLoadDetail ? drug.itemSeq : nil
        isDetailLoading = shouldLoadDetail
        selectedDrug = drug
        guard shouldLoadDetail else { return }
        Task { await enrichSelectedDrug(drug) }
    }

    private func needsDetailEnrichment(_ drug: Drug) -> Bool {
        return isBlank(drug.efcyQesitm) || isBlank(drug.useMethodQesitm)
    }

    private func enrichSelectedDrug(_ drug: Drug) async {
        defer {
            if loadingDetailItemSeq == drug.itemSeq {
                loadingDetailItemSeq = nil
                isDetailLoading = false
            }
        }

        do {
            let enriched = try await searchDrugUseCase.enrich(drug)
            guard selectedDrug?.itemSeq == drug.itemSeq else { return }
            selectedDrug = enriched
            if pendingFavoriteToggle {
                pendingFavoriteToggle = false
                performToggle(enriched)
            }
        } catch {
            if pendingFavoriteToggle {
                pendingFavoriteToggle = false
                performToggle(selectedDrug ?? drug)
            }
        }
    }

    private func isBlank(_ value: String?) -> Bool {
        value?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true
    }

    func clearSearch() {
        searchText = ""
        viewState = .initial
        showDebugChip = false
        currentPage = 1
        totalCount = 0
        currentKeyword = ""
    }

    func removeRecentSearch(_ keyword: String) {
        Task {
            do {
                try await recentSearchUseCase.delete(keyword: keyword)
                await loadRecentSearches()
            } catch {
                recentSearches.removeAll { $0 == keyword }
            }
        }
    }

    func removeRecentSearch(at offsets: IndexSet) {
        let keywords = offsets
            .sorted(by: >)
            .compactMap { recentSearches.indices.contains($0) ? recentSearches[$0] : nil }
        Task {
            do {
                for keyword in keywords {
                    try await recentSearchUseCase.delete(keyword: keyword)
                }
                await loadRecentSearches()
            } catch {
                recentSearches.removeAll { keywords.contains($0) }
            }
        }
    }

    func clearRecentSearches() {
        Task {
            do {
                try await recentSearchUseCase.clear()
            } catch {
                // 최근 검색어 삭제 실패 시 현재 화면 상태만 비운다.
            }
            recentSearches = []
        }
    }

    func searchRecentKeyword(_ keyword: String) {
        searchText = keyword
        Task { await search(keyword: keyword) }
    }

    private func loadRecentSearches() async {
        do {
            recentSearches = try await recentSearchUseCase.fetchAll()
        } catch {
            recentSearches = []
        }
    }

    private func saveRecentSearch(_ keyword: String) async {
        do {
            try await recentSearchUseCase.save(keyword: keyword)
            await loadRecentSearches()
        } catch {
            // 검색 성공 자체를 저장 실패로 되돌리지 않는다.
        }
    }

    func isFavorite(_ drug: Drug) -> Bool {
        favoriteItemSeqs.contains(drug.itemSeq)
    }

    func toggleFavorite(_ drug: Drug) {
        if isDetailLoading {
            pendingFavoriteToggle = true
            return
        }
        performToggle(drug)
    }

    private func performToggle(_ drug: Drug) {
        Task {
            do {
                try await favoriteDrugUseCase.toggle(drug: drug)
                await loadFavorites()
            } catch {
                detailError = (error as? AppError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    func removeFavorite(_ favoriteDrug: FavoriteDrug) {
        Task {
            do {
                try await favoriteDrugUseCase.delete(itemSeq: favoriteDrug.itemSeq)
                await loadFavorites()
            } catch {
                detailError = (error as? AppError)?.errorDescription ?? error.localizedDescription
            }
        }
    }

    func loadFavorites() async {
        do {
            let favorites = try await favoriteDrugUseCase.fetchAll()
            favoriteDrugs = favorites
            favoriteItemSeqs = Set(favorites.map(\.itemSeq))
        } catch {
            detailError = (error as? AppError)?.errorDescription ?? error.localizedDescription
        }
    }
}
