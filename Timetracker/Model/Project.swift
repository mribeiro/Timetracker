//
//  Project.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 25/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import CoreData


class Project: NSManagedObject {
    
    static let entityName = "Project"
    
    @NSManaged var name: String?
    @NSManaged var client: Client?
    @NSManaged var tasks: Set<Task>?

    @objc var isLeaf: Bool = true
    
    @objc var children = [] as NSArray
    
}
