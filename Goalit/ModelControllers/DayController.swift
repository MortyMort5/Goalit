//
//  DayController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import CoreData
import Firebase


class DayController {
    
    static let shared = DayController()
    var ref: DatabaseReference!
    
    func createDay(withDate date: Date, completed: Int32, goal: Goal) {
        ref = Database.database().reference()
        guard let goalIDRef = goal.goalUUID else { return }
        let dateString = DateHelper.convertDateToString(date: date)
        guard let key = ref.child("days").childByAutoId().key else { return }
        let dayDictionary = [Constant.dayDateKey: dateString,
                              Constant.dayCompletedKey: completed,
                              Constant.dayUUIDKey: key,
                              Constant.dayGoalIDRefKey: goalIDRef] as [String : Any]
        let childUpdates = ["\(goalIDRef)/\(key)": dayDictionary]
        
        ref.child("days").updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Day could not be saved: \(error).")
            } else {
                print("Day saved successfully!")
                let _ = Day(date: date, completed: completed, goal: goal, dayUUID: key)
                GoalController.shared.saveToPersistentStore()
            }
        }
    }
    
    func modifyDay(day: Day) {
        let moc = CoreDataStack.context
        let request = NSFetchRequest<Day>(entityName: Constant.Day)
        request.predicate = NSPredicate(format: "dayUUID like[cd] %@", day.dayUUID ?? "")
        moc.perform {
            do {
                let fetchedDays: [Day] = try moc.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Day]
                guard let day: Day = fetchedDays.first else { return }
                if day.completed == CompletedGoalForDay.completed.rawValue {
                    day.completed = CompletedGoalForDay.excused.rawValue
                } else if day.completed == CompletedGoalForDay.excused.rawValue {
                    day.completed = CompletedGoalForDay.failedToComplete.rawValue
                } else if day.completed == CompletedGoalForDay.failedToComplete.rawValue {
                    day.completed = CompletedGoalForDay.completed.rawValue
                } 
            } catch {
                fatalError("Failed to fetch goals: \(error.localizedDescription)")
            }
            GoalController.shared.saveToPersistentStore()
        }
    }
}
