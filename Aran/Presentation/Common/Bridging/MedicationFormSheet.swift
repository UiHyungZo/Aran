import SwiftUI
import UIKit

struct MedicationFormSheet: UIViewControllerRepresentable {

    let drugName: String
    let container: MedicationSceneDIContainer

    final class Coordinator {
        var flowCoordinator: MedicationFlowCoordinator?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let navController = UINavigationController()
        let flowCoordinator = container.makeMedicationFlowCoordinator(navigationController: navController)
        context.coordinator.flowCoordinator = flowCoordinator
        flowCoordinator.startFormSheet(drugName: drugName, dosage: "")
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
