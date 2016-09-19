//
//  AppDelegate.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 25/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, TaskPingReceiver {
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    
    var builder: Builder = MoonPhases.one
    
    let menu = NSMenu()
    
    var taskProvider: TaskProvider!
    
    var currentTaskTime: String?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        taskProvider = TaskProviderManager.setup(managedObjectContext)
        taskProvider.addPingReceiver(self)
        
        //button.image = NSImage(named: "StatusBarButtonImage")
        statusItem.button?.title = builder.idle
        
        statusItem.menu = menu
        statusItem.menu?.delegate = self
        
    }
    

    func applicationWillTerminate(_ aNotification: Notification) {
        taskProvider.stopRunningTask()
    }

    // MARK: - TaskPingReceiver implementation
    func ping(_ interval: TimeInterval) {
        if let button = statusItem.button {
            let string = interval.toProperString()
            currentTaskTime = string
            
            //button.title = string
            button.title = builder.string()
        }
    }
    
    func taskStopped() {
        statusItem.button?.title = builder.idle
        currentTaskTime = nil
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
            let url = self.applicationDocumentsDirectory.appendingPathComponent("CocoaAppCD2_DEV.sqlite")
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
            NSApplication.shared().presentError(error)
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
                NSApplication.shared().presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(_ window: NSWindow) -> UndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return managedObjectContext.undoManager
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplicationTerminateReply {
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
            if answer == NSAlertFirstButtonReturn {
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
    
    func taskClicked(_ sender: NSMenuItem) {
        if let task = sender.representedObject as? Task {
            print(sender.representedObject)
            
            if taskProvider.isTaskRunning {
                taskProvider.stopRunningTask()
            }
            
            taskProvider.startTask(task.title!, inProject: task.project!)
        }
    }
    
    func stopTaskClicked(_ sender: NSMenuItem) {
        taskProvider.stopRunningTask()
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
    
}
