//
//  ItemCoreEntity.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2/1/24.
//
//

import Foundation
import SwiftData

@Model public class ItemCoreEntity {
    var amount: Double
    var category: CategoryCoreEntity
    var note: String
    var timestamp: Date
    var title: String

    internal init(
        amount: Double,
        category: CategoryCoreEntity,
        note: String = "",
        timestamp: Date,
        title: String
    ) {
        self.amount = amount
        self.category = category
        self.note = note
        self.timestamp = timestamp
        self.title = title
    }

}
