//
//  SplashContainerView.swift
//  Aran
//
//  Created by Iker Casillas on 6/3/26.
//

import SwiftUI

struct SplashContainerView<Content: View>: View {
    private let content: Content
    @State private var isShowingSplash = !UITestEnvironment.isEnabled

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            content
                .accessibilityHidden(isShowingSplash)

            if isShowingSplash {
                LaunchSplashView()
                    .allowsHitTesting(true)
            }
        }
        .task {
            await hideSplashIfNeeded()
        }
    }

    private func hideSplashIfNeeded() async {
        guard isShowingSplash else { return }
        try? await Task.sleep(for: .seconds(1))
        isShowingSplash = false
    }
}

private struct LaunchSplashView: View {
    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)

            Image("launchImage")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}
