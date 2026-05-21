//
//  HealthRecordSceneDIContainer.swift
//  Aran
//

import UIKit
import SwiftData

@MainActor
final class HealthRecordSceneDIContainer: HealthRecordFlowCoordinatorDependencies {

    struct Dependencies {
        let modelContext: ModelContext
    }

    private let dependencies: Dependencies

    private lazy var healthRecordRepository: HealthRecordRepositoryProtocol =
        HealthRecordRepository(context: dependencies.modelContext)

    private lazy var healthRecordUseCase: HealthRecordUseCase =
        HealthRecordUseCase(repository: healthRecordRepository)

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    // MARK: - HealthRecordFlowCoordinatorDependencies

    func makeExamListViewController() -> ExamListViewController {
        ExamListViewController()
    }

    // MARK: - Flow Coordinator

    func makeHealthRecordFlowCoordinator(navigationController: UINavigationController) -> HealthRecordFlowCoordinator {
        HealthRecordFlowCoordinator(navigationController: navigationController, dependencies: self)
    }
}
