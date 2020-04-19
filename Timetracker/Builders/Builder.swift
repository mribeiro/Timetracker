//
//  Builder.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 03/05/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa
protocol Builder {
    mutating func string() -> String

    var name: String { get }

    var idle: String { get }

    var start: String { get }

}
