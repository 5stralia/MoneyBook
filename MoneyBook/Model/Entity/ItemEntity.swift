//
//  ItemEntity.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/07/30.
//

import Foundation

struct ItemEntity {
    let amount: Double
    let category: String
    let group_id: UUID
    let note: String
    let timestamp: Date
    let title: String
}
