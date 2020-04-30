//
//  AnalyticsManager.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 30/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import AppCenter
import AppCenterAnalytics

class AnalyticsManager {
    
    static func setup() {
        MSAppCenter.start("55bbb316-b1d2-41c1-bbf2-72eed9b6a604", withServices: [MSAnalytics.self])
    }
    
    static func windowOpened(_ name: String) {
        MSAnalytics.trackEvent("window-opened", withProperties: ["name": name])
    }
    
    static func taskStarted(_ entryPoint: String) {
        MSAnalytics.trackEvent("task-started", withProperties: ["entry-point": entryPoint])
    }
    
    static func taskStopped(_ entryPoint: String) {
        MSAnalytics.trackEvent("task-stopped", withProperties: ["entry-point": entryPoint])
    }
    
    static func builderChanged(_ newBuilder: String) {
        MSAnalytics.trackEvent("builder-changed", withProperties: ["new-builder": newBuilder])
    }
    
    static func dockIconEnabled() {
        MSAnalytics.trackEvent("dock-icon-enabled")
    }
    
    static func logsDisabled() {
        MSAnalytics.trackEvent("logs-disabled")
    }
    
    static func logsEnabled() {
        MSAnalytics.trackEvent("logs-enabled")
    }
    
    static func errorShownBecause(_ reason: String) {
        MSAnalytics.trackEvent("error-shown", withProperties: ["reason": reason])
    }
}
