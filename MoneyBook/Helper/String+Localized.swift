//
//  String+Localized.swift
//  MoneyBook
//
//  Created by Hoju Choi on 5/4/24.
//

import Foundation

extension String {
    var localized: String {
        String(localized: LocalizedStringResource(String.LocalizationValue(self)))
    }
}
