//
//  ExamListWrapper.swift
//  Aran
//
//  Created by Iker Casillas on 5/13/26.
//

import SwiftUI
import UIKit
import AranDomain

struct ExamListWrapper: UIViewControllerRepresentable {
    let container: HealthRecordSceneDIContainer

    final class Coordinator {
        var flowCoordinator: HealthRecordFlowCoordinator?
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UINavigationController {
        let navController = UINavigationController()
        let flow = container.makeHealthRecordFlowCoordinator(navigationController: navController)
        context.coordinator.flowCoordinator = flow
        flow.start()
        return navController
    }

    func updateUIViewController(_: UINavigationController, context _: Context) {}
}
