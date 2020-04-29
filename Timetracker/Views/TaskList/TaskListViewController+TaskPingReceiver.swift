//
//  TaskListViewController+TaskPingReceiver.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 29/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation

extension TaskListViewController: TaskPingReceiver {

    func taskStarted() {
        filterTasks()
    }

    func ping(_ interval: TimeInterval) {
        L.v("Ping in TaskListViewController")
        let lastRow = tasks?.count
        calculateTime()
        tableView.reloadData(forRowIndexes: [lastRow!], columnIndexes: [TableColumns.accumulated.rawValue])
    }

    func taskStopped() {
        filterTasks()
    }

}
