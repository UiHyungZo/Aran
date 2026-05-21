//
//  MedicationSceneDIContainer.swift
//  Aran
//

import UIKit
import SwiftData

@MainActor
final class MedicationSceneDIContainer: MedicationFlowCoordinatorDependencies {

    struct Dependencies {
        let modelContext: ModelContext
        let drugServiceKey: String
        let drugAPIEndpoint: String
    }

    private let dependencies: Dependencies

    private lazy var medicationRepository: MedicationRepositoryProtocol =
        MedicationRepository(context: dependencies.modelContext)

    private lazy var notificationRepository: NotificationRepositoryProtocol =
        NotificationManager()

    private lazy var medicationUseCase: MedicationUseCase =
        MedicationUseCase(
            medicationRepository: medicationRepository,
            notificationRepository: notificationRepository
        )

    private lazy var drugRepository: DrugRepositoryProtocol =
        DrugRepository(serviceKey: dependencies.drugServiceKey, baseURL: dependencies.drugAPIEndpoint)

    private lazy var searchDrugUseCase: SearchDrugUseCase =
        SearchDrugUseCase(repository: drugRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - MedicationFlowCoordinatorDependencies

    func makeMedicationListViewController(actions: MedicationListActions) -> MedicationListViewController {
        MedicationListViewController(
            viewModel: MedicationViewModel(medicationUseCase: medicationUseCase),
            actions: actions
        )
    }

    func makeMedicationSearchViewController(actions: MedicationSearchActions) -> MedicationSearchViewController {
        MedicationSearchViewController(
            searchDrugUseCase: searchDrugUseCase,
            actions: actions
        )
    }

    func makeMedicationFormViewController(drugName: String, dosage: String) -> MedicationFormViewController {
        MedicationFormViewController(
            viewModel: MedicationFormViewModel(medicationUseCase: medicationUseCase),
            initialDrugName: drugName,
            initialDosage: dosage
        )
    }

    // MARK: - Flow Coordinator

    func makeMedicationFlowCoordinator(navigationController: UINavigationController) -> MedicationFlowCoordinator {
        MedicationFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}
