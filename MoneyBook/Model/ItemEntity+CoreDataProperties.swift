//
//  ItemEntity+CoreDataProperties.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/13.
//
//

import Foundation
import CoreData


extension ItemEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ItemEntity> {
        return NSFetchRequest<ItemEntity>(entityName: "ItemEntity")
    }

    @NSManaged public var timestamp: Date
    @NSManaged public var title: String
    @NSManaged public var note: String
    @NSManaged public var amount: Double
    @NSManaged public var category: String
    @NSManaged public var group_id: UUID

}

extension ItemEntity : Identifiable {

}
