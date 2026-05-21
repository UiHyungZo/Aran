import Foundation

@MainActor
final class DrugInfoSceneDIContainer {

    struct Dependencies {
        let drugServiceKey: String
        let drugAPIEndpoint: String
    }

    private let dependencies: Dependencies

    private lazy var drugRepository: DrugRepositoryProtocol =
        DrugRepository(serviceKey: dependencies.drugServiceKey, baseURL: dependencies.drugAPIEndpoint)

    private lazy var searchDrugUseCase: SearchDrugUseCase =
        SearchDrugUseCase(repository: drugRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func makeDrugInfoViewModel() -> DrugInfoViewModel {
        DrugInfoViewModel(searchDrugUseCase: searchDrugUseCase)
    }
}
