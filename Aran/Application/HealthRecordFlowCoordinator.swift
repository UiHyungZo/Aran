import UIKit

struct ExamListActions {
    let showAddForm: () -> Void
    let showHistory: (_ item: TestItem) -> Void
}

protocol HealthRecordFlowCoordinatorDependencies {
    func makeExamListViewController(actions: ExamListActions) -> ExamListViewController
    func makeHealthRecordFormViewController(onSaved: @escaping () -> Void) -> UIViewController
    func makeExamHistoryViewController(item: TestItem, actions: ExamHistoryActions) -> ExamHistoryViewController
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
                showHistory: { [weak self] item in self?.showHistory(item: item) }
            )
        )
        listViewController = vc
        navigationController?.setViewControllers([vc], animated: false)
    }

    private func showNumericForm() {
        let vc = dependencies.makeHealthRecordFormViewController(onSaved: { [weak self] in
            self?.listViewController?.reload()
        })
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        navigationController?.topViewController?.present(vc, animated: true)
    }

    private func showHistory(item: TestItem) {
        let actions = ExamHistoryActions(
            showAddForm: { [weak self] in
                self?.showAddFormForItem(item)
            }
        )
        let vc = dependencies.makeExamHistoryViewController(item: item, actions: actions)
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showAddFormForItem(_ item: TestItem) {
        showNumericForm()
    }
}
