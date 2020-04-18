//
//  PreferenceAboutViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 12/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import AppKit
import Preferences

class PreferenceAboutViewController: NSViewController, PreferencePane {
    var preferencePaneIdentifier: Identifier = PreferencePaneIdentifier.Identifier.about

    var preferencePaneTitle: String = "About"

    @IBOutlet weak var labelVersion: NSTextField!
    @IBOutlet weak var labelCopyright: NSTextField!

    var toolbarItemIcon: NSImage = NSImage(named: "icon-about")!

    override var nibName: NSNib.Name? { "PreferenceAboutView" }

    override func viewDidLoad() {
        preferredContentSize = NSSize(width: 600, height: 200)
        let shortVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as? String ?? "CFBundleShortVersionString missing"
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as? String ?? "CFBundleVersion missing"
        let copyright = Bundle.main.infoDictionary!["NSHumanReadableCopyright"] as? String ?? "NSHumanReadableCopyright missing"
        let buildType = Bundle.main.infoDictionary!["BUILD_TYPE"] as? String ?? "BUILD_TYPE missing"

        labelVersion.stringValue = "Version \(shortVersion) (\(build)) \(buildType)"

        labelCopyright.stringValue = copyright
    }

    @IBAction func acknowledgementsClicked(_ sender: Any) {

        let textDisplayer = TextDisplayerViewController()

        if let path = Bundle.main.path(forResource: "copyright", ofType: "txt") {
            do {
                textDisplayer.text = try String(contentsOfFile: path)
            } catch {
                L.e("Error reading text from \(path)")
            }
        }

        presentAsSheet(textDisplayer)

    }

}
