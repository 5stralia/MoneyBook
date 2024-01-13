//
//  Double+format.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/13/24.
//

import Foundation

extension Double {
    func string(digits: Int) -> String? {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = digits // Minimum number of decimal places
        formatter.maximumFractionDigits = digits // Maximum number of decimal places
        formatter.numberStyle = .decimal

        return formatter.string(from: NSNumber(value: self))
    }
}
