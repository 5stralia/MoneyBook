//
//  Persistence.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/10.
//

import Foundation
import SwiftData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: ModelContainer

    @MainActor static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)

        let expenseCategoryCoreEntity1 = CategoryCoreEntity(title: "식비", iconName: "carrot", isExpense: true)
        result.container.mainContext.insert(expenseCategoryCoreEntity1)
        [10000, 7200, 12300, 50000, 67300, 273000, 2300, 4500]
            .enumerated()
            .forEach { offset, amount in
                result.container.mainContext.insert(
                    ItemCoreEntity(
                        amount: amount, category: expenseCategoryCoreEntity1, timestamp: Date(),
                        title: "식비 TEST \(offset)"))
            }

        let expenseCategoryCoreEntity2 = CategoryCoreEntity(title: "쇼핑", iconName: "atom", isExpense: true)
        result.container.mainContext.insert(expenseCategoryCoreEntity2)
        [10010, 7210, 12310, 50010, 67310, 273010, 2310, 4510]
            .enumerated()
            .forEach { offset, amount in
                result.container.mainContext.insert(
                    ItemCoreEntity(
                        amount: amount, category: expenseCategoryCoreEntity2, timestamp: Date(),
                        title: "쇼핑 TEST \(offset)"))
            }

        let incomeCategoryCoreEntity = CategoryCoreEntity(title: "용돈", iconName: "fish", isExpense: false)
        [700000, 200000]
            .enumerated()
            .forEach { offset, amount in
                result.container.mainContext.insert(
                    ItemCoreEntity(
                        amount: amount, category: incomeCategoryCoreEntity, timestamp: Date(),
                        title: "용돈 Test \(offset)"))
            }

        return result
    }()

    init(inMemory: Bool = false) {
        let schema = Schema([ItemCoreEntity.self, GroupCoreEntity.self, CategoryCoreEntity.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: inMemory)

        do {
            self.container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError()
        }

        //        container = NSPersistentContainer(name: "MoneyBook")
        //        if inMemory {
        //            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        //        }
        //        container.loadPersistentStores(completionHandler: { (_, error) in
        //            if let error = error as NSError? {
        //                // Replace this implementation with code to handle the error appropriately.
        //                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        //
        //                /*
        //                 Typical reasons for an error here include:
        //                 * The parent directory does not exist, cannot be created, or disallows writing.
        //                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
        //                 * The device is out of space.
        //                 * The store could not be migrated to the current model version.
        //                 Check the error message to determine what the actual problem was.
        //                 */
        //                fatalError("Unresolved error \(error), \(error.userInfo)")
        //            }
        //        })
        //        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
