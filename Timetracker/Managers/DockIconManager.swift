//
//  DockerIconManager.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 11/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

class DockIconManager {

    class func shouldHideIcon() -> Bool {
        return U.get[.hideDockIcon]
    }

    class func set(hideIcon: Bool) {
        U.get[.hideDockIcon] = hideIcon
        let policy: NSApplication.ActivationPolicy = hideIcon ? .accessory : .regular
        NSApplication.shared.setActivationPolicy(policy)
        AnalyticsManager.dockIconStatusHidden(hideIcon)
    }

    class func setIconPerConfiguration() {
        let hideIcon = shouldHideIcon()
        iconHidden(hideIcon)
    }

    private class func iconHidden(_ hideIcon: Bool) {
        let policy: NSApplication.ActivationPolicy = hideIcon ? .accessory : .regular
        NSApplication.shared.setActivationPolicy(policy)
    }

}
