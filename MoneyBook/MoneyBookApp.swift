//
//  MoneyBookApp.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/10.
//

import SwiftUI

@main
struct MoneyBookApp: App {
    //    let persistenceController = PersistenceController.shared
    let persistenceController = PersistenceController.preview

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    do {
                        let categories = try persistenceController.viewContext.fetch(
                            CategoryCoreEntity.fetchRequest())
                        if categories.isEmpty {
                            try ["식비", "생활비", "교통비", "통신비", "기타"].forEach { category in
                                try persistenceController.addCategory(category)
                            }
                        }
                    } catch {
                        print("에러다다다!!!")
                    }
                })
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
