//
//  MoneyBookApp.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/10.
//

import SwiftUI

@main
struct MoneyBookApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
