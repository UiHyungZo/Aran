import SwiftUI
import UIKit

struct MedicationListWrapper: UIViewControllerRepresentable {
    let container: DIContainer

    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: container.makeMedicationListViewController())
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
