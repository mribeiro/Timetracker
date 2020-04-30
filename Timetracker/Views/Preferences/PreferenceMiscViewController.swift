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

class PreferenceMiscViewController: TrackedViewController, PreferencePane {
    var preferencePaneIdentifier: Identifier = PreferencePaneIdentifier.Identifier.misc

    var preferencePaneTitle: String = "Misc"

    @IBOutlet weak var checkboxHideDockIcon: NSButton!

    var toolbarItemTitle: String = "Misc"

    var toolbarItemIcon: NSImage = NSImage(named: "icon-switch")!

    override var nibName: NSNib.Name? {
        "PreferenceMiscView"
    }
    
    override var analyticsScreenName: String? { "preferences-misc" }

    override func viewDidLoad() {
        preferredContentSize = NSSize(width: 600, height: 200)
    }

    override func viewWillAppear() {
        self.checkboxHideDockIcon.state = DockIconManager.shouldHideIcon() ? .on : .off
    }

    @IBAction func hideDockIconChanged(_ sender: NSButtonCell) {
        DockIconManager.set(hideIcon: sender.state == .on)
    }
}
