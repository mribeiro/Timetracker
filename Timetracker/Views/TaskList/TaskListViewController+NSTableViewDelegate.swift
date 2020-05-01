//
//  TaskListViewController+NSTableViewDelegate.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 01/05/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation
import AppKit

extension TaskListViewController: NSTableViewDelegate {

    // MARK: - TableViewDelegate callbacks

    func handlePossibleCorruptContent(_ text: String?) -> String {
        if let sureText = text {
            return sureText
        } else {
            self.contentCorrupted = true
            return "⚠️"
        }
    }

    func buildContent(forTask task: Task, inProject project: Project?,
                      tableColumn: NSTableColumn, inTable tableView: NSTableView) -> String {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"

        var text: String?

        if tableColumn == tableView.tableColumns[TableColumns.headOfDevelopment.rawValue] { // HoD column
            text = handlePossibleCorruptContent(project?.client?.headOfDevelopment?.name)

        } else if tableColumn == tableView.tableColumns[TableColumns.client.rawValue] { // Client column
            text = handlePossibleCorruptContent(project?.client?.name)

        } else if tableColumn == tableView.tableColumns[TableColumns.project.rawValue] { // Project column
            text = handlePossibleCorruptContent(project?.name)

        } else if tableColumn == tableView.tableColumns[TableColumns.task.rawValue] { // Task name column
            text = task.title

        } else if tableColumn == tableView.tableColumns[TableColumns.startTime.rawValue] { // Task start column
            if let startTime = task.startTime {
                text = formatter.string(from: startTime as Date)
            }

        } else if tableColumn == tableView.tableColumns[TableColumns.endTime.rawValue] { // Task end column
            if let endTime = task.endTime {
                text = formatter.string(from: endTime as Date)
            }

        } else if tableColumn == tableView.tableColumns[TableColumns.accumulated.rawValue] { // Accumulated column
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

        if task == nil && TaskProviderManager.instance.isTaskRunning {
            task = TaskProviderManager.instance.runningTask
            project = TaskProviderManager.instance.projectOfRunningTask
        }

        let text = buildContent(forTask: task!, inProject: project, tableColumn: tableColumn!, inTable: tableView)

        let identifier: String = "hod_cell"

        if let cell = tableView.makeView(withIdentifier: convertToNSUserInterfaceItemIdentifier(identifier),
                                         owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }

        return nil
    }

}

// Helper function inserted by Swift 4.2 migrator.
private func convertToNSUserInterfaceItemIdentifier(_ input: String) -> NSUserInterfaceItemIdentifier {
    return NSUserInterfaceItemIdentifier(rawValue: input)
}
