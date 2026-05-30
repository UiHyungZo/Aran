//
//  SceneDelegate.swift
//  Aran
//
//  Created by Iker Casillas on 5/3/26.
//

import SwiftData
import SwiftUI
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let modelContainer: ModelContainer
        do {
            modelContainer = try Self.makeModelContainer()
        } catch {
            fatalError("ModelContainer 초기화 실패: \(error)")
        }

        let diContainer = AppDIContainer(modelContainer: modelContainer)
        let rootView = MainTabView(container: diContainer)

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = UIHostingController(rootView: rootView)
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }

    private static func makeModelContainer() throws -> ModelContainer {
        let schema = Schema(AppSchemaV4.models)
        let storeURL = URL.applicationSupportDirectory.appending(path: "default.store")
        let configuration = ModelConfiguration(schema: schema, url: storeURL)

        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: AppMigrationPlan.self,
                configurations: [configuration]
            )
        } catch {
            resetLocalStore(at: storeURL)
            return try ModelContainer(for: schema, configurations: [configuration])
        }
    }

    private static func resetLocalStore(at storeURL: URL) {
        let fileManager = FileManager.default
        let storeDirectory = storeURL.deletingLastPathComponent()
        let storeFileName = storeURL.lastPathComponent
        let relatedURLs = [
            storeURL,
            storeDirectory.appending(path: "\(storeFileName)-shm"),
            storeDirectory.appending(path: "\(storeFileName)-wal")
        ]

        for url in relatedURLs where fileManager.fileExists(atPath: url.path) {
            try? fileManager.removeItem(at: url)
        }
    }
}
