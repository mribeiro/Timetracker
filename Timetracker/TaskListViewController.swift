//
//  TaskListViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 30/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

class TaskListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, ManualTaskViewDelegate, TaskPingReceiver, CurrentTaskEditorViewDelegate {
    
    enum TableColumns: Int {
        case HeadOfDevelopment = 0
        case Client = 1
        case Project = 2
        case Task = 3
        case StartTime = 4
        case EndTime = 5
        case Accumulated = 6
    }
    
    
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
        
        var timeAccumulated = tasks?.reduce(0) { (accumulated, value) in
            return (accumulated! + value.endTime!.timeIntervalSince(value.startTime! as Date))
        } ?? 0
        
        if let runningTastStartTime = TaskProviderManager.instance.runningTask?.startTime {
            timeAccumulated += Date().timeIntervalSince(runningTastStartTime)
        }
        
        let components = self.secondsToHoursMinutesSeconds(seconds: Int(timeAccumulated))
        
        accumulatedTime.stringValue = "Accumulated time: \(String(format:"%02d", components.hours))h\(String(format:"%02d",components.minutes))m"
    
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    override func viewWillDisappear() {
        TaskProviderManager.instance.removePingReceiver(self)
    }
    
    func taskStarted() {
        filterClicked(self)
    }
    
    func ping(_ interval: TimeInterval) {
        L.v("Ping in TaskListViewController")
        let lastRow = tasks?.count
        calculateTime()
        tableView.reloadData(forRowIndexes: [lastRow!], columnIndexes: [TableColumns.Accumulated.rawValue])
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
        
        if tableView.clickedRow == tasks?.count ?? 0 {
            performSegue(withIdentifier: "edit_current_task", sender: self)
            
        } else {
            editingTask = tasks?[safe: tableView.clickedRow]
            performSegue(withIdentifier: "add_line", sender: self)
            
        }
        
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        let savedTasks = tasks?.count ?? 0
        
        if TaskProviderManager.instance.isTaskRunning {
            return savedTasks + 1
        }
        return savedTasks
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        return tasks?[safe: row] ?? TaskProviderManager.instance.runningTask
    }
    
    // MARK: - ExportViewControllerDelegate
    func manualTaskViewDidDismiss() {
        filterClicked(nil)
    }
    
    // MARK: - CurrentTaskEditorViewDelegate
    func currentTaskEditorViewDidDismiss() {
        calculateTime()
        self.tableView.reloadData(forRowIndexes: [self.tasks?.count ?? 1], columnIndexes: [TableColumns.StartTime.rawValue])
    }
    
    // MARK: - TableViewDelegate callbacks
    
    
    func buildContent(forTask task: Task, inProject project: Project, tableColumn: NSTableColumn, inTable tableView: NSTableView) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        var text: String?
        
        if tableColumn == tableView.tableColumns[TableColumns.HeadOfDevelopment.rawValue] { // HoD column
            text = project.client?.headOfDevelopment?.name
            
        } else if tableColumn == tableView.tableColumns[TableColumns.Client.rawValue] { // Client column
            text = project.client?.name
            
        } else if tableColumn == tableView.tableColumns[TableColumns.Project.rawValue] { // Project column
            text = project.name
            
        } else if tableColumn == tableView.tableColumns[TableColumns.Task.rawValue] { // Task name column
            text = task.title
            
        } else if tableColumn == tableView.tableColumns[TableColumns.StartTime.rawValue] { // Task start column
            if let startTime = task.startTime {
                text = formatter.string(from: startTime as Date)
            }
            
        } else if tableColumn == tableView.tableColumns[TableColumns.EndTime.rawValue] { // Task end column
            if let endTime = task.endTime {
                text = formatter.string(from: endTime as Date)
            }
            
        } else if tableColumn == tableView.tableColumns[TableColumns.Accumulated.rawValue] { // Accumulated column
            if let endTime = task.endTime {
                let seconds = endTime.timeIntervalSince(task.startTime!)
                text = seconds.toProperString()
                
            } else {
                let seconds = Date().timeIntervalSince(task.startTime!)
                text = seconds.toProperString()
            }
        }
        
        return text ?? ""
        
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        var task = tasks?[safe: row]
        var project = task?.project
        
        if task == nil {
            task = TaskProviderManager.instance.runningTask
            project = TaskProviderManager.instance.projectOfRunningTask
        }
        
        let text = buildContent(forTask: task!, inProject: project!, tableColumn: tableColumn!, inTable: tableView)
        
        let identifier: String = "hod_cell"
        
        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(identifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        
        return nil
    }
    
    
    // MARK: - SegmentedControl action
    
    @IBAction func segmentedClicked(_ sender: NSSegmentedControl) {
        
        L.d("Clicked \(sender.selectedSegment)")
        
        switch sender.selectedSegment {
        case 0: // delete task
            
            guard let tasksCount = tasks?.count, tasksCount > 0 else {
                return
            }
            
            var tasksToDelete = [Task]()
            
            self.tableView.selectedRowIndexes.sorted(by: >).forEach {
                // Task may not exist if it is the line of the current task
                let taskExists = self.tasks?.indices.contains($0) ?? false
                if taskExists {
                    tasksToDelete.append(self.tasks!.remove(at: $0))
                } else {
                    // If the task does not exist deselect it so it is not removed from the list
                    self.tableView.deselectRow($0)
                }
                
            }
            
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
        
        if let destination = segue.destinationController as? CurrentTaskEditorViewController {
            destination.delegate = self
        }
                
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
	return NSUserInterfaceItemIdentifier(rawValue: input)
}
