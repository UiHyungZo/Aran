//
//  HealthRecordFlowCoordinator.swift
//  Aran
//

import UIKit

protocol HealthRecordFlowCoordinatorDependencies {
    func makeExamListViewController() -> ExamListViewController
}

final class HealthRecordFlowCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: HealthRecordFlowCoordinatorDependencies

    init(navigationController: UINavigationController, dependencies: HealthRecordFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let vc = dependencies.makeExamListViewController()
        navigationController?.setViewControllers([vc], animated: false)
    }
}
