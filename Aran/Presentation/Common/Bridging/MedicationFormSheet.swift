import SwiftUI
import UIKit

struct MedicationFormSheet: UIViewControllerRepresentable {
    let drugName: String
    let container: MedicationSceneDIContainer
    @Environment(\.dismiss) private var dismiss

    final class Coordinator {
        let dismiss: DismissAction
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let actions = MedicationFormActions(
            onCancel: { context.coordinator.dismiss() },
            onSaveCompleted: { context.coordinator.dismiss() }
        )
        let vc = container.makeMedicationFormViewController(drugName: drugName, dosage: "", actions: actions)
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}
}
