//
//  MedicationListWrapper.swift
//  Aran
//
//  Created by Iker Casillas on 5/13/26.
//

import SwiftUI
import UIKit

struct MedicationListWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: MedicationListViewController())
    }
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}


