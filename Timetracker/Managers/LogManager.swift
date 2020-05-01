//
//  LogManager.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 29/03/2019.
//  Copyright © 2019 Antonio Ribeiro. All rights reserved.
//

import Foundation
import SwiftyBeaver
import Cocoa

//swiftlint:disable type_name
typealias L = LogManager
//swiftlint:enable type_name

final class LogManager {

    static let shared = LogManager()
    private let logPath = "timetracker/timetracker.log"

    private(set) var level: Level
    private(set) var enabled: Bool
    private let logger = SwiftyBeaver.self

    var logFolder: String

    enum Level: Int, Codable {
        // These values must be in sync with SwiftyBeaver
        case verbose = 1
        case debug = 2
        case info = 3
        case warning = 4
        case error = 5

        var asString: String {
            switch self {
            case .verbose:
                return "VERBOSE"
            case .debug:
                return "DEBUG"
            case .info:
                return "INFO"
            case .warning:
                return "WARNING"
            case .error:
                return "ERROR"
            }
        }

        static var all: [Level] {
            return [.verbose, .debug, .info, .warning, .error]
        }

        var intVal: Int {
            return self.rawValue
        }

    }

    static func i(_ message: String) {
        shared.i(message)
    }

    static func d(_ message: String) {
        shared.d(message)
    }

    static func e(_ message: String) {
        shared.e(message)
    }

    static func v(_ message: String) {
        shared.v(message)
    }

    func setEnabled(_ enabled: Bool) {
        U.get[.logsEnabled] = enabled
        self.enabled = enabled
        AnalyticsManager.logsChanged(enabled)
    }

    func setLevel(_ level: Level) {
        U.get[.logLevel] = level
        self.level = level
    }

    private func i(_ message: String) {
        logMessage(message, withLevel: .info)
    }

    private func d(_ message: String) {
        logMessage(message, withLevel: .debug)
    }

    private func e(_ message: String) {
        logMessage(message, withLevel: .error)
    }

    private func v(_ message: String) {
        logMessage(message, withLevel: .verbose)
    }

    private init() {
        let url = FileManager.default.urls(for: .cachesDirectory,
                                           in: .userDomainMask).last?.appendingPathComponent(logPath)

        let consoleLog = ConsoleDestination()
        let fileLog = FileDestination(logFileURL: url)

        self.logger.addDestination(consoleLog)
        self.logger.addDestination(fileLog)

        self.logFolder = fileLog.logFileURL?.path ?? "NA"

        self.enabled = U.get[.logsEnabled]
        self.level = U.get[.logLevel]

    }

    private func logMessage(_ message: String, withLevel level: Level) {
        if enabled && level.rawValue >= self.level.rawValue {
            let swiftBeaverLevel = SwiftyBeaver.Level(rawValue: level.rawValue) ?? SwiftyBeaver.Level.error
            let message = "\(level.asString) | \(message)"
            self.logger.custom(level: swiftBeaverLevel, message: message)
        }
    }

}
