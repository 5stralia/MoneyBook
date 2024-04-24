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
    @Relationship var category: CategoryCoreEntity?
    var note: String
    var timestamp: Date
    var title: String

    internal init(
        amount: Double,
        note: String = "",
        timestamp: Date,
        title: String
    ) {
        self.amount = amount
        self.note = note
        self.timestamp = timestamp
        self.title = title
    }

}
