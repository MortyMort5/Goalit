//
//  Goal.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import Firebase

class Goal {
    
    var name: String
    let dateCreated: Date
    var goalType: Int
    let goalUUID: String
    var selectedDays: String
    let totalCompleted: Int
    let userIDRef: String
    var reminderTime: String
    var goalDescription: String
    var days: [Day]
    
    init(dateCreated: Date,name: String, totalCompleted: Int, goalUUID: String, selectedDays: String, goalType: Int, userIDRef: String, reminderTime: String, goalDescription: String = "", days: [Day] = []) {
        self.name = name
        self.dateCreated = dateCreated
        self.totalCompleted = totalCompleted
        self.goalUUID = goalUUID
        self.selectedDays = selectedDays
        self.goalType = goalType
        self.userIDRef = userIDRef
        self.reminderTime = reminderTime
        self.goalDescription = goalDescription
        self.days = days
    }
    
    init?(dictionary: [String:Any]) {
        guard let name = dictionary[Constant.goalNameKey] as? String,
            let dateCreatedString = dictionary[Constant.goalDateCreatedKey] as? String,
            let totalCompleted = dictionary[Constant.totalCompletedKey] as? Int,
            let goalUUID = dictionary[Constant.goalUUIDKey] as? String,
            let selectedDays = dictionary[Constant.selectedDaysKey] as? String,
            let goalType = dictionary[Constant.goalTypeKey] as? Int,
            let userIDRef = dictionary[Constant.userIDRefKey] as? String,
            let goalDescription = dictionary[Constant.goalDescriptionKey] as? String,
            let reminderTime = dictionary[Constant.goalReminderTimeKey] as? String else { return nil }
        
        self.name = name
        let dateCreated = DateHelper.convertStringToDate(stringDate: dateCreatedString)
        self.dateCreated = dateCreated
        self.totalCompleted = totalCompleted
        self.goalUUID = goalUUID
        self.selectedDays = selectedDays
        self.goalType = goalType
        self.userIDRef = userIDRef
        self.reminderTime = reminderTime
        self.goalDescription = goalDescription
        self.days = []
    }
    
    var dictionaryRepresentaion: [String: Any] {
        let stringDateCreated = DateHelper.convertDateToString(date: self.dateCreated)
        let dictionary = [Constant.userIDRefKey: self.userIDRef,
                    Constant.goalNameKey: self.name,
                    Constant.goalDateCreatedKey: stringDateCreated,
                    Constant.goalUUIDKey: self.goalUUID,
                    Constant.totalCompletedKey: self.totalCompleted,
                    Constant.goalTypeKey: self.goalType,
                    Constant.goalReminderTimeKey: self.reminderTime,
                    Constant.goalDescriptionKey: self.goalDescription,
                    Constant.selectedDaysKey: self.selectedDays] as [String : Any]
        return dictionary
    }
}
