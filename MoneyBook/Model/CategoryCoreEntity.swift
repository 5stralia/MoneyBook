//
//  CategoryCoreEntity.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2/1/24.
//
//

import Foundation
import SwiftData

@Model public class CategoryCoreEntity {
    var title: String = ""
    var isExpense: Bool = true
    
    @Relationship(inverse: \ItemCoreEntity.category) var items: [ItemCoreEntity]?
    
    var group: GroupCoreEntity?

    public init(title: String, isExpense: Bool) {
        self.title = title
        self.isExpense = isExpense
    }

}
