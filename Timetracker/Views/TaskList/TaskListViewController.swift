//
//  TaskListViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 30/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa
import SwiftDate

class TaskListViewController: TrackedViewController, NSTableViewDataSource {

    enum TableColumns: Int {
        case headOfDevelopment = 0
        case client = 1
        case project = 2
        case task = 3
        case startTime = 4
        case endTime = 5
        case accumulated = 6
    }

    enum TimeSpan: Int {
        case day = 0
        case week = 1
        case month = 2
    }

    // MARK: - Outlets
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var accumulatedTime: NSTextField!
    @IBOutlet weak var recordsLabel: NSTextField!

    // MARK: - Vars and Lets
    var tasks: [Task]?
    var contentCorrupted = false
    var exported: String?

    override var analyticsScreenName: String? { "task-list" }

    var windowController: TaskListWindowController? {
        return self.view.window?.windowController as? TaskListWindowController
    }

    // MARK: - ViewController callbacks
    override func viewWillAppear() {
        super.viewWillAppear()
        //tasks = TaskProviderManager.instance.allTasks
        windowController?.startDatePicker.dateValue = Date()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.doubleAction = #selector(tableViewDoubleClick)

        filterTasks()

        TaskProviderManager.instance.addPingReceiver(self)
    }

    func calculateTime() {

        var timeAccumulated = tasks?.reduce(0) { (accumulated, value) in
            return (accumulated! + value.endTime!.timeIntervalSince(value.startTime! as Date))
        } ?? 0

        if let runningTastStartTime = TaskProviderManager.instance.runningTask?.startTime {
            timeAccumulated += Date().timeIntervalSince(runningTastStartTime)
        }

        let components = TimeInterval(timeAccumulated).decomposeTimeInterval()

        accumulatedTime.stringValue = """
        Accumulated time: \(String(format: "%02d", components.hour!))h\(String(format: "%02d", components.minute!))m
        """
    }

    @IBAction func timeSpanSelectorClicked(_ sender: Any) {
        filterTasks()
    }

    @IBAction func startDateChanged(_ sender: Any) {
        filterTasks()
    }

    override func viewWillDisappear() {
        TaskProviderManager.instance.removePingReceiver(self)
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

        case 1: // new task
            let countProjects = TaskProviderManager.instance.countProjects()
            if countProjects > 0 {
                self.editingTask = nil
                performSegue(withIdentifier: "add_line", sender: self)

            } else {
                showError("You need to have at least one project", because: "manual-task-add-no-project")
            }

        default:
            L.d("Segment not recognized")
        }

    }

    @IBAction func exportClicked(_ sender: AnyObject) {
        guard !self.contentCorrupted else {
            showError("There are tasks that do not seem to be properly configured. Please check and fix them.",
                      because: "task-list-corrupted-content")
            return
        }

        if let tasks = self.tasks {
            let export = TabSeparatedValuesExporter()
            exported = export.export(tasks)

            performSegue(withIdentifier: "show_export", sender: self)

        }
    }

    func filterTasks() {

        guard let timespan = self.windowController?.timeSpan, let startDate = self.windowController?.startDate else {
            return
        }

        let startAndEndTime = calculateDateRangeWithStartDate(startDate, forTimeSpan: timespan)

        var text: String

        switch timespan {
        case .day:
            let dateFormatted = startAndEndTime.startDate.toFormat("dd/MM/yyyy")
            text = "Showing records on \(dateFormatted)"

        case .week:
            let startDateFormatted = startAndEndTime.startDate.toFormat("dd/MM/yyyy")
            let endDateFormatted = startAndEndTime.endDate.toFormat("dd/MM/yyyy")
            text = "Showing records between \(startDateFormatted) and \(endDateFormatted)"

        case .month:
            text = "Showing records in \(startAndEndTime.startDate.monthName(.default))"
        }

        self.recordsLabel.stringValue = text

        self.contentCorrupted = false
        self.tasks = TaskProviderManager.instance.getTasksBetween(startAndEndTime.startDate,
                                                                  and: startAndEndTime.endDate)
        self.tableView.reloadData()
        self.calculateTime()
    }

    override func prepare(for segue: NSStoryboardSegue, sender: Any?) {

        if let destination = segue.destinationController as? ExportViewController {
            destination.string = self.exported
            return
        }

        if let destination = segue.destinationController as? ManualTaskViewController {
            destination.onDismiss = {
                self.filterTasks()
            }
            destination.editingTask = self.editingTask
            return
        }

        if let destination = segue.destinationController as? CurrentTaskEditorViewController {
            destination.onDismiss = {
                self.calculateTime()
                self.tableView.reloadData(forRowIndexes: [self.tasks?.count ?? 1],
                                          columnIndexes: [TableColumns.startTime.rawValue])
            }
        }
    }

    private func calculateDateRangeWithStartDate(_ startDate: Date, forTimeSpan timeSpan: TimeSpan)
        -> (startDate: Date, endDate: Date) {

        var startOfFilter: Date
        var endOfFilter: Date

        switch timeSpan {
        case .day:
            startOfFilter = startDate.dateAt(.startOfDay)
            endOfFilter = startDate.dateAt(.endOfDay)

        case .week:
            startOfFilter = startDate.dateAt(.startOfWeek)
            endOfFilter = startDate.dateAt(.endOfWeek)

        case .month:
            startOfFilter = startDate.dateAt(.startOfMonth)
            endOfFilter = startDate.dateAt(.endOfMonth)
        }

        return (startOfFilter, endOfFilter)
    }
    //swiftlint:disable shorthand_operator
    @IBAction private func jumpToNext(_ sender: Any?) {

        guard var date = self.windowController?.startDate, let span = self.windowController?.timeSpan else {
            return
        }

        switch span {
        case .day:
            date = date + 1.days

        case .week:
            date = date + 1.weeks

        case .month:
            date = date + 1.months
        }

        self.windowController?.startDatePicker.dateValue = date
        filterTasks()

    }

    @IBAction private func jumpToPrevious(_ sender: Any?) {

        guard var date = self.windowController?.startDate, let span = self.windowController?.timeSpan else {
            return
        }

        switch span {
        case .day:
            date = date - 1.days

        case .week:
            date = date - 1.weeks

        case .month:
            date = date - 1.months
        }

        self.windowController?.startDatePicker.dateValue = date
        filterTasks()

    }
    //swiftlint:enable shorthand_operator

}
