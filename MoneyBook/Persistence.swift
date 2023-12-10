//
//  Persistence.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/10.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    var viewContext: NSManagedObjectContext { self.container.viewContext }

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext

        let now = Date()
        let group_id = UUID()
        for k in 0..<12 {
            for i in 0..<10 {
                for j in 1..<4 {
                    let newItem = ItemCoreEntity(context: viewContext)
                    newItem.title = "Title \(i)_\(j)"
                    newItem.note = "Note \(i)_\(j)"
                    newItem.timestamp = Date(timeInterval: TimeInterval(-(60 * 60 * 24 * 30) * k) + TimeInterval(-(60 * 60 * 24) * i - j), since: now)
                    newItem.category = "Category\(i % 3)"
                    newItem.amount = 1000 * Double(j) * (j % 2 == 0 ? -1 : 1)
                    newItem.group_id = group_id
                }
            }
        }

        do {
            try ["식비", "생활비", "교통비", "통신비", "기타"].forEach { category in
                try result.addCategory(category)
            }

            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MoneyBook")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func addItem(_ item: ItemEntity) throws {
        let newItem = ItemCoreEntity(context: self.viewContext)
        newItem.timestamp = item.timestamp
        newItem.title = item.title
        newItem.note = item.note
        newItem.amount = item.amount
        newItem.category = item.category
        newItem.group_id = item.group_id

        try self.viewContext.save()
    }

    func updateItem(_ item: ItemEntity, coreItem: ItemCoreEntity) throws {
        coreItem.title = item.title
        coreItem.timestamp = item.timestamp
        coreItem.note = item.note
        coreItem.amount = item.amount
        coreItem.category = item.category
        coreItem.group_id = item.group_id

        try self.viewContext.save()
    }

    func addCategory(_ category: String) throws {
        let newCategory = CategoryCoreEntity(context: self.viewContext)
        newCategory.title = category

        try self.viewContext.save()
    }
}
