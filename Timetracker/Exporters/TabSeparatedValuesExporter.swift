//
//  TabSeparatedValuesExporter.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 03/05/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation

class TabSeparatedValuesExporter {
    
    fileprivate static let calendar = Calendar.current
    fileprivate var tasksPerDate: [String: [Line]]!
    fileprivate var weekdays: [String: String] = [String: String]()
    
    init() {
        tasksPerDate = [String: [Line]]()
    }
    
    func export(_ tasks: [Task]) -> String {

        tasks.forEach {
            
            var line = Line()
            line.title = $0.title!
            line.project = $0.project!.name!
            line.client = $0.project!.client!.name!
            line.hod = $0.project!.client!.headOfDevelopment!.name!
            
            addStuff(line, startingOn: $0.startTime! as Date, endingOn: $0.endTime! as Date)
            
        }
        
        return toString()
    }
    
    fileprivate func toString() -> String {
        
        var s: String = ""
        
        self.tasksPerDate.keys.forEach { key in
            
            s.append("\(weekdays[key]!) (\(key))\r\n")
            
            tasksPerDate[key]?.forEach { line in
                s.append(line.description)
            }
            
            s.append("\r\n")
        }
        
        return s
    }
    
    fileprivate func addStuff(_ line: Line, startingOn startDate: Date, endingOn endDate: Date) {
        
        let startComponents = (TabSeparatedValuesExporter.calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .weekday], from: startDate)
        let startAsString = String(format: "%02d:%02d", startComponents.hour!, startComponents.minute!)
        
        var newLine = line
        newLine.start = startAsString
        
        if TabSeparatedValuesExporter.calendar.isDate(startDate, inSameDayAs: endDate) {
            
            
            let endComponents = (TabSeparatedValuesExporter.calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: endDate)
            
            
            let endAsString = String(format: "%02d:%02d", endComponents.hour!, endComponents.minute!)
            
            
            newLine.end = endAsString
            addLine(newLine, toDate: startComponents)
            
            
        } else {
            
            // add line from start to start date at 23:59
            
            let endAsString = "23:59"
            
            newLine.end = endAsString
            
            addLine(newLine, toDate: startComponents)
            
            
            // set start day to next day 00:00
            let calendar = TabSeparatedValuesExporter.calendar
            
            let startDateAtMidnight = calendar.startOfDay(for: startDate)
            
            let tomorrowAtMidnight = (calendar as NSCalendar).date(byAdding: .day, value: 1, to: startDateAtMidnight, options: NSCalendar.Options(rawValue: 0))!
            
            // call addStuff again
            addStuff(line, startingOn: tomorrowAtMidnight, endingOn: endDate)
            
        }
        
    }
    
    fileprivate func addLine(_ line: Line, toDate dateComponents:DateComponents) {
        
        let date = String(format: "%4d/%02d/%02d", dateComponents.year!, dateComponents.month!, dateComponents.day!)
        
        //dateComponents.weekday is 1-base index while weekdaySymobols is 0-base index, hence the -1
        let weekday = TabSeparatedValuesExporter.calendar.weekdaySymbols[dateComponents.weekday!-1]
        
        if tasksPerDate[date] == nil {
            tasksPerDate[date] = [Line]()
            weekdays[date] = weekday
        }
        tasksPerDate[date]?.append(line)
    }
    
}

private struct Line: CustomStringConvertible {
    
    var start: String!
    var end: String!
    var title: String!
    var hod: String!
    var client: String!
    var project: String!
    
    var description: String {
        return "\(start as String)\t\(end as String)\t\(hod as String)\t\(client as String)\t\(project as String)\t\(title as String)\r\n"
    }
    
}
