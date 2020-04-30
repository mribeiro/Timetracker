//
//  File.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 30/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import AppKit

class TrackedViewController: NSViewController {
    
     private(set) var analyticsScreenName: String? = nil
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        print("sending analytics...")
        
        let screenName = analyticsScreenName ?? self.className
        AnalyticsManager.windowOpened(screenName)
        print("done")
    }
    
}
