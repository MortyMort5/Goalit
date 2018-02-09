//
//  GoalController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import CoreData

class GoalController {
    
    static let shared = GoalController()

    var goals: [Goal] {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest() // Telling what object to grab fromm the managed object context
        let moc = CoreDataStack.context
        
        do {
            return try moc.fetch(request)
        } catch  {
            return []
        }
    }

    func createGoal(withName name: String, dateCreated: Date, totalCompleted: Int32) {
        guard let user = UserController.shared.currentUser else { return }
        let goal = Goal(dateCreated: dateCreated, name: name, totalCompleted: totalCompleted, user: user, goalUUID: NSUUID().uuidString)
        DayController.shared.createDay(withDate: DateHelper.currentDate(), completed: 1, goal: goal)
        saveToPersistentStore()
    }
    
    func fillMissingDays() {
        let moc = CoreDataStack.context
        let request = NSFetchRequest<Goal>(entityName: "Goal")
        moc.perform {
            do {
                let fetchedGoals: [Goal] = try moc.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Goal]
                var tomorrow = Date()
                goalArr: for goal in fetchedGoals {
                    guard let daysNSSet = goal.days, let days: [Day] = Array(daysNSSet) as? [Day], let date = days.last?.date else { return }
                    tomorrow = date
                    if StaticFunction.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
                    
                    while (true) {
                        tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
                        DayController.shared.createDay(withDate: tomorrow, completed: CompletedGoalForDay.failedToComplete.rawValue, goal: goal)
                        if StaticFunction.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
                    }
                }
            } catch {
                fatalError("Failed to fetch goals: \(error.localizedDescription)")
            }
        }
    }
    
    func modifyGoal(goal: Goal) {
        let moc = CoreDataStack.context
        let request = NSFetchRequest<Goal>(entityName: "Goal")
        request.predicate = NSPredicate(format: "goalUUID like[cd] %@", goal.goalUUID ?? "")
        moc.perform {
            do {
                let fetchedGoals: [Goal] = try moc.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Goal]
                guard let goalFetched: Goal = fetchedGoals.first else { return }
                goalFetched.name = goal.name
                
            } catch {
                fatalError("Failed to fetch goals: \(error.localizedDescription)")
            }
            self.saveToPersistentStore()
        }
    }
    
    func deleteGoal(withGoal goal: Goal) {
        if let moc = goal.managedObjectContext {
            moc.delete(goal)
            saveToPersistentStore()
        }
    }
    
    func saveToPersistentStore() {
        do {
            try CoreDataStack.context.save()
            print("Saved to persistent Store")
        } catch let error {
            NSLog("Error with saving to Core Data: \n\(error)")
        }
    }
}
