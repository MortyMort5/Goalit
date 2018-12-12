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
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.completed, forKey: Constant.dayCompletedKey)
        aCoder.encode(self.date, forKey: Constant.dayDateKey)
        aCoder.encode(self.dayUUID, forKey: Constant.dayUUIDKey)
        aCoder.encode(self.goalIDRef, forKey: Constant.dayGoalIDRefKey)
    }
}
