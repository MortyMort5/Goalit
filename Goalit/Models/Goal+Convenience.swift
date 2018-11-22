//
//  Goal+Convenience.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import CoreData

extension Goal {
    @discardableResult convenience init(dateCreated: Date,name: String, totalCompleted: Int32, user: User, goalUUID: String, recordID: String = "", goalType: Int32, goalOwnerRef: String = "", context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.name = name
        self.dateCreated = dateCreated
        self.totalCompleted = totalCompleted
        self.user = user
        self.goalUUID = goalUUID
        self.recordID = recordID
        self.goalType = goalType
        self.goalOwnerRef = goalOwnerRef
    }
}
