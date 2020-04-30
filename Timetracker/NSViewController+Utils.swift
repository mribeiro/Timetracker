//
//  NSViewController+Utils.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 30/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import AppKit

extension NSViewController {
    
    func showError(_ error: String, because reason: String = "NOT-SET") {
        AnalyticsManager.errorShownBecause(reason)
        let errorViewController = ErrorViewController(nibName: "ErrorView", bundle: nil)
        errorViewController.errorString = error
        presentAsSheet(errorViewController)
    }
    
}
