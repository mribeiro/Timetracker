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
        return UserDefaults().bool(forKey: "hide_dock_icon")
    }
    
    class func set(hideIcon: Bool) {
        UserDefaults().set(hideIcon, forKey: "hide_dock_icon")
        let policy: NSApplication.ActivationPolicy = hideIcon ? .accessory : .regular
        NSApplication.shared.setActivationPolicy(policy)
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
