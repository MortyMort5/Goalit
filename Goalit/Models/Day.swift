//
//  Day.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation

class Day {
    
    let completed: Int
    let date: Date
    let dayUUID: String
    let goalIDRef: String
    
    init(date: Date, completed: Int = 0, goal: Goal, dayUUID: String, goalIDRef: String = "") {
        self.date = date
        self.completed = completed
        self.dayUUID = dayUUID
        self.goalIDRef = goalIDRef
    }
}
