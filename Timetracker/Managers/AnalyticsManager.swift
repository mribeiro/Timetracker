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
import AppCenterCrashes

class AnalyticsManager {

    static var isEnabled: Bool { UserDefaults().bool(forKey: "analytics_disabled") }

    static func setup() {
        let analyticsDisabled = UserDefaults().bool(forKey: "analytics_disabled")

        L.d("Analytics are disabled: \(analyticsDisabled)")

        MSAppCenter.setEnabled(!analyticsDisabled)
        MSAppCenter.start("55bbb316-b1d2-41c1-bbf2-72eed9b6a604", withServices: [MSAnalytics.self, MSCrashes.self])
    }

    static func switchAnalytics(_ disable: Bool) {
        UserDefaults().set(disable, forKey: "analytics_disabled")
        MSAppCenter.setEnabled(disable)
        MSAnalytics.trackEvent("analytics-changed", withProperties: ["disabled": disable.description])
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

    static func dockIconStatusHidden(_ hide: Bool) {
        MSAnalytics.trackEvent("dock-icon-changed", withProperties: ["hide": hide.description])
    }

    static func logsChanged(_ enabled: Bool) {
        MSAnalytics.trackEvent("logs-changed", withProperties: ["enabled": enabled.description])
    }

    static func errorShownBecause(_ reason: String) {
        MSAnalytics.trackEvent("error-shown", withProperties: ["reason": reason])
    }
}
