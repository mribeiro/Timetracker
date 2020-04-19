//
//  ViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 25/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Cocoa

class TaskRunnerViewController: NSViewController, TaskPingReceiver, DataChanged, NSComboBoxDataSource {

    // MARK: - Outlets

    @IBOutlet var hodPopup: NSPopUpButton!
    @IBOutlet var clientPopup: NSPopUpButton!
    @IBOutlet var projectPopup: NSPopUpButton!
    @IBOutlet var timeLabel: NSTextField!
    @IBOutlet var taskHodLabel: NSTextField!
    @IBOutlet var taskClientLabel: NSTextField!
    @IBOutlet var taskProjectLabel: NSTextField!
    @IBOutlet var taskTaskLabel: NSTextField!
    @IBOutlet weak var taskComboBox: NSComboBox!

    // MARK: - Vars and Lets

    fileprivate var selectedHod: HeadOfDevelopment? {
        return hodPopup.indexOfSelectedItem >= 0 ? hods?[hodPopup.indexOfSelectedItem] : nil
    }

    fileprivate var selectedClient: Client? {
        return selectedHod?.getClientByName(clientPopup.titleOfSelectedItem)
    }

    fileprivate var selectedProject: Project? {
        return selectedClient?.getProjectByName(projectPopup.titleOfSelectedItem)
    }

    fileprivate var selectedProjectsTaskNames: [String]?

    fileprivate var hods: [HeadOfDevelopment]?

    // MARK: - ViewController callbacks

    func didChange() {
        reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TaskProviderManager.instance.addPingReceiver(self)
        TaskProviderManager.instance.addChangesListener(self)

        self.taskComboBox.usesDataSource = true
        self.taskComboBox.completes = true
        self.taskComboBox.dataSource = self

        reloadData()

        setCurrentTaskLabels()
    }

    fileprivate func reloadData() {
        hods = TaskProviderManager.instance.getHeadOfDevelopments()
        let hodNames = hods!.compactMap { $0.name! }
        hodPopup.removeAllItems()
        hodPopup.addItems(withTitles: hodNames)
        populateClients()
        populateTasks()
    }

    override func viewWillDisappear() {
        TaskProviderManager.instance.removePingReceiver(self)
        TaskProviderManager.instance.removeChangesListener(self)
    }

    // MARK: - Actions

    @IBAction func selectedHodChanged(_ sender: NSPopUpButton) {
        L.d("selected hod \(sender.indexOfSelectedItem)")
        populateClients()
    }
    @IBAction func selectedClientChanged(_ sender: NSPopUpButton) {
        L.d("selected client \(sender.indexOfSelectedItem)")
        populateProjects()
    }
    @IBAction func selectedProjectChanged(_ sender: NSPopUpButtonCell) {
        L.d("selected project \(sender.indexOfSelectedItem)")
        populateTasks()
    }

    @IBAction func startClicked(_ sender: AnyObject) {

        guard let selectedProject = selectedProject, taskComboBox.stringValue.count > 0 else {
            L.e("Cannot start task. Were all fields set?")
            showError("Did you set all fields?")
            return
        }

        if TaskProviderManager.instance.isTaskRunning {
            _ = TaskProviderManager.instance.stopRunningTask()
        }

        TaskProviderManager.instance.startTask(taskComboBox.stringValue, inProject: selectedProject)
        setCurrentTaskLabels()
    }

    @IBAction func stopClicked(_ sender: NSButton) {

        let stopped = TaskProviderManager.instance.stopRunningTask()
        setCurrentTaskLabels()
        L.i("Task stopped successfully? \(stopped)")

    }

    // MARK: - TaskPing Receiver implementation

    func ping(_ interval: TimeInterval) {
        let string = interval.toProperString()
        timeLabel.stringValue = string
    }

    func taskStarted() {
        setCurrentTaskLabels()
    }

    func taskStopped() {
        _ = Timer.inOneSecond({ (_) in
            self.setCurrentTaskLabels()
        })
    }

    // MARK: - Private methods

    fileprivate func setCurrentTaskLabels() {

        if let runningTask = TaskProviderManager.instance.runningTask,
            let runningProject = TaskProviderManager.instance.projectOfRunningTask {

            timeLabel.stringValue = "Started"
            taskHodLabel.stringValue = runningProject.client!.headOfDevelopment!.name!
            taskClientLabel.stringValue = runningProject.client!.name!
            taskProjectLabel.stringValue = runningProject.name!
            taskTaskLabel.stringValue = runningTask.title!

        } else {
            timeLabel.stringValue = "Stopped"
            taskHodLabel.stringValue = ""
            taskClientLabel.stringValue = ""
            taskProjectLabel.stringValue = ""
            taskTaskLabel.stringValue = ""
        }
    }

    fileprivate func populateClients() {
        clientPopup.removeAllItems()
        if let selectedHod = selectedHod {
            let clientNames = selectedHod.children.compactMap { $0.name }
            clientPopup.addItems(withTitles: clientNames)
        }

        populateProjects()
    }

    fileprivate func populateProjects() {
        projectPopup.removeAllItems()
        if let selectedClient = selectedClient {
            var projectNames = selectedClient.children.compactMap { $0.name }

            projectNames.sort {
                return $0.compare($1) == .orderedAscending
            }

            projectPopup.addItems(withTitles: projectNames)
        }
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
