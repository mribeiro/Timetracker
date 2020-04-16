//
//  MoonPhases.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 03/05/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation

enum MoonPhases: Builder {
    
    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    
    var name: String {
        return "moon"
    }
    
    var idle: String {
        return "🌚"
    }
    
    var start: String {
        return "🌝"
    }
    
    mutating func string() -> String {
        switch self {
        case .one:
            self = .two
            return "🌕"
        case .two:
            self = .three
            return "🌖"
        case .three:
            self = .four
            return "🌗"
        case .four:
            self = .five
            return "🌘"
        case .five:
            self = .six
            return "🌑"
        case .six:
            self = .seven
            return "🌒"
        case .seven:
            self = .eight
            return "🌓"
        case .eight:
            self = .one
            return "🌔"
        }
    }
    
}
