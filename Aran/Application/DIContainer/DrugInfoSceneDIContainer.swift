import Foundation
import SwiftData

@MainActor
final class DrugInfoSceneDIContainer {
    struct Dependencies {
        let modelContext: ModelContext
        let drugServiceKey: String
        let drugAPIEndpoint: String
        let drugApprovalServiceKey: String
        let drugApprovalAPIEndpoint: String
    }

    private let dependencies: Dependencies

    private lazy var drugRepository: DrugRepositoryProtocol =
        DrugRepository(
            serviceKey: dependencies.drugServiceKey,
            baseURL: dependencies.drugAPIEndpoint,
            approvalServiceKey: dependencies.drugApprovalServiceKey,
            approvalBaseURL: dependencies.drugApprovalAPIEndpoint
        )

    private lazy var searchDrugUseCase: SearchDrugUseCaseProtocol =
        SearchDrugUseCase(repository: drugRepository)

    private lazy var favoriteDrugRepository: FavoriteDrugRepositoryProtocol =
        FavoriteDrugRepository(context: dependencies.modelContext)

    private lazy var favoriteDrugUseCase: FavoriteDrugUseCaseProtocol =
        FavoriteDrugUseCase(repository: favoriteDrugRepository)

    private lazy var recentDrugSearchRepository: RecentDrugSearchRepositoryProtocol =
        RecentDrugSearchRepository(context: dependencies.modelContext)

    private lazy var recentDrugSearchUseCase: RecentDrugSearchUseCaseProtocol =
        RecentDrugSearchUseCase(repository: recentDrugSearchRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func makeDrugInfoViewModel() -> DrugInfoViewModel {
        DrugInfoViewModel(
            searchDrugUseCase: searchDrugUseCase,
            favoriteDrugUseCase: favoriteDrugUseCase,
            recentSearchUseCase: recentDrugSearchUseCase
        )
    }
}
