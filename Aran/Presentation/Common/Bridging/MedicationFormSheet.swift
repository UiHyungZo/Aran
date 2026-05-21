import SwiftUI
import UIKit

struct MedicationFormSheet: UIViewControllerRepresentable {

    let drugName: String
    let container: MedicationSceneDIContainer

    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = container.makeMedicationFormViewController(drugName: drugName, dosage: "")
        return UINavigationController(rootViewController: vc)
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
