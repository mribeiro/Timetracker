//
//  ViewController.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 25/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, TaskPingReceiver, DataChanged {
    
    // MARK: - Outlets
    
    @IBOutlet var hodPopup: NSPopUpButton!
    @IBOutlet var clientPopup: NSPopUpButton!
    @IBOutlet var projectPopup: NSPopUpButton!
    @IBOutlet var timeLabel: NSTextField!
    @IBOutlet var taskLabel: NSTextField!
    @IBOutlet var taskHodLabel: NSTextField!
    @IBOutlet var taskClientLabel: NSTextField!
    @IBOutlet var taskProjectLabel: NSTextField!
    @IBOutlet var taskTaskLabel: NSTextField!
    
    // MARK: - Vars and Lets
    
    fileprivate var selectedHod: HeadOfDevelopment? {
        return hods?[hodPopup.indexOfSelectedItem]
    }
    
    fileprivate var selectedClient: Client? {
        return selectedHod?.getClientByName(clientPopup.titleOfSelectedItem)
    }
    
    fileprivate var selectedProject: Project? {
        return selectedClient?.getProjectByName(projectPopup.titleOfSelectedItem)
    }
    
    fileprivate var hods: [HeadOfDevelopment]?
    
    // MARK: - ViewController callbacks
    
    func didChange() {
        reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        TaskProviderManager.instance.addPingReceiver(self)
        TaskProviderManager.instance.addChangesListener(self)
        
        reloadData()
        
        setCurrentTaskLabels()
    }
    
    fileprivate func reloadData() {
        hods = TaskProviderManager.instance.getHeadOfDevelopments()
        let hodNames = hods!.flatMap{ $0.name! }
        hodPopup.removeAllItems()
        hodPopup.addItems(withTitles: hodNames)
        populateClients()
    }
    
    override func viewWillDisappear() {
        TaskProviderManager.instance.removePingReceiver(self)
        TaskProviderManager.instance.removeChangesListener(self)
    }

    // MARK: - Actions
    
    @IBAction func selectedHodChanged(_ sender: NSPopUpButton) {
        print("selected hod \(sender.indexOfSelectedItem)")
        populateClients()
    }
    @IBAction func selectedClientChanged(_ sender: NSPopUpButton) {
        print("selected client \(sender.indexOfSelectedItem)")
        populateProjects()
    }
    
    @IBAction func startClicked(_ sender: AnyObject) {
        
        guard let selectedProject = selectedProject , taskLabel.stringValue.characters.count > 0 else {
            print("cannot start task")
            showError("Did you set all fields?")
            return
        }
        
        if TaskProviderManager.instance.isTaskRunning {
            _ = TaskProviderManager.instance.stopRunningTask()
        }
        
        TaskProviderManager.instance.startTask(taskLabel.stringValue, inProject: selectedProject)
        setCurrentTaskLabels()
    }
    
    @IBAction func stopClicked(_ sender: NSButton) {
        
        let stopped = TaskProviderManager.instance.stopRunningTask()
        setCurrentTaskLabels()
        print("\(stopped)")
        
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
        setCurrentTaskLabels()
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
            let clientNames = selectedHod.children.flatMap { $0.name }
            clientPopup.addItems(withTitles: clientNames)
        }
        
        populateProjects()
    }
    
    fileprivate func populateProjects() {
        projectPopup.removeAllItems()
        if let selectedClient = selectedClient {
            var projectNames = selectedClient.children.flatMap { $0.name }
            
            projectNames.sort{
                return $0.0.compare($0.1) == .orderedAscending
            }
            
            projectPopup.addItems(withTitles: projectNames)
        }
    }
    
}

