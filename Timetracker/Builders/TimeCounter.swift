//
//  TimeCounter.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 16/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation

enum TimeCounter: Builder {

    case one

    mutating func string() -> String {
        if let runningTimeStart = TaskProviderManager.instance.runningTask?.startTime {
            return Date().timeIntervalSince(runningTimeStart).toProperString()
        }

        return "???"
    }

    var name: String { "time_counter" }

    var idle: String { "Stopped" }

    var start: String { "00:00:00" }

}
