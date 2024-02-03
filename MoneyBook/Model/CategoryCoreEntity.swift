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
    var title: String
    var iconName: String
    var isExpense: Bool

    public init(title: String, iconName: String, isExpense: Bool) {
        self.title = title
        self.iconName = iconName
        self.isExpense = isExpense
    }

}
