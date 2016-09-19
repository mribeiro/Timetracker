//
//  TaskPingReceiver.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 28/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation

protocol TaskPingReceiver {
    
    func ping(_ interval: TimeInterval)
    
    func taskStarted()
    
    func taskStopped()
    
}
