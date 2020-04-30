//
//  ErrorViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 05/05/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

class ErrorViewController: NSViewController {
    
    var errorString: String?

    @IBOutlet var errorLabel: NSTextField!

    override func viewDidLoad() {
        errorLabel.stringValue = errorString ?? ""
    }
}
#warning("This should be in utils, in a dedicated file")
extension NSViewController {

    func showError(_ error: String, because reason: String = "NOT-SET") {
        AnalyticsManager.errorShownBecause(reason)
        let errorViewController = ErrorViewController(nibName: "ErrorView", bundle: nil)
        errorViewController.errorString = error
        presentAsSheet(errorViewController)
    }

}
