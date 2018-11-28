//
//  Constants.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation

class Constant {
    
    // Models
    static let User = "User"
    static let Goal = "Goal"
    static let Day = "Day"
    
    // User
    static let firstNameKey = "firstName"
    static let lastNameKey = "lastName"
    static let userUUIDKey = "userUUID"
    
    // Goal
    static let dateCreatedKey = "dateCreated"
    static let goalUUIDKey = "goalUUID"
    static let goalNameKey = "name"
    static let totalCompletedKey = "totalCompleted"
    
    // Day
    
    
    // Cell Identifiers
    static let goalCellIdentifier = "goalCell"
    static let dayCellIdentifier = "dayCell"
    
    // Segue Identifiers
    static let loadingTOloginSegue =  "loadingTOloginSegue"
    static let loadingTOgoalSegue = "loadingTOgoalSegue"
    static let loginTOgoalSegue = "loginTOgoalSegue"
    static let goalTOcreateSegue = "toCreateGoalVC"
    
}
