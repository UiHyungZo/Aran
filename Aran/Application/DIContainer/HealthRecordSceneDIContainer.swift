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

    private lazy var healthRecordUseCase: HealthRecordUseCase =
        .init(repository: healthRecordRepository)

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

    func makeHealthRecordFormViewController(onSaved: @escaping () -> Void) -> UIViewController {
        HealthRecordFormViewController(
            viewModel: HealthRecordFormViewModel(useCase: healthRecordUseCase),
            onSaved: onSaved
        )
    }

    func makeExamHistoryViewController(item: TestItem, actions: ExamHistoryActions) -> ExamHistoryViewController {
        ExamHistoryViewController(
            viewModel: ExamHistoryViewModel(useCase: healthRecordUseCase, item: item),
            actions: actions
        )
    }

    // MARK: - Flow Coordinator

    func makeHealthRecordFlowCoordinator(navigationController: UINavigationController) -> HealthRecordFlowCoordinator {
        HealthRecordFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}
