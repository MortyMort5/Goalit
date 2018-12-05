//
//  UserController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/31/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import Firebase

class UserController {
    
    static let shared = UserController()
    var currentUser: User?
    var ref: DatabaseReference!
    
    func createUser(withUsername username: String, userID: String, completion: @escaping() -> Void) {
        ref = Database.database().reference()
        
        let userDictionary = [Constant.userNameKey: username, Constant.userUUIDKey: userID] as [String : Any]
        let childUpdates = ["\(userID)": userDictionary]
        
        ref.child("users").updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("User could not be saved: \(error).")
                completion()
            } else {
                print("User saved successfully!")
                let user = User(username: username, userID: userID)
                self.currentUser = user
                completion()
            }
        }
    }
    
    func fetchUser(userID: String, completion: @escaping() -> Void) {
        ref = Database.database().reference()
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            
            let value = snapshot.value as? NSDictionary
            let username = value?["username"] as? String ?? ""
            let user = User(username: username, userID: userID)
            self.currentUser = user
            completion()
            
        }) { (error) in
            print("Error fetching User \(error.localizedDescription)")
            completion()
        }
    }
}
