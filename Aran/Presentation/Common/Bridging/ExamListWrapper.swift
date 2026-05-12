//
//  ExamListWrapper.swift
//  Aran
//
//  Created by Iker Casillas on 5/13/26.
//


import SwiftUI
import UIKit

struct ExamListWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UINavigationController {
        UINavigationController(rootViewController: ExamListViewController())
    }
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {}
}
