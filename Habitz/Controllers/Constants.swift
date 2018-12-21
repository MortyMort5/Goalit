//
//  Constants.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit

class Constant {
    
    // Models
    static let User = "User"
    static let Goal = "Goal"
    static let Day = "Day"
    
    // User
    static let userNameKey = "username"
    static let emailKey = "email"
    static let userUUIDKey = "userUUID"
    static let userImageURL = "imageURL"
    
    // Goal
    static let goalDateCreatedKey = "dateCreated"
    static let goalUUIDKey = "goalUUID"
    static let goalNameKey = "name"
    static let goalDaysKey = "days"
    static let totalCompletedKey = "totalCompleted"
    static let selectedDaysKey = "selectedDays"
    static let goalTypeKey = "goalType"
    static let userIDRefKey = "userIDRef"
    static let goalReminderTimeKey = "reminderTime"
    static let goalDescriptionKey = "description"
    
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
    static let signUpTOgoalSegue = "signUpToGoals"
    static let goalsTOprofileSegue = "goalsToProfileSegue"
    static let goalsTOcreateSegue = "goalsToCreateGoalSegue"
    
    // Buttons
    static let buttonCornerRadius: CGFloat = 15
    
    // Main Colors
    static let grayMainColor: UIColor = UIColor(red: 88/255,
                                                green: 89/255,
                                                blue: 91/255,
                                                alpha: 1.0)
    
    static let lightBlueMainColor: UIColor = UIColor(red: 225/255,
                                                     green: 235/255,
                                                     blue: 232/255,
                                                     alpha: 1.0)
    
    static let blueMainColor: UIColor = UIColor(red: 58/255,
                                                green: 121/255,
                                                blue: 166/255,
                                                alpha: 1.0)
    
    static let yellowMainColor: UIColor = UIColor(red: 253/255,
                                                  green: 216/255,
                                                  blue: 92/255,
                                                  alpha: 1.0)
    
    // View Around TextFields
    static let viewCornerRadius: CGFloat = 10
    
    // Text Fields
    static let paddingLeftAndRight: CGFloat = 20
    
    // Day Collection View Cell Colors
    static let completedDayColor: CGColor = UIColor(red: 253/255,
                                                    green: 216/255,
                                                    blue: 92/255,
                                                    alpha: 1.0).cgColor
    
    static let failedToCompleteColor: CGColor = UIColor(red: 88/255,
                                                        green: 89/255,
                                                        blue: 91/255,
                                                        alpha: 1.0).cgColor
    
    static let excusedColor: CGColor = UIColor(red: 253/255,
                                               green: 216/255,
                                               blue: 92/255,
                                               alpha: 1.0).cgColor
}
