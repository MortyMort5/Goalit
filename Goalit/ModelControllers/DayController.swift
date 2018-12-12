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
        let uuid = NSUUID().uuidString
        let dayDictionary = [Constant.dayDateKey: date,
                             Constant.dayCompletedKey: completed,
                             Constant.dayGoalIDRefKey: goalUUID,
                             Constant.dayUUIDKey: uuid] as [String : Any]
        return dayDictionary
    }
    
    
    func addDayToGoal(goal: Goal, dayDate: Date) {
        let userID = goal.userIDRef
        let goalID = goal.goalUUID
        let uuid = NSUUID().uuidString
        let date = DateHelper.convertDateToString(date: dayDate)
        let dayDictionary = [Constant.dayDateKey: date,
                             Constant.dayCompletedKey: CompletedGoalForDay.failedToComplete.rawValue,
                             Constant.dayGoalIDRefKey: goalID,
                             Constant.dayUUIDKey: uuid] as [String : Any]
        let childUpdates = [uuid: dayDictionary]
        ref = Database.database().reference().child("goals/\(userID)/\(goalID)/days")
        ref.updateChildValues(childUpdates)
    }
    
    func createDay(date: Date, completed: Int, dayUUID: String, goalIDRef: String, selectedDays: String) -> Day? {
            return Day(date: date, completed: completed, dayUUID: dayUUID, goalIDRef: goalIDRef)
    }
    
//    func fetchDaysForGoal(goal: Goal, completion:@escaping() -> Void) {
//        ref = Database.database().reference()
//        let goalID = goal.goalUUID
//        var days: [Day] = []
//
//        ref.child("days").child(goalID).observeSingleEvent(of: .value, with: { (snapshot) in
//            if let snapshotValues = snapshot.value as? NSDictionary {
//                for snap in snapshotValues {
//                    guard let dict = snap.value as? [String: Any], let day = Day(dictionary: dict) else { completion(); return }
//                    days.append(day)
//                }
//                let orderedDays = days.sorted(by: { $0.date < $1.date })
//                GoalController.shared.goals.filter{ $0.goalUUID == goalID }.first?.days = orderedDays
//                completion()
//            } else {
////                GoalController.shared.fillMissingDays {
////                    completion()
////                }
//            }
//
//        }) { (error) in
//            print("Error fetching Days \(error.localizedDescription)")
//            completion()
//        }
//    }
    
    func deleteAllDays() {
        ref = Database.database().reference()
        ref.child("days").removeValue()
            
        
        
    }
    
//    func modifyDay(day: Day) {
//        let moc = CoreDataStack.context
//        let request = NSFetchRequest<Day>(entityName: Constant.Day)
//        request.predicate = NSPredicate(format: "dayUUID like[cd] %@", day.dayUUID ?? "")
//        moc.perform {
//            do {
//                let fetchedDays: [Day] = try moc.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Day]
//                guard let day: Day = fetchedDays.first else { return }
//                if day.completed == CompletedGoalForDay.completed.rawValue {
//                    day.completed = CompletedGoalForDay.excused.rawValue
//                } else if day.completed == CompletedGoalForDay.excused.rawValue {
//                    day.completed = CompletedGoalForDay.failedToComplete.rawValue
//                } else if day.completed == CompletedGoalForDay.failedToComplete.rawValue {
//                    day.completed = CompletedGoalForDay.completed.rawValue
//                }
//            } catch {
//                fatalError("Failed to fetch goals: \(error.localizedDescription)")
//            }
//            GoalController.shared.saveToPersistentStore()
//        }
//    }
}
