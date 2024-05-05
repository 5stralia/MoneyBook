//
//  GroupCoreEntity.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2/1/24.
//
//

import Foundation
import SwiftData

@Model public class GroupCoreEntity {
    var title: String = "unknown"
    var createdDate: Date = Date()
    
    @Relationship(inverse: \CategoryCoreEntity.group) var categories: [CategoryCoreEntity]?
    
    public init(title: String, createdDate: Date) {
        self.title = title
        self.createdDate = createdDate

    }

}
