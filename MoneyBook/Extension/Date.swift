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

    var startDateOfMonth: Date {
        guard let date = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: self))
        else {
            fatalError("Unable to get start date from date")
        }
        return date
    }

    var endDateOfMonth: Date {
        guard let date = Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startDateOfMonth)
        else {
            fatalError("Unable to get end date from date")
        }
        return date
    }
}
