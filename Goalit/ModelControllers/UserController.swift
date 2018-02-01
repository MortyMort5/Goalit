//
//  UserController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/31/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation

class UserController {
    
    static let shared = UserController()
    var currentUser: User?
    
    init() {
        self.createUser(withFirstName: "Sterling", lastName: "Mortensen")
    }
    
    func createUser(withFirstName firstName: String, lastName: String) {
        let user = User(firstName: firstName, lastName: lastName, userUUID: NSUUID().uuidString)
        self.currentUser = user
        GoalController.shared.saveToPersistentStore()
    }
}
