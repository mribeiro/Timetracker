//
//  TrafficLights.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 16/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation

enum TrafficLights: Builder {
    
    case one
    
    mutating func string() -> String {
        return "🟢"
    }
    
    var name: String { "traffic_lights" }
    
    var idle: String { "🔴" }
    
    var start: String { "🟡" }
    
    
}
