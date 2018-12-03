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
    @discardableResult convenience init(username: String, email: String, userUUID: String, context: NSManagedObjectContext = CoreDataStack.context) {
        self.init(context: context)
        self.username = username
        self.email = email
        self.userUUID = userUUID
    }
}
