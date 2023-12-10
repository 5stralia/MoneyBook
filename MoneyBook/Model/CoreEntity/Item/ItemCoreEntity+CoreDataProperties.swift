//
//  ItemCoreEntity+CoreDataProperties.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/07/30.
//
//

import CoreData
import Foundation

extension ItemCoreEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemCoreEntity> {
        return NSFetchRequest<ItemCoreEntity>(entityName: "ItemCoreEntity")
    }

    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var group_id: UUID
    @NSManaged public var note: String
    @NSManaged public var timestamp: Date
    @NSManaged public var title: String

}

extension ItemCoreEntity: Identifiable {

}
