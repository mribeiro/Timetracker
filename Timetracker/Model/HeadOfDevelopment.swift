//
//  HeadOfDevelopment.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 25/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import CoreData


class HeadOfDevelopment: NSManagedObject {
    
    static let entityName = "HeadOfDevelopment"
    
    @NSManaged var name: String?
    @NSManaged var clients: Set<Client>?
    
    var isLeaf: Bool = false
    
    
    var children: [Client] {
        return Array(self.clients!)
    }
    
    func getClientByName(_ clientName: String?) -> Client? {
        
        guard let cName = clientName else { return nil }
        
        return children.filter {
            return $0.name?.compare(cName) == .orderedSame
        }.first
    }
    
    // Insert code here to add functionality to your managed object subclass
    
}
