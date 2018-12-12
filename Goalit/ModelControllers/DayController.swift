//
//  DayController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import Firebase


class DayController {
    
    static let shared = DayController()
    var ref: DatabaseReference!
    
    func createDayDictionary(day: Day) -> [String:Any] {
        let date = DateHelper.convertDateToString(date: day.date)
        let completed = day.completed
        let goalUUID = day.goalIDRef
        let uuid = day.dayUUID
        let dayDictionary = [Constant.dayDateKey: date,
                             Constant.dayCompletedKey: completed,
                             Constant.dayGoalIDRefKey: goalUUID,
                             Constant.dayUUIDKey: uuid] as [String : Any]
        return dayDictionary
    }
    
    
//    func addDayToGoal(goal: Goal, dayDate: Date) {
//        let userID = goal.userIDRef
//        let goalID = goal.goalUUID
//        let uuid = NSUUID().uuidString
//        let date = DateHelper.convertDateToString(date: dayDate)
//        let dayDictionary = [Constant.dayDateKey: date,
//                             Constant.dayCompletedKey: CompletedGoalForDay.failedToComplete.rawValue,
//                             Constant.dayGoalIDRefKey: goalID,
//                             Constant.dayUUIDKey: uuid] as [String : Any]
//        let childUpdates = [uuid: dayDictionary]
//        ref = Database.database().reference().child("goals/\(userID)/\(goalID)/days")
//        ref.updateChildValues(childUpdates)
//    }
    
    func createDay(date: Date, completed: Int, dayUUID: String, goalIDRef: String, selectedDays: String) -> Day? {
            return Day(date: date, completed: completed, dayUUID: dayUUID, goalIDRef: goalIDRef)
    }
    
    func deleteAllDays() {
        ref = Database.database().reference()
        ref.child("days").removeValue()
    }
    
    func modifyDay(day: Day, completion:@escaping() -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { completion(); return }
        let goalID = day.goalIDRef
        let dayID = day.dayUUID
        
        if day.completed == CompletedGoalForDay.completed.rawValue {
            day.completed = CompletedGoalForDay.failedToComplete.rawValue
        } else if day.completed == CompletedGoalForDay.failedToComplete.rawValue {
            day.completed = CompletedGoalForDay.completed.rawValue
        }
        
        let dayDict = createDayDictionary(day: day)
        ref = Database.database().reference()
        ref.child("goals").child(userID).child(goalID).child("days").child(dayID).updateChildValues(dayDict) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Day could not be Modified: \(error.localizedDescription).")
                completion()
            } else {
                print("Day was modified successfully!")
                completion()
            }
        }
    }
}
