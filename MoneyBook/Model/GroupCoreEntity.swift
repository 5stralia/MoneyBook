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
    var createdDate: Date
    @Relationship var items: [ItemCoreEntity]?
    @Relationship var categories: [CategoryCoreEntity]?
    public init(createdDate: Date) {
        self.createdDate = createdDate

    }

}
