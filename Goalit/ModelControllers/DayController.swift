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
    
    func createDay(withDate date: Date, completed: Int, goal: Goal, completion:@escaping(Day?) -> Void) {
        ref = Database.database().reference()
        let goalIDRef = goal.goalUUID
        let dateString = DateHelper.convertDateToString(date: date)
        guard let key = ref.child("days").childByAutoId().key else { completion(nil); return }
        let dayDictionary = [Constant.dayDateKey: dateString,
                              Constant.dayCompletedKey: completed,
                              Constant.dayUUIDKey: key,
                              Constant.dayGoalIDRefKey: goalIDRef] as [String : Any]
        
        let childUpdates = ["\(goalIDRef)/\(key)": dayDictionary]

        ref.child("days").updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Day could not be saved: \(error).")
                completion(nil)
            } else {
                print("Day saved successfully!")
                let day = Day(date: date, completed: completed, goal: goal, dayUUID: key)
                completion(day)
            }
        }
    }
    
    func fetchDaysForGoal(goal: Goal, completion:@escaping() -> Void) {
        ref = Database.database().reference()
        let goalID = goal.goalUUID
        var days: [Day] = []
        
        ref.child("days").child(goalID).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let snapshotValues = snapshot.value as? NSDictionary else { completion(); return }
            for snap in snapshotValues {
                guard let dict = snap.value as? [String: Any], let day = Day(dictionary: dict) else { completion(); return }
                days.append(day)
            }
            let orderedDays = days.sorted(by: { $0.date < $1.date })
            GoalController.shared.goals.filter{ $0.goalUUID == goalID }.first?.days = orderedDays
            completion()
        }) { (error) in
            print("Error fetching Days \(error.localizedDescription)")
            completion()
        }
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
