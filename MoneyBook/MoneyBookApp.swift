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
                            let group = GroupCoreEntity(title: "default", createdDate: Date())
                            modelContainer.mainContext.insert(group)
                            GroupManager.shared.setGroup(group)

                            ["식비", "생활비", "교통비", "통신비", "기타"]
                                .forEach { title in
                                    let category = CategoryCoreEntity(title: title, isExpense: true)
                                    category.group = group
                                    modelContainer.mainContext.insert(category)
                                }
                            ["월급", "기타"]
                                .forEach { title in
                                    let category = CategoryCoreEntity(title: title, isExpense: false)
                                    category.group = group
                                    modelContainer.mainContext.insert(category)
                                }

                        } else {
                            let groupCount =
                                (try? modelContainer.mainContext.fetchCount(
                                    FetchDescriptor(predicate: #Predicate<GroupCoreEntity> { _ in true }))) ?? 0
                            if groupCount == 0 {
                                let group = GroupCoreEntity(title: "default", createdDate: Date())
                                modelContainer.mainContext.insert(group)
                                GroupManager.shared.setGroup(group)
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
