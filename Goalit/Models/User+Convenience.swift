//
//  User+Convenience.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/31/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import CoreData

extension User {
    @discardableResult convenience init(firstName: String, lastName: String, userUUID: String, recordID: String = "", context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.firstName = firstName
        self.lastName = lastName
        self.userUUID = userUUID
        self.recordID = recordID
    }
}
