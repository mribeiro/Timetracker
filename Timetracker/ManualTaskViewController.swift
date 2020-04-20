//
//  ManualTaskViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 03/05/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

class ManualTaskViewController: NSViewController, NSComboBoxDataSource {

    @IBOutlet var hodsPopup: NSPopUpButton!
    @IBOutlet var projectsPopup: NSPopUpButton!
    @IBOutlet var clientsPopup: NSPopUpButton!
    @IBOutlet var taskEnd: NSDatePicker!
    @IBOutlet var taskStart: NSDatePicker!
    @IBOutlet weak var taskComboBox: NSComboBox!

    var selectedProjectsTaskNames: [String]?

    weak var editingTask: Task?

    var onDismiss: (() -> Void)?

    fileprivate var selectedHod: HeadOfDevelopment? {
        return hods?[safe: hodsPopup.indexOfSelectedItem]
    }

    fileprivate var selectedClient: Client? {
        return selectedHod?.getClientByName(clientsPopup.titleOfSelectedItem)
    }

    fileprivate var selectedProject: Project? {
        return selectedClient?.getProjectByName(projectsPopup.titleOfSelectedItem)
    }

    fileprivate var hods: [HeadOfDevelopment]?

    override func viewWillAppear() {
        super.viewWillAppear()
        hods = TaskProviderManager.instance.getHeadOfDevelopments()
        let hodNames = hods!.compactMap { $0.name }
        hodsPopup.removeAllItems()
        hodsPopup.addItems(withTitles: hodNames)

        if let task = editingTask {

            taskStart.dateValue = task.startTime! as Date
            taskEnd.dateValue = task.endTime! as Date
            taskComboBox.stringValue = task.title!

            let taskProject = task.project!
            let taskClient = taskProject.client!
            let taskHod = taskClient.headOfDevelopment!

            hodsPopup.selectItem(withTitle: taskHod.name!)
            populateClients(taskClient.name!, withDefaultProject: taskProject.name!)

        } else {
            populateClients(nil, withDefaultProject: nil)
            taskStart.dateValue = Date()
            taskEnd.dateValue = taskStart.dateValue
        }

        taskEnd.minDate = taskStart.dateValue
        taskStart.maxDate = Date()
        taskEnd.maxDate = Date()

        self.taskComboBox.usesDataSource = true
        self.taskComboBox.completes = true
        self.taskComboBox.dataSource = self

        populateTasks()

    }

    fileprivate func populateClients(_ defaultSelected: String?, withDefaultProject defaultProject: String?) {
        clientsPopup.removeAllItems()
        if let selectedHod = selectedHod {
            let clientNames = selectedHod.children.compactMap { $0.name }
            clientsPopup.addItems(withTitles: clientNames)
        }

        if let selected = defaultSelected {
            clientsPopup.selectItem(withTitle: selected)
        }

        populateProjects(defaultProject)
    }

    fileprivate func populateProjects(_ defaultSelected: String?) {
        projectsPopup.removeAllItems()
        if let selectedClient = selectedClient {
            var projectNames = selectedClient.children.compactMap { $0.name }

            projectNames.sort {
                return $0.compare($1) == .orderedAscending
            }

            projectsPopup.addItems(withTitles: projectNames)
        }

        if let selected = defaultSelected {
            projectsPopup.selectItem(withTitle: selected)
        }
    }

    override func viewWillDisappear() {
        self.editingTask = nil
        self.onDismiss?()
    }

    @IBAction func hodChanged(_ sender: AnyObject?) {
        populateClients(nil, withDefaultProject: nil)
    }

    @IBAction func clientChanged(_ sender: AnyObject) {
        populateProjects(nil)
    }

    @IBAction func projectChanged(_ sender: Any) {
        populateTasks()
    }

    @IBAction func cancelClicked(_ sender: NSButton) {
        self.dismiss(self)
    }

    @IBAction func saveClicked(_ sender: NSButton) {
        if let selectedProject = self.selectedProject, taskComboBox.stringValue.count > 0 {

            if let task = editingTask {

                task.title = taskComboBox.stringValue
                task.startTime = taskStart.dateValue
                task.endTime = taskEnd.dateValue
                task.project = selectedProject

                if TaskProviderManager.instance.updateTask(task) {
                    dismiss(self)

                } else {
                    showError("Couldn't update task")
                    L.e("Couldn't update task in database")
                }

            } else {

                if TaskProviderManager.instance.saveTaskInProject(selectedProject,
                                                                  withTitle: taskComboBox.stringValue,
                                                                  startingAt: taskStart.dateValue,
                                                                  finishingAt: taskEnd.dateValue) {
                    dismiss(self)
                } else {
                    showError("Couldn't save task")
                    L.e("Couldn't save task in database")
                }
            }

        } else {
            showError("Have you filled all fields?")
        }
    }

    @IBAction func startDateChanged(_ sender: NSDatePicker) {
        self.taskEnd.minDate = sender.dateValue
    }

    @IBAction func endDateChanged(_ sender: NSDatePicker) {
        self.taskStart.maxDate = sender.dateValue
    }

    fileprivate func populateTasks() {

        self.selectedProjectsTaskNames = selectedProject?.distinctTasksNames

        taskComboBox.reloadData()

        if taskComboBox.numberOfItems > 0 {
            taskComboBox.selectItem(at: 0)
        }

    }

    func numberOfItems(in comboBox: NSComboBox) -> Int {
        return self.selectedProjectsTaskNames?.count ?? 0
    }

    func comboBox(_ comboBox: NSComboBox, objectValueForItemAt index: Int) -> Any? {
        return self.selectedProjectsTaskNames![index]
    }

    func comboBox(_ comboBox: NSComboBox, completedString string: String) -> String? {
        return self.selectedProjectsTaskNames?.filter({ (taskTitle) -> Bool in
            return taskTitle.starts(with: string)
        }).first
    }

    func comboBox(_ comboBox: NSComboBox, indexOfItemWithStringValue string: String) -> Int {
        return self.selectedProjectsTaskNames?.firstIndex(of: string) ?? NSNotFound
    }
}
