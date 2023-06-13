//
//  GroupEntity+CoreDataProperties.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/13.
//
//

import Foundation
import CoreData


extension GroupEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GroupEntity> {
        return NSFetchRequest<GroupEntity>(entityName: "GroupEntity")
    }

    @NSManaged public var id: UUID
    @NSManaged public var title: String

}

extension GroupEntity : Identifiable {

}
