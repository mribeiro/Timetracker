//
//  AppDelegate+TaskPingReceiver.swift
//  Timetracker
//
//  Created by Antonio Ribeiro on 19/04/2020.
//  Copyright © 2020 Antonio Ribeiro. All rights reserved.
//

import Foundation

extension AppDelegate: TaskPingReceiver {

    func ping(_ interval: TimeInterval) {
        if let button = statusItem.button {
            let string = interval.toProperString()
            currentTaskTime = string

            var lastEvent: CFTimeInterval = 0
            lastEvent = CGEventSource.secondsSinceLastEventType(CGEventSourceStateID.hidSystemState,
                                                                eventType: CGEventType(rawValue: ~0)!)

            if Int(lastEvent) > maxIdleSeconds {
                if !showingIdleDialog {
                    let now = Date()
                    let idleDate = now - TimeInterval(maxIdleSeconds)
                    L.d("""
                        Showing idle dialog. \
                        Now is \(now) and the user was idle for \(maxIdleSeconds). Started idling at \(idleDate)
                        """)
                    handleIdleDialog(withResponse: showIdleDialogWithIdleDate(idleDate), andIdleStart: idleDate)
                    showingIdleDialog = false

                }
            }

            button.title = builder.string()

            if let menuTimer = self.menu.item(withTag: 1) {
                menuTimer.title = string
            }

        }
    }

    func taskStopped() {
        currentTaskTime = nil
        _ = Timer.inOneSecond { (_) in
            self.statusItem.button?.title = self.builder.idle
        }
    }

    func taskStarted() {
        statusItem.button?.title = builder.start
    }

}
