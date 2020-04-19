//
//  Clock.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 16/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation

enum Clock: Builder {

    case one
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case eleven
    case twelve

    // swiftlint:disable cyclomatic_complexity
    mutating func string() -> String {
        switch self {
        case .one:
            self = .two
            return "🕐"
        case .two:
            self = .three
            return "🕑"
        case .three:
            self = .four
            return "🕒"
        case .four:
            self = .five
            return "🕓"
        case .five:
            self = .six
            return "🕔"
        case .six:
            self = .seven
            return "🕕"
        case .seven:
            self = .eight
            return "🕖"
        case .eight:
            self = .nine
            return "🕗"
        case .nine:
            self = .ten
            return "🕘"
        case .ten:
            self = .eleven
            return "🕙"
        case .eleven:
            self = .twelve
            return "🕚"
        case .twelve:
            self = .one
            return "🕛"
        }
    }
    // swiftlint:enable cyclomatic_complexity

    var name: String { "moon" }

    var idle: String { "⏸" }

    var start: String { "🕛" }

}
