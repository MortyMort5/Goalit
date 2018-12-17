//
//  User.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/31/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit

class User {
    
    let username: String
    let userID: String
    let email: String
    var imageURL: String?
    var profileImageData: Data?
    
    init(username: String, userID: String, email: String, profileImageData: Data) {
        self.username = username
        self.userID = userID
        self.email = email
        self.profileImageData = profileImageData
    }
    
    var profileImage: UIImage {
        guard let imageData = profileImageData else { return UIImage() }
        guard let image = UIImage(data: imageData) else { return UIImage() }
        return image
    }
    
    var dictionaryRepresentaion: [String: Any] {
        let dictionary = [Constant.userNameKey: username,
                              Constant.userUUIDKey: userID,
                              Constant.emailKey: email,
                              Constant.userImageURL: imageURL ?? ""] as [String : Any]
        return dictionary
    }
}
