//
//  AppDelegate+NSMenuDelegate.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 11/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Cocoa
import IOKit
import AppKit
import Preferences

extension AppDelegate: NSMenuDelegate {

    func menuWillOpen(_ menu: NSMenu) {

        menu.removeAllItems()

        loadBasicMenuItems(menu)
        loadLastTask(menu)
        loadTree(menu)
        loadCurrentTask(menu)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Exit", action: #selector(NSApp.terminate), keyEquivalent: "")

    }

    func loadTree(_ sender: NSMenu) {
        taskProvider.getHeadOfDevelopments().forEach { hod in

            let hodItem = menu.addItem(withTitle: hod.name!, action: nil, keyEquivalent: "")

            let clients = hod.children

            if clients.count > 0 {

                let clientsMenu = NSMenu()
                hodItem.submenu = clientsMenu
                clients.forEach { client in
                    let clientItem = clientsMenu.addItem(withTitle: client.name!, action: nil, keyEquivalent: "")

                    let projects = client.children

                    if projects.count > 0 {

                        let projectsMenu = NSMenu()
                        clientItem.submenu = projectsMenu

                        projects.forEach { project in
                            let projectItem = projectsMenu.addItem(withTitle: project.name!,
                                                                   action: nil,
                                                                   keyEquivalent: "")

                            let tasks = project.tasks
                            if tasks?.count ?? 0 > 0 {

                                let tasksMenu = NSMenu()
                                projectItem.submenu = tasksMenu

                                var distinctNames = [String]()

                                let distinctTasks = tasks!.filter { task in
                                    if !distinctNames.contains(task.title!) {
                                        distinctNames.append(task.title!)
                                        return true
                                    }
                                    return false
                                    }.sorted { (task1, task2) in
                                        return task1.title!.compare(task2.title!) == .orderedAscending
                                }

                                distinctTasks.forEach { task in
                                    let taskItem = tasksMenu.addItem(withTitle: task.title!,
                                                                     action: #selector(taskClicked),
                                                                     keyEquivalent: "")
                                    taskItem.isEnabled = true

                                    taskItem.representedObject = task
                                }
                            }
                        }
                    }
                }
            }
        }

    }

    @objc func taskClicked(_ sender: NSMenuItem) {
        if let task = sender.representedObject as? Task {

            L.i("Starting task \(task.title!) in project \(task.project!) from menu bar")

            if taskProvider.isTaskRunning {
                _ = taskProvider.stopRunningTask()
            }

            taskProvider.startTask(task.title!, inProject: task.project!)
        }
    }

    @objc func stopTaskClicked(_ sender: NSMenuItem) {
        _ = taskProvider.stopRunningTask()
    }

    @objc func openTaskRunner(_ sender: NSMenuItem) {
        executeSegue(ofMenuItem: self.taskRunnerMenuItem)
    }

    @objc func openTaskList(_ sender: NSMenuItem) {
        executeSegue(ofMenuItem: self.taskListMenuItem)
    }

    @objc func openCostCentre(_ sender: NSMenuItem) {
        executeSegue(ofMenuItem: self.costCentresMenuItem)
    }

    func loadBasicMenuItems(_ menu: NSMenu) {
        let openMenuItems = NSMenu()

        // Task runner
        let openTaskRunnerItem = NSMenuItem(title: "Task runner",
                                            action: #selector(openTaskRunner(_:)),
                                            keyEquivalent: "")
        openMenuItems.addItem(openTaskRunnerItem)

        // Task list
        let openTaskListItem = NSMenuItem(title: "Task list", action: #selector(openTaskList(_:)), keyEquivalent: "")
        openMenuItems.addItem(openTaskListItem)

        // Cost centre
        let openCostCentreItem = NSMenuItem(title: "Cost centres",
                                            action: #selector(openCostCentre(_:)),
                                            keyEquivalent: "")
        openMenuItems.addItem(openCostCentreItem)

        // Open preferences
        let openPreferencesItem = NSMenuItem(title: "Preferences",
                                             action: #selector(openPreferences(_:)),
                                             keyEquivalent: "")
        openMenuItems.addItem(openPreferencesItem)

        let openMenu = menu.addItem(withTitle: "Open", action: nil, keyEquivalent: "")
        openMenu.submenu = openMenuItems

        if taskProvider.isTaskRunning {

            let timePassed = NSMenuItem(title: currentTaskTime ?? "", action: nil, keyEquivalent: "")
            timePassed.isEnabled = false
            timePassed.tag = 1

            menu.addItem(timePassed)

            let stop = NSMenuItem(title: "Stop", action: #selector(stopTaskClicked), keyEquivalent: "")
            stop.isEnabled = true
            menu.addItem(stop)
        }

        menu.addItem(NSMenuItem.separator())

    }

    func loadCurrentTask(_ menu: NSMenu) {
        if let task = taskProvider.runningTask, let project = taskProvider.projectOfRunningTask {

            menu.addItem(NSMenuItem.separator())

            let client = project.client!
            let hod = client.headOfDevelopment!

            let hodItem = NSMenuItem(title: hod.name!, action: nil, keyEquivalent: "")
            hodItem.isEnabled = false
            let projectItem = NSMenuItem(title: project.name!, action: nil, keyEquivalent: "")
            projectItem.isEnabled = false
            let clientItem = NSMenuItem(title: client.name!, action: nil, keyEquivalent: "")
            clientItem.isEnabled = false
            let taskItem = NSMenuItem(title: task.title!, action: nil, keyEquivalent: "")
            taskItem.isEnabled = false

            menu.addItem(hodItem)
            menu.addItem(projectItem)
            menu.addItem(clientItem)
            menu.addItem(taskItem)

        }
    }

    func loadLastTask(_ menu: NSMenu) {

        let taskProviderInstance = TaskProviderManager.instance!

        // guarantee there's a last task
        guard !(taskProviderInstance.isTaskRunning), taskProviderInstance.lastTask != nil else {
            return
        }

        let restart = NSMenuItem(title: "Restart last task",
                                 action: #selector(restartLastTaskClicked),
                                 keyEquivalent: "")
        restart.isEnabled = true
        menu.addItem(restart)

    }

    @objc func restartLastTaskClicked(_ sender: NSMenuItem) {

        let taskProviderInstance = TaskProviderManager.instance!

        // guarantee there's a last task and everything is OK
        guard !(taskProviderInstance.isTaskRunning),
            let lastTask = taskProviderInstance.lastTask,
            let lastTaskTitle = lastTask.title,
            let lastTaskProject = lastTask.project else {

            return
        }

        taskProviderInstance.startTask(lastTaskTitle, inProject: lastTaskProject)
    }
}
