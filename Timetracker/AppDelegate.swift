//
//  AppDelegate.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 25/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Cocoa
import IOKit
import AppKit
import Preferences
import SwiftLog

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, TaskPingReceiver {
    
    let databaseName = Bundle.main.object(forInfoDictionaryKey: "DB_NAME") as! String
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let idleTime = Int(Bundle.main.object(forInfoDictionaryKey: "IDLE_SECONDS") as! String)!
    
    var builder: Builder = BuilderManager.getFromConfiguration()
    
    let menu = NSMenu()
    
    var taskProvider: TaskProvider!
    
    var currentTaskTime: String?
    
    func builderChanged(_ newBuilder: Builder) {
        
        self.builder = newBuilder
        if (!self.taskProvider.isTaskRunning) {
            statusItem.button?.title = builder.idle
        }
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        taskProvider = TaskProviderManager.setup(managedObjectContext)
        taskProvider.addPingReceiver(self)
        
        //button.image = NSImage(named: "StatusBarButtonImage")
        statusItem.button?.title = builder.idle
        
        statusItem.menu = menu
        statusItem.menu?.delegate = self
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        _ = taskProvider.stopRunningTask()
    }

    let preferencesWindowController = PreferencesWindowController(
        viewControllers: [
            PreferenceBuilderViewController(),
            PreferenceLogViewController()
        ]
    )
    
    @IBAction func openPreferences(_ sender: NSMenuItem) {
        preferencesWindowController.showWindow()
    }
    
    
    var showingIdleDialog = false;
    func showIdleDialogWithIdleDate(_ idleDate: Date) -> NSApplication.ModalResponse {
        self.showingIdleDialog = true
        let alert = NSAlert()
        
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "HH:mm"
        let dateStr = formatter.string(from: idleDate)
        
        alert.messageText = "Idle time"
        alert.informativeText = "You've been idle since \(dateStr)"
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Stop at idle time")
        alert.addButton(withTitle: "Stop now")
        alert.addButton(withTitle: "Continue")
        return alert.runModal()
    }
    
    func handleIdleDialog(withResponse response: NSApplication.ModalResponse, andIdleStart idleDate: Date) {
        switch response {
        case .alertFirstButtonReturn: // stop at idle time
            L.d("Task stopping at idle time")
            _ = taskProvider.stopRunningTask(atDate: idleDate)
            break
        case .alertSecondButtonReturn: // stop now
            L.d("Task stopping now")
            _ = taskProvider.stopRunningTask()
            break
        default: // continue
            L.d("nothing to do, let's continue counting time")
            break
        }
        
    }
    
    // MARK: - TaskPingReceiver implementation
    func ping(_ interval: TimeInterval) {
        if let button = statusItem.button {
            let string = interval.toProperString()
            currentTaskTime = string
            
            var lastEvent:CFTimeInterval = 0
            lastEvent = CGEventSource.secondsSinceLastEventType(CGEventSourceStateID.hidSystemState, eventType: CGEventType(rawValue: ~0)!)
            
            if (Int(lastEvent) > idleTime) {
                if (!showingIdleDialog) {
                    let idleDate = Date();
                    L.d("Showing idle dialog")
                    handleIdleDialog(withResponse: showIdleDialogWithIdleDate(idleDate), andIdleStart: idleDate)
                    showingIdleDialog = false
                    
                }
            }
            
            button.title = builder.string()
            
            if let menuTimer = self.menu.item(withTag: 1) {
                menuTimer.title = string
            }
            
        }
    }
    
    func taskStopped() {
        currentTaskTime = nil
        _ = Timer.inOneSecond { (timer) in
            self.statusItem.button?.title = self.builder.idle
        }
    }
    
    func taskStarted() {
        statusItem.button?.title = builder.start
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "org.aribeiro.Timetracker" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent("org.aribeiro.Timetracker")
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Timetracker", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = FileManager.default
        var failError: NSError? = nil
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."
        
        // Make sure the application files directory is there
        do {
            let properties = try (self.applicationDocumentsDirectory as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            if !(properties[URLResourceKey.isDirectoryKey]! as AnyObject).boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } catch  {
            let nserror = error as NSError
            if nserror.code == NSFileReadNoSuchFileError {
                do {
                    try fileManager.createDirectory(atPath: self.applicationDocumentsDirectory.path, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    failError = nserror
                }
            } else {
                failError = nserror
            }
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = nil
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.appendingPathComponent("CocoaAppCD2_\(self.databaseName).sqlite")
            do {
                try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
            } catch {
                failError = error as NSError
            }
        }
        
        if shouldFail || (failError != nil) {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            if failError != nil {
                dict[NSUnderlyingErrorKey] = failError
            }
            let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.shared.presentError(error)
            abort()
        } else {
            return coordinator!
        }
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    
    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(_ sender: AnyObject!) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing before saving")
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSApplication.shared.presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return managedObjectContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(type(of: self))) unable to commit editing to terminate")
            return .terminateCancel
        }
        
        if !managedObjectContext.hasChanges {
            return .terminateNow
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .terminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButton(withTitle: quitButton)
            alert.addButton(withTitle: cancelButton)
            
            let answer = alert.runModal()
            if answer == NSApplication.ModalResponse.alertFirstButtonReturn {
                return .terminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .terminateNow
    }
    
}

extension AppDelegate: NSMenuDelegate {
    
    func menuWillOpen(_ menu: NSMenu) {
        
        menu.removeAllItems()
    
        
        loadBasicMenuItems(menu)
        loadTree(menu)
        loadCurrentTask(menu)
        
    }
    
    func open(_ action: AnyObject) {
        if let controller = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "id_task_runner") as? NSWindowController {
            //NSApplication.shared().mainWindow
            controller.showWindow(self)
        }
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
                            let projectItem = projectsMenu.addItem(withTitle: project.name!, action: nil, keyEquivalent: "")
                            
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
                                    let taskItem = tasksMenu.addItem(withTitle: task.title!, action: #selector(taskClicked), keyEquivalent: "")
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
    
    func loadBasicMenuItems(_ menu: NSMenu) {
        
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
    
    func loadCurrentTask(_ menu:NSMenu) {
        if let task = taskProvider.runningTask , let project = taskProvider.projectOfRunningTask {
            
            menu.addItem(NSMenuItem.separator())
            
            let client = project.client!
            let hod = client.headOfDevelopment!
            
            let hodItem = NSMenuItem(title: hod.name!, action: nil, keyEquivalent: "")
            hodItem.isEnabled = false
            let projectItem = NSMenuItem(title: project.name!,  action: nil, keyEquivalent: "")
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
}
