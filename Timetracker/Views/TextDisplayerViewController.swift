//
//  TextDisplayerViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 16/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

class TextDisplayerViewController: TrackedViewController {

    @IBOutlet var textView: NSTextView!

    override var analyticsScreenName: String? { "text-displayer" }
    override var nibName: NSNib.Name? { "TextDisplayerView" }

    var text: String?

    override func viewDidLoad() {
        self.textView.isEditable = false
        self.textView.string = text ?? ""
    }

    @IBAction func closeClicked(_ sender: Any) {
        self.dismiss(self)
    }
}
