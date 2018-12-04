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
    var ref: DatabaseReference!
    
    func createUser(withUsername username: String, email: String, userID: String) {
        ref = Database.database().reference()
        
        guard let key = ref.child("users").childByAutoId().key else { return }
        let userDictionary = [Constant.userNameKey: username,
                    Constant.userUUIDKey: userID] as [String : Any]
        let childUpdates = ["\(key)": userDictionary]
        
        ref.child("users").updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("User could not be saved: \(error).")
            } else {
                print("User saved successfully!")
                let user = User(username: username, email: email, userUUID: userID)
                self.currentUser = user
                GoalController.shared.saveToPersistentStore()
            }
        }
        

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
