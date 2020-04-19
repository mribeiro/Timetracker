//
//  Client.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 25/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import CoreData

class Client: NSManagedObject {

    static let entityName = "Client"

    @NSManaged var name: String?
    @NSManaged var projects: Set<Project>?
    @NSManaged var headOfDevelopment: HeadOfDevelopment?

    @objc var isLeaf: Bool = false

    @objc var children: [Project] {
        return Array(self.projects!)
    }

    func getProjectByName(_ name: String?) -> Project? {
        guard let pName = name else {
            return nil
        }

        return children.filter {
            return pName.compare($0.name!) == .orderedSame
        }.first
    }
}
