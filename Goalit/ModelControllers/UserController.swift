//
//  UserController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/31/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import Foundation
import Firebase

class UserController {
    
    static let shared = UserController()
    var currentUser: User?
    var ref: DatabaseReference!
    
    func createUser(withUsername username: String, userID: String, email: String, imageURL: String, profileImageData: Data, completion: @escaping() -> Void) {
        ref = Database.database().reference()
        
        let userDictionary = [Constant.userNameKey: username,
                              Constant.userUUIDKey: userID,
                              Constant.emailKey: email,
                              Constant.userImageURL: imageURL] as [String : Any]
        let childUpdates = ["\(userID)": userDictionary]
        
        ref.child("users").updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("User could not be saved: \(error).")
                completion()
            } else {
                print("User saved successfully!")
                let user = User(username: username, userID: userID, email: email, profileImageData: profileImageData)
                self.currentUser = user
                completion()
            }
        }
    }
    
    func fetchUser(userID: String, completion: @escaping() -> Void) {
        ref = Database.database().reference()
        
        ref.child("users").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            if !snapshot.exists() {
                guard let username = Auth.auth().currentUser?.displayName else { return }
                guard let email = Auth.auth().currentUser?.email else { return }
                UserController.shared.createUser(withUsername: username,
                                                 userID: userID,
                                                 email: email,
                                                 imageURL: "",
                                                 profileImageData: Data(),
                                                 completion: {
                    self.fetchUser(userID: userID, completion: {
                        completion()
                    })
                })
            } else {
                let value = snapshot.value as? NSDictionary
                guard let username = value?[Constant.userNameKey] as? String,
                let email = value?[Constant.emailKey] as? String,
                let imageURL = value?[Constant.userImageURL] as? String else { return }
                self.fetchImageData(WithURL: imageURL, completion: { (data) in
                    if let data = data {
                        let user = User(username: username, userID: userID, email: email, profileImageData: data)
                        self.currentUser = user
                        completion()
                    } else {
                        completion()
                    }
                })
            }
        }) { (error) in
            print("Error fetching User \(error.localizedDescription)")
            completion()
        }
    }
    
    func fetchImageData(WithURL url: String, completion:@escaping(Data?) -> Void) {
        if url.isEmpty { completion(nil); return }
        let storageRef = Storage.storage().reference(forURL: url)
        storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error fetching image data with url: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(data)
        }
    }
}
