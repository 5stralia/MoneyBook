//
//  MyLogger.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/14/24.
//

import OSLog

enum MyLogger {
    static let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "logger")
}
