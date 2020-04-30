//
//  PreferenceLogViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 05/04/2019.
//  Copyright © 2019 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa
import Preferences

class PreferenceLogViewController: TrackedViewController, PreferencePane {

    var preferencePaneIdentifier: Identifier = PreferencePaneIdentifier.Identifier.logs

    var preferencePaneTitle: String = "Log"

    var toolbarItemTitle: String = "Log"

    var toolbarItemIcon: NSImage = NSImage(named: "icon-log")!

    @IBOutlet weak var logFolderPath: NSTextField!
    @IBOutlet weak var logEnabled: NSButton!
    @IBOutlet weak var logLevelsPopup: NSPopUpButton!

    override var nibName: NSNib.Name? {
        "PreferenceLogView"
    }

    override var analyticsScreenName: String? { "preferences-log" }

    override func viewDidLoad() {
        super.viewDidLoad()
        logFolderPath.stringValue = LogManager.shared.logFolder
        logEnabled.state = LogManager.shared.enabled ? .on : .off
        loadLogLevels()
        preferredContentSize = NSSize(width: 600, height: 200)
    }

    @IBAction func logsToggled(_ sender: NSButtonCell) {
        let newState = sender.state == .on ? true : false
        LogManager.shared.setEnabled(newState)
    }

    private func loadLogLevels() {
        self.logLevelsPopup.removeAllItems()
        self.logLevelsPopup.addItems(withTitles: LogManager.Level.all.map({ (level) -> String in
            level.asString
        }))

        self.logLevelsPopup.selectItem(at: LogManager.shared.level.intVal - 1)
    }

    @IBAction func logLevelChanged(_ sender: NSPopUpButton) {
        let selectedLevel = LogManager.Level(rawValue: sender.indexOfSelectedItem + 1)
        LogManager.shared.setLevel(selectedLevel!)
    }

}
