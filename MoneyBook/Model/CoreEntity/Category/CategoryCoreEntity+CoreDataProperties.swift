//
//  CategoryCoreEntity+CoreDataProperties.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/07/31.
//
//

import Foundation
import CoreData

extension CategoryCoreEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryCoreEntity> {
        return NSFetchRequest<CategoryCoreEntity>(entityName: "CategoryCoreEntity")
    }

    @NSManaged public var title: String

}

extension CategoryCoreEntity: Identifiable {

}
