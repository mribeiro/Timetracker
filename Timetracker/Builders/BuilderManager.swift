//
//  BuilderManager.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 17/03/2019.
//  Copyright © 2019 Antonio Ribeiro. All rights reserved.
//

import Foundation
import Cocoa

class BuilderManager {
    
    class func getFromConfiguration() -> Builder {
        let builder = UserDefaults().string(forKey: "builder") ?? ""
        return getFromName(builder)
    }
    
    class func saveBuilder(_ name: String) -> Builder {
        UserDefaults().set(name, forKey: "builder")
        let builder = getFromName(name)
        // This looks so bad it hurts
        let appDelegate = NSApp.delegate as! AppDelegate
        appDelegate.builderChanged(builder)
        
        return builder
    }
    
    class func getFromName(_ name: String) -> Builder {
        
        switch name {
        case "moon":
            return MoonPhases.one
        case "clock":
            return Clock.one
        case "traffic_lights":
            return TrafficLights.one
        case "time_counter":
            return TimeCounter.one
        default: // monkey is the default
            return JackTheMonkey.one
        }
        
    }
    
}
