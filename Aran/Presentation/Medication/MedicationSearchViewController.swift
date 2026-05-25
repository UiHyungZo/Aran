import SwiftUI
import UIKit

final class MedicationSearchViewController: UIViewController {
    private let viewModel: DrugInfoViewModel
    private let actions: MedicationSearchActions
    private var hostingController: UIHostingController<DrugSearchView>?

    init(searchDrugUseCase: SearchDrugUseCase, actions: MedicationSearchActions) {
        viewModel = DrugInfoViewModel(searchDrugUseCase: searchDrugUseCase)
        self.actions = actions
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        embedDrugSearchView()
    }

    private func embedDrugSearchView() {
        let searchView = DrugSearchView(
            title: "약 검색",
            mode: .register,
            viewModel: viewModel,
            onAddDrug: { _ in },
            onRegisterDrug: { [weak self] drugName, dosage in
                self?.actions.showForm(drugName, dosage)
            },
            onClose: { [weak self] in
                self?.actions.close()
            }
        )

        let hostingController = UIHostingController(rootView: searchView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }
}
