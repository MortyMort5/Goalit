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
    static let userNameKey = "username"
    static let emailKey = "email"
    static let userUUIDKey = "userUUID"
    
    // Goal
    static let goalDateCreatedKey = "dateCreated"
    static let goalUUIDKey = "goalUUID"
    static let goalNameKey = "name"
    static let goalDaysKey = "days"
    static let totalCompletedKey = "totalCompleted"
    static let selectedDaysKey = "selectedDays"
    static let goalTypeKey = "goalType"
    static let userIDRefKey = "userIDRef"
    
    // Day
    static let dayCompletedKey = "completed"
    static let dayDateKey = "date"
    static let dayUUIDKey = "dayUUID"
    static let dayGoalIDRefKey = "goalIDRef"
    
    
    // Cell Identifiers
    static let goalCellIdentifier = "goalCell"
    static let dayCellIdentifier = "dayCell"
    
    // Segue Identifiers
    static let loadingTOloginSegue =  "loadingTOloginSegue"
    static let loadingTOgoalSegue = "loadingTOgoalSegue"
    static let loginTOgoalSegue = "loginTOgoalSegue"
    static let goalTOcreateSegue = "toCreateGoalVC"
    static let signUpTOgoalSegue = "signUpToGoals"
    
}
