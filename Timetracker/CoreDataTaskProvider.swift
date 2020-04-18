//
//  TaskOrchestrator.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 25/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import CoreData

class CoreDataTaskProvider: TaskProvider {

    fileprivate var coreDataCtx: NSManagedObjectContext
    fileprivate(set) static var runningTask: Task?
    fileprivate static var timer: Timer?
    fileprivate static var pingReceivers: [TaskPingReceiver]?
    fileprivate static var runningProject: Project?
    fileprivate static var dataChangedListeners = [DataChanged]()

    var runningTask: Task? {
        return CoreDataTaskProvider.runningTask
    }

    var projectOfRunningTask: Project? {
        return CoreDataTaskProvider.runningProject
    }

    var isTaskRunning: Bool {
        return CoreDataTaskProvider.runningTask != nil
    }

    var allTasks: [Task]? {
        let fetchRequest = NSFetchRequest<Task>(entityName: Task.entityName)
        return try? coreDataCtx.fetch(fetchRequest)
    }

    init(coreDataContext: NSManagedObjectContext) {
        coreDataCtx = coreDataContext
        subscribeCoreDataNotifications()
    }

    fileprivate func subscribeCoreDataNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(coreDataChanged), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: coreDataCtx)
    }

    func addPingReceiver(_ taskPingReceiver: TaskPingReceiver) {
        if CoreDataTaskProvider.pingReceivers == nil {
            CoreDataTaskProvider.pingReceivers = [TaskPingReceiver]()
        }

        CoreDataTaskProvider.pingReceivers?.append(taskPingReceiver)
    }

    func removePingReceiver(_ pingReceiver: TaskPingReceiver) {
        CoreDataTaskProvider.pingReceivers = CoreDataTaskProvider.pingReceivers?.filter { ($0 as AnyObject) !== (pingReceiver as AnyObject) }
    }

    func countProjects() -> Int {
        let fetchRequest = NSFetchRequest<Project>(entityName: Project.entityName)
        do {
            return try coreDataCtx.count(for: fetchRequest)
        } catch {
            L.e("\(error)")
        }
        return 0
    }

    func getHeadOfDevelopments() -> [HeadOfDevelopment] {

        let fetchRequest = NSFetchRequest<HeadOfDevelopment>(entityName: HeadOfDevelopment.entityName)
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {

            let results = try coreDataCtx.fetch(fetchRequest)
            return results

        } catch {
            L.e("\(error)")
        }

        return []

    }

    func saveHeadOfDevelopments(_ name: String) -> Bool {

        guard name.count > 0 else {
            return false
        }

        guard let hod = NSEntityDescription.insertNewObject(forEntityName: HeadOfDevelopment.entityName, into: coreDataCtx) as? HeadOfDevelopment else {
            return false
        }
        hod.name = name

        do {
            try coreDataCtx.save()
            return true

        } catch {
            L.e("\(error)")
        }

        return false
    }

    func saveClient(_ name: String, ofHod hod: HeadOfDevelopment) -> Bool {

        guard name.count > 0,
            let client = NSEntityDescription.insertNewObject(forEntityName: Client.entityName, into: coreDataCtx) as? Client else {
            return false
        }

        client.name = name
        client.headOfDevelopment = hod

        do {
            try coreDataCtx.save()
            return true

        } catch {
            L.e("\(error)")
        }

        return false

    }

    func saveProject(_ name: String, ofClient client: Client) -> Bool {

        guard name.count > 0,
            let project = NSEntityDescription.insertNewObject(forEntityName: Project.entityName, into: coreDataCtx) as? Project else {
            return false
        }

        project.name = name
        project.client = client

        do {
            try coreDataCtx.save()
            return true

        } catch {
            L.e("\(error)")
        }

        return false

    }

    func startTask(_ name: String, inProject project: Project) {

        if CoreDataTaskProvider.runningTask != nil {
            _ = stopRunningTask()
        }

        guard CoreDataTaskProvider.runningTask == nil else {
            return
        }

        let taskDescriptor = NSEntityDescription.entity(forEntityName: Task.entityName, in: coreDataCtx)

        let task = Task(entity: taskDescriptor!, insertInto: nil)

        CoreDataTaskProvider.runningProject = project
        //task.project = project
        task.startTime = Date()
        task.title = name

        CoreDataTaskProvider.runningTask = task

        CoreDataTaskProvider.pingReceivers?.forEach {
            $0.taskStarted()
        }

        CoreDataTaskProvider.timer = Timer(timeInterval: 1, target: self, selector: #selector(CoreDataTaskProvider.taskPing), userInfo: nil, repeats: true)
        RunLoop.current.add(CoreDataTaskProvider.timer!, forMode: RunLoop.Mode.common)
    }

    func stopRunningTask(atDate endDate: Date?) -> Bool {

        if let task = CoreDataTaskProvider.runningTask {
            task.endTime = endDate ?? Date()
            coreDataCtx.insert(task)
            task.project = CoreDataTaskProvider.runningProject
            //CoreDataTaskProvider.runningProject?.tasks?.insert(task)
            do {
                try coreDataCtx.save()
                CoreDataTaskProvider.runningProject = nil
                CoreDataTaskProvider.runningTask = nil
                CoreDataTaskProvider.timer?.invalidate()
                CoreDataTaskProvider.timer = nil

                CoreDataTaskProvider.pingReceivers?.forEach {
                    $0.taskStopped()
                }

                return true
            } catch {
                L.e("\(error)")
            }

        }
        return false

    }

    func stopRunningTask() -> Bool {
        return stopRunningTask(atDate: Date())
    }

    func deleteTasks(_ tasks: [Task]) -> Bool {
        tasks.forEach {
            _ = $0.project?.tasks?.remove($0)
            coreDataCtx.delete($0)
        }
        do {
            try coreDataCtx.save()
            return true
        } catch {
            return false
        }
    }

    func saveTaskInProject(_ project: Project, withTitle title: String, startingAt startDate: Date, finishingAt finishDate: Date) -> Bool {

        guard let task = NSEntityDescription.insertNewObject(forEntityName: Task.entityName, into: coreDataCtx) as? Task else {
            return false
        }

        task.project = project
        task.title = title
        task.startTime = startDate
        task.endTime = finishDate

        do {
            try coreDataCtx.save()
            return true
        } catch {
            L.e("\(error)")
            return false
        }

    }

    func getTasksBetween(_ startDate: Date, and endDate: Date) -> [Task] {

        let predicate = NSPredicate(format: "(startTime >= %@) and (endTime <= %@)", startDate as CVarArg, endDate as CVarArg)

        let fetchRequest = NSFetchRequest<Task>(entityName: Task.entityName)
        fetchRequest.predicate = predicate

        do {

            let tasks = try coreDataCtx.fetch(fetchRequest)
            return tasks
        } catch {
            L.e("\(error)")
        }

        return []
    }

    func updateTask(_ task: Task) -> Bool {

        do {
            _ = CoreDataTaskProvider.runningProject?.tasks?.remove(task)
            try coreDataCtx.save()
            return true
        } catch {
            L.e("\(error)")
            return false
        }

    }

    func addChangesListener(_ listener: DataChanged) {
        CoreDataTaskProvider.dataChangedListeners.append(listener)
    }

    func removeChangesListener(_ listener: DataChanged) {
        CoreDataTaskProvider.dataChangedListeners = CoreDataTaskProvider.dataChangedListeners.filter {
            return $0 !== listener
        }
    }

    @objc func coreDataChanged() {
        CoreDataTaskProvider.dataChangedListeners.forEach { $0.didChange() }
    }

    @objc func taskPing() {

        let interval = Date().timeIntervalSince(CoreDataTaskProvider.runningTask!.startTime! as Date)

        CoreDataTaskProvider.pingReceivers?.forEach {
            $0.ping(interval)
        }
    }

}
