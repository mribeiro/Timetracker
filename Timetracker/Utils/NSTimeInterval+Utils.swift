//
//  NSTimeInterval+Utils.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 30/04/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

extension TimeInterval {
    
    func decomposeTimeInterval() -> (hours: Int, minutes: Int, seconds: Int) {
        let interval = Int(self)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return (hours: hours, minutes: minutes, seconds: seconds)
    }
    
    func toProperString() -> String {
        
        let decomposed = self.decomposeTimeInterval()
        
        var components = DateComponents()
        components.hour = decomposed.hours
        components.minute = decomposed.minutes
        components.second = decomposed.seconds
        
        return String(format: "%02d:%02d:%02d", components.hour!, components.minute!, components.second!)
    }
    
}
