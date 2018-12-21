//
//  Day.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation

class Day: Codable {
    
    var completed: Int
    let date: Date
    let dayUUID: String
    let goalIDRef: String
    
    init(date: Date, completed: Int = 0, dayUUID: String, goalIDRef: String = "") {
        self.date = date
        self.completed = completed
        self.dayUUID = dayUUID
        self.goalIDRef = goalIDRef
    }
    
    init?(dictionary: [String:Any]) {
        guard let completed = dictionary[Constant.dayCompletedKey] as? Int,
            let dateString = dictionary[Constant.dayDateKey] as? String,
            let dayUUID = dictionary[Constant.dayUUIDKey] as? String,
            let goalIDRef = dictionary[Constant.dayGoalIDRefKey] as? String else { return nil }
        
        self.completed = completed
        let date = DateHelper.convertStringToDate(stringDate: dateString)
        self.date = date
        self.dayUUID = dayUUID
        self.goalIDRef = goalIDRef
    }
    
    var dictionaryRepresentaion: [String:[String: Any]] {
        let stringDate = DateHelper.convertDateToString(date: self.date)
        let dictionary: [String:[String: Any]] = [self.dayUUID:[
            Constant.dayCompletedKey: self.completed,
            Constant.dayDateKey: stringDate,
            Constant.dayUUIDKey: self.dayUUID,
            Constant.dayGoalIDRefKey: self.goalIDRef
        ]]
        return dictionary
    }
    
    // MARK: - PUT
    // Turn or serialize dictionaryRep into data
    // Returns JSON data from our object - to go up to Firebase. Firebase is JSON!!!
    
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: dictionaryRepresentaion, options: .prettyPrinted)
    }
    
}
