//
//  MedicationFlowCoordinator.swift
//  Aran
//

import UIKit

struct MedicationListActions {
    let showSearch: () -> Void
}

struct MedicationSearchActions {
    let showForm: (_ drugName: String, _ dosage: String) -> Void
    let close: () -> Void
}

protocol MedicationFlowCoordinatorDependencies {
    func makeMedicationListViewController(actions: MedicationListActions) -> MedicationListViewController
    func makeMedicationSearchViewController(actions: MedicationSearchActions) -> MedicationSearchViewController
    func makeMedicationFormViewController(drugName: String, dosage: String, actions: MedicationFormActions) -> MedicationFormViewController
}

final class MedicationFlowCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: MedicationFlowCoordinatorDependencies

    init(navigationController: UINavigationController, dependencies: MedicationFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let vc = dependencies.makeMedicationListViewController(
            actions: MedicationListActions(showSearch: { [weak self] in self?.showSearch() })
        )
        navigationController?.setViewControllers([vc], animated: false)
    }

    private func showSearch() {
        let vc = dependencies.makeMedicationSearchViewController(
            actions: MedicationSearchActions(
                showForm: { [weak self] drugName, dosage in self?.showForm(drugName: drugName, dosage: dosage) },
                close: { [weak self] in self?.navigationController?.popViewController(animated: true) }
            )
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showForm(drugName: String, dosage: String) {
        let actions = MedicationFormActions(close: { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        })
        let vc = dependencies.makeMedicationFormViewController(drugName: drugName, dosage: dosage, actions: actions)
        navigationController?.pushViewController(vc, animated: true)
    }

    func startFormSheet(drugName: String, dosage: String) {
        let actions = MedicationFormActions(close: { [weak self] in
            self?.navigationController?.dismiss(animated: true)
        })
        let vc = dependencies.makeMedicationFormViewController(drugName: drugName, dosage: dosage, actions: actions)
        navigationController?.setViewControllers([vc], animated: false)
    }
}
