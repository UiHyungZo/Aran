//
//  HealthRecordSceneDIContainer.swift
//  Aran
//

import SwiftData
import UIKit

@MainActor
final class HealthRecordSceneDIContainer: HealthRecordFlowCoordinatorDependencies {
    struct Dependencies {
        let modelContext: ModelContext
    }

    private let dependencies: Dependencies

    private lazy var healthRecordRepository: HealthRecordRepositoryProtocol =
        HealthRecordRepository(context: dependencies.modelContext)

    private lazy var healthRecordUseCase: HealthRecordUseCaseProtocol =
        HealthRecordUseCase(repository: healthRecordRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - HealthRecordFlowCoordinatorDependencies

    func makeExamListViewController(actions: ExamListActions) -> ExamListViewController {
        ExamListViewController(
            viewModel: HealthRecordViewModel(useCase: healthRecordUseCase),
            actions: actions
        )
    }

    func makeHealthRecordFormViewController(
        mode: HealthRecordFormViewModel.FormMode,
        onSaved: @escaping () -> Void
    ) -> UIViewController {
        HealthRecordFormViewController(
            viewModel: HealthRecordFormViewModel(useCase: healthRecordUseCase, mode: mode),
            mode: mode,
            onSaved: onSaved
        )
    }

    func makeExamHistoryViewController(type: String, actions: ExamHistoryActions) -> ExamHistoryViewController {
        ExamHistoryViewController(
            viewModel: ExamHistoryViewModel(useCase: healthRecordUseCase, type: type),
            actions: actions
        )
    }

    // MARK: - Flow Coordinator

    func makeHealthRecordFlowCoordinator(navigationController: UINavigationController) -> HealthRecordFlowCoordinator {
        HealthRecordFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}
