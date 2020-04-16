//
//  JackTheMonkey.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 03/05/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
enum JackTheMonkey: Builder {
    
    case one
    case two
    case three
    
    var name: String {
        return "monkey"
    }
    
    var idle: String {
        return "🐒"
    }
    
    var start: String {
        return "🐵"
    }
    
    mutating func string() -> String {
        switch self {
        case .one:
            self = .two
            return "🙈"
        case .two:
            self = .three
            return "🙊"
        case .three:
            self = .one
            return "🙉"
        }
    }
    
}
