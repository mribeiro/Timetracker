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

    private(set) var analyticsScreenName: String?

    override func viewWillAppear() {
        super.viewWillAppear()
        let screenName = analyticsScreenName ?? self.className
        AnalyticsManager.windowOpened(screenName)
    }

}
