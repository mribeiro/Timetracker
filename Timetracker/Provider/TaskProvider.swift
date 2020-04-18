//
//  TaskProvider.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 30/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import CoreData

class TaskProviderManager {

    fileprivate(set) static var instance: TaskProvider!

    static func setup(_ coreDataContext: NSManagedObjectContext) -> TaskProvider {
        if instance == nil {
            instance = CoreDataTaskProvider(coreDataContext: coreDataContext)
        }
        return instance
    }

}

protocol DataChanged: AnyObject {

    func didChange()

}

// swiftlint:disable line_length
protocol TaskProvider {

    var isTaskRunning: Bool { get }

    var runningTask: Task? { get }

    var projectOfRunningTask: Project? { get }

    var allTasks: [Task]? { get }

    func getHeadOfDevelopments() -> [HeadOfDevelopment]

    func saveHeadOfDevelopments(_ name: String) -> Bool

    func saveClient(_ name: String, ofHod hod: HeadOfDevelopment) -> Bool

    func saveProject(_ name: String, ofClient client: Client) -> Bool

    func addPingReceiver(_ pingReceiver: TaskPingReceiver)

    func removePingReceiver(_ pingReceiver: TaskPingReceiver)

    func startTask(_ name: String, inProject project: Project)

    func stopRunningTask(atDate endDate: Date?) -> Bool

    func stopRunningTask() -> Bool

    func deleteTasks(_ tasks: [Task]) -> Bool

    func saveTaskInProject(_ project: Project, withTitle title: String, startingAt startDate: Date, finishingAt finishDate: Date) -> Bool

    func getTasksBetween(_ startDate: Date, and endDate: Date) -> [Task]

    func updateTask(_ task: Task) -> Bool

    func addChangesListener(_ listener: DataChanged)

    func removeChangesListener(_ listener: DataChanged)

    func countProjects() -> Int

}
// swiftlint:enable line_length
