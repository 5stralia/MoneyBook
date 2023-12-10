//
//  Date.swift
//  MoneyBook
//
//  Created by Hoju Choi on 2023/06/19.
//

import Foundation

extension Date {
    func isEqualDateOnly(_ other: Date) -> Bool {
        let lhs = Calendar.current.dateComponents([.year, .month, .day], from: self)
        let rhs = Calendar.current.dateComponents([.year, .month, .day], from: other)

        return lhs.year == rhs.year && lhs.month == rhs.month && lhs.day == rhs.day
    }
}
