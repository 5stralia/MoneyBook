//
//  SceneDelegate.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/28/24.
//

import UIKit

class SceneDelegate: NSObject, UIWindowSceneDelegate {

    private let homeQuickActionManager = HomeQuickActionManager.shared

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let shortcutItem = connectionOptions.shortcutItem {
            self.homeQuickActionManager.action = HomeQuickAction(type: shortcutItem.type)
        }
    }

    func windowScene(
        _ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        homeQuickActionManager.action = HomeQuickAction(type: shortcutItem.type)
        completionHandler(true)
    }
}
