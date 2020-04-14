//
//  TaskListViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 30/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

class TaskListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ManualTaskViewDelegate, TaskPingReceiver {
    
    // MARK: - Outlets
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var startDate: NSDatePicker!
    @IBOutlet var endDate: NSDatePicker!
    @IBOutlet var accumulatedTime: NSTextField!
    
    // MARK: - Vars and Lets
    fileprivate var tasks: [Task]?
    
    // MARK: - ViewController callbacks
    override func viewWillAppear() {
        super.viewWillAppear()
        //tasks = TaskProviderManager.instance.allTasks
        startDate.dateValue = Date()
        endDate.dateValue = startDate.dateValue
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.doubleAction = #selector(tableViewDoubleClick)
        
        filterClicked(nil)
        
        TaskProviderManager.instance.addPingReceiver(self)
        
    }
    
    func calculateTime() {
        //TODO time accumulated
        let timeAccumulated = tasks?.reduce(0) { (accumulated, value) in
            return (accumulated! + value.endTime!.timeIntervalSince(value.startTime! as Date))
        }
        
        if let time = timeAccumulated {
            
            let components = self.secondsToHoursMinutesSeconds(seconds: Int(time))
            
            accumulatedTime.stringValue = "Accumulated time: \(String(format:"%02d", components.hours))h\(String(format:"%02d",components.minutes))m"
        }
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    override func viewWillDisappear() {
        TaskProviderManager.instance.removePingReceiver(self)
    }
    
    func taskStarted() {
        
    }
    
    func ping(_ interval: TimeInterval) {
        
    }
    
    func taskStopped() {
        filterClicked(self)
    }
    
    // MARK: - TableViewDataSource callbacks
    
    var editingTask: Task?
    @objc func tableViewDoubleClick() {
        guard tableView.clickedRow > -1 else {
            L.d("header was double clicked, ignore")
            return
        }
        L.d("double clicked on row \(tableView.clickedRow)")
        editingTask = tasks?[tableView.clickedRow]
        performSegue(withIdentifier: "add_line", sender: self)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return tasks?.count ?? 0
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return tasks?[row]
    }
    
    // MARK: - ExportViewControllerDelegate
    func manualTaskViewDidDismiss() {
        filterClicked(nil)
    }
    
    // MARK: - TableViewDelegate callbacks
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        
        /*
        guard let task = tasks?[row] else {
            return nil
        }
        */
        
        var text: String?
        let identifier: String = "hod_cell"
        
        if tableColumn == tableView.tableColumns[0] { // HoD column
            text = tasks?[row].project?.client?.headOfDevelopment?.name
            
        } else if tableColumn == tableView.tableColumns[1] { // Client column
            text = tasks?[row].project?.client?.name
            
        } else if tableColumn == tableView.tableColumns[2] { // Project column
            text = tasks?[row].project?.name
            
        } else if tableColumn == tableView.tableColumns[3] { // Task name column
            text = tasks?[row].title
            
        } else if tableColumn == tableView.tableColumns[4] { // Task start column
            if let startTime = tasks?[row].startTime {
                text = formatter.string(from: startTime as Date)
            }
            
            
        } else if tableColumn == tableView.tableColumns[5] { // Start end column
            if let endTime = tasks?[row].endTime {
                text = formatter.string(from: endTime as Date)
            }
        }
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(identifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text ?? ""
            return cell
        }
        
        return nil
        
    }
    
    
    
    // MARK: - SegmentedControl action
    
    @IBAction func segmentedClicked(_ sender: NSSegmentedControl) {
        
        L.d("Clicked \(sender.selectedSegment)")
        
        switch sender.selectedSegment {
        case 0: // delete task
            
            var tasksToDelete = [Task]()
            
            self.tableView.selectedRowIndexes.sorted(by: >).forEach { tasksToDelete.append(self.tasks!.remove(at: $0)) }
            
            if TaskProviderManager.instance.deleteTasks(tasksToDelete) {
                self.tableView.removeRows(at: self.tableView.selectedRowIndexes, withAnimation: .slideUp)
                
            } else {
                tasks = TaskProviderManager.instance.allTasks
                self.tableView.reloadData()
            }
            
            calculateTime()
            
            break;
        case 1: // new task
            let countProjects = TaskProviderManager.instance.countProjects()
            if countProjects > 0 {
                self.editingTask = nil
                performSegue(withIdentifier: "add_line", sender: self)
                
            } else {
                showError("You need to have at least one project")
            }
            
            break;
        default:
            L.d("Segment not recognized")
        }
        
        
    }
    
    var exported: String?
    
    @IBAction func exportClicked(_ sender: AnyObject) {
        
        if let tasks = self.tasks {
            let export = TabSeparatedValuesExporter()
            exported = export.export(tasks)
            
            performSegue(withIdentifier: "show_export", sender: self)
            
        }
        
    }
    
    @IBAction func filterClicked(_ sender: AnyObject?) {
        
        guard let end = endDate.dateValue.endOfDay else {
            L.e("Couldn't get end date")
            return
        }
        
        self.tasks = TaskProviderManager.instance.getTasksBetween(startDate.dateValue.startOfDay, and: end)
        self.tableView.reloadData()
        self.calculateTime()
    }
    
    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destinationController as? ExportViewController {
            destination.string = self.exported
            return
        }
        
        if let destination = segue.destinationController as? ManualTaskViewController {
            destination.delegate = self
            destination.editingTask = self.editingTask
            return
        }
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
