//
//  AppDelegate.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/28/24.
//

import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    private let homeQuickActionManager = HomeQuickActionManager.shared

    func application(
        _ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            homeQuickActionManager.action = HomeQuickAction(type: shortcutItem.type)
        }
        let configuration = UISceneConfiguration(
            name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
}
