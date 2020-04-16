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

typealias L = LogManager

final class LogManager {
    
    static let shared = LogManager()
    
    private(set) var level: Level
    private(set) var enabled: Bool
    private let logger = SwiftyBeaver.self
    
    var logFolder: String
    
    enum Level: Int {
        // These values must be in sync with SwiftyBeaver
        case Verbose = 1
        case Debug = 2
        case Info = 3
        case Warning = 4
        case Error = 5
        
        var asString: String {
            get {
                switch self {
                case .Verbose:
                    return "VERBOSE"
                case .Debug:
                    return "DEBUG"
                case .Info:
                    return "INFO"
                case .Warning:
                    return "WARNING"
                case .Error:
                    return "ERROR"
                }
            }
        }
        
        static var all: [Level] {
            return [.Verbose, .Debug, .Info, .Warning ,.Error]
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
        UserDefaults().set(enabled, forKey: "log_enabled")
        self.enabled = enabled
    }
    
    func setLevel(_ level: Level) {
        UserDefaults().set(level.rawValue, forKey: "log_level")
        self.level = level
    }
    
    private func i(_ message: String) {
        logMessage(message, withLevel: .Info)
    }
    
    private func d(_ message: String) {
        logMessage(message, withLevel: .Debug)
    }
    
    private func e(_ message: String) {
        logMessage(message, withLevel: .Error)
    }
    
    private func v(_ message: String) {
        logMessage(message, withLevel: .Verbose)
    }
    
    private init() {
        let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).last?.appendingPathComponent("timetracker/timetracker.log")
        
        let consoleLog = ConsoleDestination()
        let fileLog = FileDestination(logFileURL: url)
        
        self.logger.addDestination(consoleLog)
        self.logger.addDestination(fileLog)
        
        self.logFolder = fileLog.logFileURL?.path ?? "NA"
        
        self.enabled = UserDefaults().bool(forKey: "log_enabled")
        self.level = Level(rawValue: UserDefaults().integer(forKey: "log_level")) ?? .Error
        
    }
    
    private func logMessage(_ message: String, withLevel level: Level) {
        if (enabled && level.rawValue >= self.level.rawValue) {
            let swiftBeaverLevel = SwiftyBeaver.Level(rawValue: level.rawValue) ?? SwiftyBeaver.Level.error
            let message = "\(level.asString) | \(message)"
            self.logger.custom(level: swiftBeaverLevel, message: message)
        }
    }
    
}
