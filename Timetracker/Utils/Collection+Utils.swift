//
//  Collection+Utils.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 14/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
