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
    var amount: Double = 0
    var note: String = ""
    var timestamp: Date = Date()
    var title: String = ""
    
    var category: CategoryCoreEntity?

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
