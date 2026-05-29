import Foundation
import SwiftData

@MainActor
final class DrugInfoSceneDIContainer {
    struct Dependencies {
        let modelContext: ModelContext
        let drugServiceKey: String
        let drugAPIEndpoint: String
    }

    private let dependencies: Dependencies

    private lazy var drugRepository: DrugRepositoryProtocol =
        DrugRepository(serviceKey: dependencies.drugServiceKey, baseURL: dependencies.drugAPIEndpoint)

    private lazy var searchDrugUseCase: SearchDrugUseCaseProtocol =
        SearchDrugUseCase(repository: drugRepository)

    private lazy var favoriteDrugRepository: FavoriteDrugRepositoryProtocol =
        FavoriteDrugRepository(context: dependencies.modelContext)

    private lazy var favoriteDrugUseCase: FavoriteDrugUseCaseProtocol =
        FavoriteDrugUseCase(repository: favoriteDrugRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func makeDrugInfoViewModel() -> DrugInfoViewModel {
        DrugInfoViewModel(
            searchDrugUseCase: searchDrugUseCase,
            favoriteDrugUseCase: favoriteDrugUseCase
        )
    }
}
