//
//  MoneyBookApp.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/10.
//

import SwiftData
import SwiftUI

@main
struct MoneyBookApp: App {
    let modelContainer = PersistenceController.shared.container

    private let homeQuickActionManager = HomeQuickActionManager.shared
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear(perform: {
                    let descriptor = FetchDescriptor<CategoryCoreEntity>(
                        predicate: #Predicate { $0.isExpense },
                        sortBy: [SortDescriptor<CategoryCoreEntity>(\.title)]
                    )

                    do {
                        let categories = try self.modelContainer.mainContext.fetch(descriptor)
                        if categories.isEmpty {
                            ["식비", "생활비", "교통비", "통신비", "기타"]
                                .forEach { category in
                                    self.modelContainer.mainContext.insert(
                                        CategoryCoreEntity(title: category, isExpense: true))
                                }
                            ["월급", "기타"]
                                .forEach { category in
                                    self.modelContainer.mainContext.insert(
                                        CategoryCoreEntity(title: category, isExpense: false))
                                }

                        }
                    } catch let error {
                        MyLogger.error("fetch categories error : \(error)")
                    }
                })
                .modelContainer(self.modelContainer)
                .environmentObject(self.homeQuickActionManager)
        }
    }
}
