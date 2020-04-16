//
//  CurrentTaskEditorViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 15/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

protocol CurrentTaskEditorViewDelegate {
    func currentTaskEditorViewDidDismiss()
}

class CurrentTaskEditorViewController: NSViewController, TaskPingReceiver {
    
    func ping(_ interval: TimeInterval) {
    }
    
    func taskStarted() {
    }
    
    func taskStopped() {
        self.dismiss(self)
    }
    
    
    @IBOutlet weak var newStartDatePicker: NSDatePicker!
    
    var delegate: CurrentTaskEditorViewDelegate?
    
    override func viewDidLoad() {
        TaskProviderManager.instance.addPingReceiver(self)
        self.newStartDatePicker.maxDate = Date()
        self.newStartDatePicker.dateValue = TaskProviderManager.instance.runningTask!.startTime!
    }
    
    @IBAction func save(_ sender: Any) {
        TaskProviderManager.instance.runningTask!.startTime = newStartDatePicker.dateValue
        dismiss(self)
    }
    
    override func viewWillDisappear() {
        delegate?.currentTaskEditorViewDidDismiss()
        TaskProviderManager.instance.removePingReceiver(self)
        
    }
    
    
}
