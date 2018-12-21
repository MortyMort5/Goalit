//
//  DayController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import Firebase


class DayController {
    
    static let shared = DayController()
    var ref: DatabaseReference!
    
    func createDay(date: Date, completed: Int, dayUUID: String, goalIDRef: String, selectedDays: String) -> Day? {
            return Day(date: date, completed: completed, dayUUID: dayUUID, goalIDRef: goalIDRef)
    }
    
    func deleteAllDays() {
        ref = Database.database().reference()
        ref.child("days").removeValue()
    }
}
