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
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSUserNotificationCenterDelegate, SUUpdaterDelegate {

    let menu = NSMenu()
    let databaseName = Bundle.main.object(forInfoDictionaryKey: "DB_NAME") as? String ?? "default_db_name_"
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let maxIdleSeconds = Int(Bundle.main.object(forInfoDictionaryKey: "IDLE_SECONDS") as? String ?? "300") ?? 300

    var currentTaskTime: String?
    var showingIdleDialog = false
    var taskProvider: TaskProvider!
    var builder: Builder = BuilderManager.getFromConfiguration()

    let preferencesWindowController = PreferencesWindowController(
        preferencePanes: [
            PreferenceBuilderViewController(),
            PreferenceLogViewController(),
            PreferenceMiscViewController(),
            PreferenceAboutViewController()
        ], style: .toolbarItems
    )

    @IBOutlet weak var updater: SUUpdater!
    @IBOutlet weak var taskRunnerMenuItem: NSMenuItem!
    @IBOutlet weak var costCentresMenuItem: NSMenuItem!
    @IBOutlet weak var taskListMenuItem: NSMenuItem!

    @IBAction func checkForUpdatesClicked(_ sender: Any) {
        self.updater.checkForUpdates(sender)
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        self.updater.delegate = self

        taskProvider = TaskProviderManager.setup(managedObjectContext)
        taskProvider.addPingReceiver(self)

        statusItem.button?.title = builder.idle

        statusItem.menu = menu
        statusItem.menu?.delegate = self

        NSUserNotificationCenter.default.scheduledNotifications.forEach {
            NSUserNotificationCenter.default.removeScheduledNotification($0)
        }
        self.scheduleNotification(appJustOpened: true)
        DockIconManager.setIconPerConfiguration()

        let defaultCenter = DistributedNotificationCenter.default()

        defaultCenter.addObserver(self,
                                  selector: #selector(screenLocked),
                                  name: NSNotification.Name(rawValue: "com.apple.screenIsLocked"),
                                  object: nil)

    }

    @objc func screenLocked() {
        L.v("Screen was locked")
        if TaskProviderManager.instance.isTaskRunning {
            L.v("Showing idle dialog as there was a task running")
            showIdleDialogWithIdleDate(Date())
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        _ = taskProvider.stopRunningTask()
    }

    func builderChanged(_ newBuilder: Builder) {

        self.builder = newBuilder
        if !self.taskProvider.isTaskRunning {
            statusItem.button?.title = builder.idle
        }
    }

    private func scheduleNotification(appJustOpened: Bool = false) {
        L.d("scheduling notification...")
        let now = Date()
        let currentCalendar = Calendar.current

        var triggerDate: Date?

        if appJustOpened {
            L.i("app just opened, let's remind the user")
           triggerDate = Date()
        } else {
            // today @ 8am
            triggerDate = currentCalendar.date(bySettingHour: 8, minute: 0, second: 0, of: now)

            L.d("trigger date is \(String(describing: triggerDate))")

            // trigger date has passed
            if triggerDate! < now {
                // tomorrow @ 8am
                triggerDate = currentCalendar.date(byAdding: .day, value: 1, to: triggerDate!)
                L.d("trigger date has passed, scheduling for tomorrow: \(String(describing: triggerDate))")
            }
        }

        let notification = NSUserNotification()
        notification.title = "Track your time!"
        notification.informativeText = "Don't forget to track your tasks."
        notification.soundName = NSUserNotificationDefaultSoundName
        notification.deliveryDate = triggerDate

        NSUserNotificationCenter.default.delegate = self
        NSUserNotificationCenter.default.scheduleNotification(notification)
        L.d("scheduled to \(notification.deliveryDate!)")
    }

    func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        self.scheduleNotification(appJustOpened: false)
    }

    @IBAction func openPreferences(_ sender: NSMenuItem) {
        let prefId = PreferencePaneIdentifier(sender.identifier?.rawValue ?? "")
        preferencesWindowController.window?.titlebarAppearsTransparent = true
        preferencesWindowController.show(preferencePane: prefId)
    }

    func showIdleDialogWithIdleDate(_ idleDate: Date) {

        // If idle dialog is already showing do not show again
        guard !showingIdleDialog else {
            return
        }

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
        let response = alert.runModal()

        handleIdleDialog(withResponse: response, andIdleStart: idleDate)
        showingIdleDialog = false

    }

    func handleIdleDialog(withResponse response: NSApplication.ModalResponse, andIdleStart idleDate: Date) {
        switch response {
        case .alertFirstButtonReturn: // stop at idle time
            L.d("Task stopping at idle time")
            _ = taskProvider.stopRunningTask(atDate: idleDate)
        case .alertSecondButtonReturn: // stop now
            L.d("Task stopping now")
            _ = taskProvider.stopRunningTask()
        default: // continue
            L.d("nothing to do, let's continue counting time")
        }
    }

    func executeSegue(ofMenuItem menuItem: NSMenuItem) {
        if let action = menuItem.action, let target = menuItem.target {
            NSApplication.shared.activate(ignoringOtherApps: true)
            NSApplication.shared.sendAction(action, to: target, from: menuItem)
        }
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file.
        // This code uses a directory named "org.aribeiro.Timetracker" in the user's Application Support directory.
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let appSupportURL = urls[urls.count - 1]
        return appSupportURL.appendingPathComponent("org.aribeiro.Timetracker")
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application.
        // This property is not optional.
        // It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Timetracker", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application.
        // This implementation creates and returns a coordinator, having added the store for the application to it.
        // (The directory for the store is created, if necessary.)
        // This property is optional since there are legitimate error
        //      conditions that could cause the creation of the store to fail.
        let fileManager = FileManager.default
        var failError: NSError?
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."

        // Make sure the application files directory is there
        do {
            let properties = try
                (self.applicationDocumentsDirectory as NSURL).resourceValues(forKeys: [URLResourceKey.isDirectoryKey])
            if !(properties[URLResourceKey.isDirectoryKey]! as AnyObject).boolValue {
                failureReason =
                "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } catch {
            let nserror = error as NSError
            if nserror.code == NSFileReadNoSuchFileError {
                do {
                    try fileManager.createDirectory(atPath: self.applicationDocumentsDirectory.path,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
                } catch {
                    failError = nserror
                }
            } else {
                failError = nserror
            }
        }

        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator?
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url =
                self.applicationDocumentsDirectory.appendingPathComponent("CocoaAppCD2_\(self.databaseName).sqlite")
            do {
                try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType,
                                                    configurationName: nil,
                                                    at: url,
                                                    options: nil)
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
        // Returns the managed object context for the application
        // (which is already bound to the persistent store coordinator for the application.)
        // This property is optional since there are legitimate error conditions
        //      that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

}
