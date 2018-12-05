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
    var days: [Day]
    
    init(dateCreated: Date,name: String, totalCompleted: Int, goalUUID: String, selectedDays: String, goalType: Int, userIDRef: String = "", days: [Day] = []) {
        self.name = name
        self.dateCreated = dateCreated
        self.totalCompleted = totalCompleted
        self.goalUUID = goalUUID
        self.selectedDays = selectedDays
        self.goalType = goalType
        self.userIDRef = userIDRef
        self.days = days
    }
    
    init?(dictionary: [String:Any]) {
        guard let name = dictionary[Constant.goalNameKey] as? String,
            let dateCreatedString = dictionary[Constant.goalDateCreatedKey] as? String,
            let totalCompleted = dictionary[Constant.totalCompletedKey] as? Int,
            let goalUUID = dictionary[Constant.goalUUIDKey] as? String,
            let selectedDays = dictionary[Constant.selectedDaysKey] as? String,
            let goalType = dictionary[Constant.goalTypeKey] as? Int,
            let userIDRef = dictionary[Constant.userIDRefKey] as? String else { return nil }
        
        self.name = name
        let dateCreated = DateHelper.convertStringToDate(stringDate: dateCreatedString)
        self.dateCreated = dateCreated
        self.totalCompleted = totalCompleted
        self.goalUUID = goalUUID
        self.selectedDays = selectedDays
        self.goalType = goalType
        self.userIDRef = userIDRef
        self.days = []
    }
}
