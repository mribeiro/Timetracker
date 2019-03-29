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


class PreferenceBuilderViewController: NSViewController, Preferenceable {
    
    var toolbarItemIcon: NSImage = NSImage(named: "settings")!
    
    var toolbarItemTitle: String = "Builder"
    
    @IBOutlet weak var monkeyRadio: NSButton!
    @IBOutlet weak var moonRadio: NSButton!
    
    
    
    override var nibName: NSNib.Name? {
        return "PreferenceBuilderView"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let builderName =
            BuilderManager.getFromConfiguration().name
        
        switch builderName {
        case "moon":
            self.moonRadio.state = .on
        default:
            self.monkeyRadio.state = .on
        }
        
        
        // Setup stuff here
    }
    
    @IBAction func setBuilder(_ sender: NSButton) {
        
        let id = sender.identifier?.rawValue ?? ""
        let builder = BuilderManager.saveBuilder(id)
        
        print(builder.start)
    
    }
    
}
