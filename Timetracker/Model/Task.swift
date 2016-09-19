//
//  Task.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 25/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import CoreData


class Task: NSManagedObject {

    static let entityName = "Task"
    
    @NSManaged var title: String?
    @NSManaged var comment: String?
    @NSManaged var startTime: Date?
    @NSManaged var endTime: Date?
    @NSManaged var project: Project?

    
}
