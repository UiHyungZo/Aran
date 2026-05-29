//
//  MedicationSceneDIContainer.swift
//  Aran
//

import SwiftData
import UIKit

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

    private lazy var medicationUseCase: MedicationUseCaseProtocol =
        MedicationUseCase(
            medicationRepository: medicationRepository,
            notificationRepository: notificationRepository
        )

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
            favoriteDrugUseCase: favoriteDrugUseCase,
            actions: actions
        )
    }

    func makeMedicationFormViewController(
        drugName: String,
        component: String,
        dosage: String,
        actions: MedicationFormActions
    ) -> MedicationFormViewController {
        MedicationFormViewController(
            viewModel: MedicationFormViewModel(medicationUseCase: medicationUseCase),
            actions: actions,
            initialDrugName: drugName,
            initialComponent: component,
            initialDosage: dosage
        )
    }

    func makeEditMedicationFormViewController(medication: Medication, actions: MedicationFormActions) -> MedicationFormViewController {
        MedicationFormViewController(
            viewModel: MedicationFormViewModel(
                medicationUseCase: medicationUseCase,
                initialMedication: medication
            ),
            actions: actions,
            initialMedication: medication
        )
    }

    func makeNotificationSettingsViewController() -> NotificationSettingsViewController {
        NotificationSettingsViewController(
            viewModel: MedicationViewModel(medicationUseCase: medicationUseCase)
        )
    }

    // MARK: - Flow Coordinator

    func makeMedicationFlowCoordinator(navigationController: UINavigationController) -> MedicationFlowCoordinator {
        MedicationFlowCoordinator(navigationController: navigationController, dependencies: self)
    }

    func deleteMedication(_ medication: Medication) async throws {
        try await medicationUseCase.delete(medication: medication)
    }
}
