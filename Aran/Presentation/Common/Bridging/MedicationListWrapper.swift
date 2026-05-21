import SwiftUI
import UIKit

struct MedicationListWrapper: UIViewControllerRepresentable {
    let container: MedicationSceneDIContainer

    final class Coordinator {
        var flowCoordinator: MedicationFlowCoordinator?
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    func makeUIViewController(context: Context) -> UINavigationController {
        let navController = UINavigationController()
        let flow = container.makeMedicationFlowCoordinator(navigationController: navController)
        context.coordinator.flowCoordinator = flow
        flow.start()
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
