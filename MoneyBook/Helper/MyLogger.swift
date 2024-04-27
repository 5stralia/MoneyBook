//
//  MyLogger.swift
//  MoneyBook
//
//  Created by Hoju Choi on 1/14/24.
//

import OSLog

enum MyLogger {
    static private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "logger")
    
    static func debug(_ message: String) {
        logger.debug("\(message)")
    }
    
    static func notice(_ message: String) {
        logger.notice("\(message)")
    }
    
    static func error(_ message: String) {
        logger.error("\(message)")
    }
    
    static func fault(_ message: String) {
        logger.fault("\(message)")
    }
}
