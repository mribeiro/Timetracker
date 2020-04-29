//
//  TaskListWindowController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 28/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import AppKit

class TaskListWindowController: NSWindowController {

    @IBOutlet weak var startDatePicker: NSDatePicker!
    @IBOutlet weak var timespanSelector: NSSegmentedControl!

    var startDate: Date {
        return startDatePicker.dateValue
    }

    var timeSpan: TaskListViewController.TimeSpan? {
        return TaskListViewController.TimeSpan(rawValue: self.timespanSelector.selectedSegment)
    }

}
