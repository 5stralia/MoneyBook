//
//  GroupCoreEntity+CoreDataProperties.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/07/30.
//
//

import Foundation
import CoreData


extension GroupCoreEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupCoreEntity> {
        return NSFetchRequest<GroupCoreEntity>(entityName: "GroupCoreEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String

}

extension GroupCoreEntity : Identifiable {

}
