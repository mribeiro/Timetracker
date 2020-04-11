//
//  PreferenceMiscViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 11/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import AppKit
import Preferences

class PreferenceMiscViewController: NSViewController, Preferenceable {
    @IBOutlet weak var checkboxHideDockIcon: NSButton!
    
    var toolbarItemTitle: String = "Misc"
    
    var toolbarItemIcon: NSImage = NSImage(named: "log")!
    
    override var nibName: NSNib.Name? {
        return "PreferenceMiscView"
    }
    
    override func viewWillAppear() {
        self.checkboxHideDockIcon.state = DockIconManager.shouldHideIcon() ? .on : .off
    }
    
    @IBAction func hideDockIconChanged(_ sender: NSButtonCell) {
        DockIconManager.set(hideIcon: sender.state == .on)
    }
    
    
    
    
}
