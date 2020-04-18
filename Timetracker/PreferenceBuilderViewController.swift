//
//  PreferenceBuilderViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 16/03/2019.
//  Copyright © 2019 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa
import Preferences

extension PreferencePane.Identifier {
    static let builder = Identifier("builder")
    static let logs = Identifier("logs")
    static let misc = Identifier("misc")
    static let about = Identifier("about")
}

class PreferenceBuilderViewController: NSViewController, PreferencePane {

    var preferencePaneIdentifier: Identifier = PreferencePane.Identifier.builder

    var preferencePaneTitle: String = "Builder"

    var toolbarItemIcon: NSImage = NSImage(named: "icon-worker")!

    var toolbarItemTitle: String = "Builder"

    @IBOutlet weak var monkeyRadio: NSButton!
    @IBOutlet weak var moonRadio: NSButton!
    @IBOutlet weak var clockRadio: NSButton!
    @IBOutlet weak var trafficLightsRadio: NSButton!
    @IBOutlet weak var timeCounterRadio: NSButton!

    override var nibName: NSNib.Name? {
        "PreferenceBuilderView"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let builderName =
            BuilderManager.getFromConfiguration().name

        switch builderName {
        case "moon":
            self.moonRadio.state = .on
        case "clock":
            self.clockRadio.state = .on
        case "traffic_lights":
            self.trafficLightsRadio.state = .on
        case "time_counter":
            self.timeCounterRadio.state = .on
        default:
            self.monkeyRadio.state = .on
        }

        preferredContentSize = NSSize(width: 600, height: 200)

    }

    @IBAction func setBuilder(_ sender: NSButton) {

        let id = sender.identifier?.rawValue ?? ""
        L.i("Saving new builder as \(id)")
        _ = BuilderManager.saveBuilder(id)
    }

}
