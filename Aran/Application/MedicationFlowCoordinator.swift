//
//  MedicationFlowCoordinator.swift
//  Aran
//

import UIKit

struct MedicationListActions {
    let showSearch: () -> Void
    let showEdit: (Medication) -> Void
}

struct MedicationSearchActions {
    let showForm: (_ drugName: String, _ component: String, _ dosage: String) -> Void
    let close: () -> Void
}

struct MedicationFormActions {
    let onCancel: () -> Void
    let onSaveCompleted: () -> Void
    let onDelete: (Medication) -> Void
}

protocol MedicationFlowCoordinatorDependencies {
    func makeMedicationListViewController(actions: MedicationListActions) -> MedicationListViewController
    func makeMedicationSearchViewController(actions: MedicationSearchActions) -> MedicationSearchViewController
    func makeMedicationFormViewController(drugName: String, component: String, dosage: String, actions: MedicationFormActions) -> MedicationFormViewController
    func makeEditMedicationFormViewController(medication: Medication, actions: MedicationFormActions) -> MedicationFormViewController
    func deleteMedication(_ medication: Medication) async throws
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
            actions: MedicationListActions(
                showSearch: { [weak self] in self?.showSearch() },
                showEdit: { [weak self] medication in self?.showEdit(medication: medication) }
            )
        )
        navigationController?.setViewControllers([vc], animated: false)
    }

    private func showSearch() {
        let vc = dependencies.makeMedicationSearchViewController(
            actions: MedicationSearchActions(
                showForm: { [weak self] drugName, component, dosage in
                    self?.showForm(drugName: drugName, component: component, dosage: dosage)
                },
                close: { [weak self] in self?.navigationController?.popViewController(animated: true) }
            )
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showForm(drugName: String, component: String, dosage: String) {
        let actions = MedicationFormActions(
            onCancel: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onSaveCompleted: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            },
            onDelete: { _ in
            }
        )
        let vc = dependencies.makeMedicationFormViewController(
            drugName: drugName,
            component: component,
            dosage: dosage,
            actions: actions
        )
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showEdit(medication: Medication) {
        let actions = MedicationFormActions(
            onCancel: { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            },
            onSaveCompleted: { [weak self] in
                self?.navigationController?.popToRootViewController(animated: true)
            },
            onDelete: { [weak self] medication in
                self?.delete(medication: medication)
            }
        )
        let vc = dependencies.makeEditMedicationFormViewController(medication: medication, actions: actions)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func delete(medication: Medication) {
        Task { [weak self] in
            guard let self else { return }
            do {
                try await dependencies.deleteMedication(medication)
                await MainActor.run {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } catch {
                await MainActor.run {
                    let alert = UIAlertController(
                        title: "삭제 실패",
                        message: (error as? AppError)?.errorDescription ?? error.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "확인", style: .default))
                    self.navigationController?.topViewController?.present(alert, animated: true)
                }
            }
        }
    }
}
