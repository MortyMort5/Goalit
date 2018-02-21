//
//  Day+Convenience.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import CoreData

extension Day {
    @discardableResult convenience init(date: Date, completed: Int32 = 0, goal: Goal, dayUUID: String, recordID: String = "", dayOwnerRef: String = "", context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.date = date
        self.completed = completed
        self.goal = goal
        self.dayUUID = dayUUID
        self.recordID = recordID
        self.dayOwnerRef = dayOwnerRef
    }
}
