//
//  NSDate+Utils.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 05/05/16.
//  Copyright © 2016 Antonio Ribeiro. All rights reserved.
//

import Foundation

extension Date {
    func getStartAndEndOfThisWeek() -> (monday: Date, sunday: Date) {
        Date.getStartAndEndOfWeek(ofDate: self)
    }

    static func getStartAndEndOfWeek(ofDate date: Date) -> (monday: Date, sunday: Date) {
        let currentCalendar = Calendar.current
        let currentWeekday = currentCalendar.component(.weekday, from: date)
        // 1 is sunday . If it is sunday we know the diff is -6 because the week ends on sundays.
        // 2 is monday . The diff must be 0 because the week starts on mondays.
        let diffToMonday = currentWeekday == 1 ? -6 : 2 - currentWeekday
        let mondayThisWeek = currentCalendar.date(byAdding: .day, value: diffToMonday, to: date)
        let sundayThisWeek = currentCalendar.date(byAdding: .day, value: 6, to: mondayThisWeek!)
        return (mondayThisWeek!, sundayThisWeek!)
    }
}
