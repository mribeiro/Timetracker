//
//  DefaultsManager.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 01/05/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Defaults
import AppKit

extension Defaults.Keys {
    static let hideDockIcon = Key<Bool>("hide_dock_icon", default: false)
    static let analyticsDisabled = Key<Bool>("analytics_disabled", default: false)
    static let logsEnabled = Key<Bool>("log_enabled", default: false)
    static let logLevel = Key<L.Level>("log_level", default: .error)
    static let builder = Key<String>("builder", default: "monkey")
}

//swiftlint:disable type_name
typealias U = DefaultsManager
//swiftlint:enable type_name

final class DefaultsManager {

    static var get: UserDefaults {
        if let delegate = NSApplication.appDelegate, delegate.runningInProd {
            return UserDefaults()
        } else {
            return UserDefaults(suiteName: "org.aribeiro.Timetracker-dev")!
        }
    }

}
