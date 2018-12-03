//
//  UserController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/31/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class UserController {
    
    static let shared = UserController()
    var currentUser: User?
    
    func createUser(withUsername username: String, email: String) {
        let user = User(username: username, email: email, userUUID: NSUUID().uuidString)
        self.currentUser = user
        GoalController.shared.saveToPersistentStore()
    }
    
    func checkIfUserExists() -> Bool {
        let moc = CoreDataStack.context
        let request = NSFetchRequest<User>(entityName: Constant.User)
        do {
            let fetchedUsers: [User] = try moc.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [User]
            guard let user : User = fetchedUsers.first else { return false }
            self.currentUser = user
            return true
        } catch {
            fatalError("Failed to fetch goals: \(error.localizedDescription)")
        }
    }
}
