//
//  Timer+Utils.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 16/03/2019.
//  Copyright © 2019 Antonio Ribeiro. All rights reserved.
//

import Foundation

extension Timer {

    class func inOneSecond(_ block: @escaping (Timer) -> Void) -> Timer {
        return Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: block)
    }

}
