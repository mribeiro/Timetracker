//
//  LogManager.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 29/03/2019.
//  Copyright © 2019 Antonio Ribeiro. All rights reserved.
//

import Foundation
import SwiftLog

typealias L = LogManager

final class LogManager {
    
    static let shared = LogManager()
    
    private(set) var level: Level
    private(set) var enabled: Bool
    
    var logFolder: String {
        return Log.logger.directory
    }
    
    enum Level: Int {
        case Debug = 0
        case Info = 1
        case Error = 2
        
        var asString: String {
            get {
                switch self {
                case .Debug:
                    return "DEBUG"
                case .Error:
                    return "ERROR"
                case .Info:
                    return "INFO"
                default:
                    return "NONE"
                }
            }
        }
        
        static var all: [Level] {
            return [.Debug, .Info, .Error, .None]
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
    
    
    func setEnabled(_ enabled: Bool) {
        UserDefaults().set(enabled, forKey: "log_enabled")
        self.enabled = enabled
    }
    
    func setLevel(_ level: Level) {
        UserDefaults().set(level.rawValue, forKey: "log_level")
        self.level = level
    }
    
    private func i(_ message: String) {
        self.logMessage(message, withLevel: .Info)
    }
    
    private func d(_ message: String) {
        self.logMessage(message, withLevel: .Debug)
    }
    
    private func e(_ message: String) {
        self.logMessage(message, withLevel: .Error)
    }
    
    private init() {
        Log.logger.directory = "\(Log.logger.directory)/Timetracker"
        self.enabled = UserDefaults().bool(forKey: "log_enabled")
        self.level = Level(rawValue: UserDefaults().integer(forKey: "log_level")) ?? .None
    }
    
    private func logMessage(_ message: String, withLevel level: Level) {
        if (enabled && level.rawValue >= self.level.rawValue) {
            let message = "\(level.asString) | \(message)"
            logw(message)
        }
    }
    
}
