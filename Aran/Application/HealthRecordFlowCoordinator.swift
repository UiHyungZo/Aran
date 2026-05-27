import UIKit

struct ExamListActions {
    let showAddForm: () -> Void
    let showEditForm: (_ record: HealthRecord) -> Void
    let showHistory: (_ type: String) -> Void
}

protocol HealthRecordFlowCoordinatorDependencies {
    func makeExamListViewController(actions: ExamListActions) -> ExamListViewController
    func makeHealthRecordFormViewController(mode: HealthRecordFormViewModel.FormMode, onSaved: @escaping () -> Void) -> UIViewController
    func makeExamHistoryViewController(type: String, actions: ExamHistoryActions) -> ExamHistoryViewController
}

final class HealthRecordFlowCoordinator {
    private weak var navigationController: UINavigationController?
    private let dependencies: HealthRecordFlowCoordinatorDependencies
    private weak var listViewController: ExamListViewController?

    init(navigationController: UINavigationController, dependencies: HealthRecordFlowCoordinatorDependencies) {
        self.navigationController = navigationController
        self.dependencies = dependencies
    }

    func start() {
        let vc = dependencies.makeExamListViewController(
            actions: ExamListActions(
                showAddForm: { [weak self] in self?.showNumericForm() },
                showEditForm: { [weak self] record in self?.showEditForm(record: record) },
                showHistory: { [weak self] type in self?.showHistory(type: type) }
            )
        )
        listViewController = vc
        navigationController?.setViewControllers([vc], animated: false)
    }

    private func showNumericForm() {
        let vc = dependencies.makeHealthRecordFormViewController(mode: .add, onSaved: { [weak self] in
            self?.listViewController?.reload()
        })
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController?.topViewController?.present(vc, animated: true)
    }

    private func showEditForm(record: HealthRecord) {
        let vc = dependencies.makeHealthRecordFormViewController(mode: .edit(record: record), onSaved: { [weak self] in
            self?.listViewController?.reload()
        })
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showHistory(type: String) {
        let actions = ExamHistoryActions(
            showAddForm: { [weak self] in
                self?.showNumericForm()
            }
        )
        let vc = dependencies.makeExamHistoryViewController(type: type, actions: actions)
        navigationController?.pushViewController(vc, animated: true)
    }
}
