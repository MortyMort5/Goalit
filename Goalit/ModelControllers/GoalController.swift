//
//  GoalController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import CoreData
import Firebase

class GoalController {
    
    static let shared = GoalController()
    var ref: DatabaseReference!

    var goals: [Goal] {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest() // Telling what object to grab fromm the managed object context
        let moc = CoreDataStack.context
        do {
            return try moc.fetch(request)
        } catch  {
            return []
        }
    }

    func createGoal(withName name: String, dateCreated: Date, totalCompleted: Int32, goalType: Int32, selectedDays: String) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        ref = Database.database().reference()
        guard let user = UserController.shared.currentUser else { return }
        let dateCreatedString = DateHelper.convertDateToString(date: dateCreated)
        
        guard let key = ref.child("goals").childByAutoId().key else { return }
        let goal = [Constant.userIDRefKey: userID,
                    Constant.goalNameKey: name,
                    Constant.goalDateCreatedKey: dateCreatedString,
                    Constant.goalUUIDKey: key,
                    Constant.totalCompletedKey: totalCompleted,
                    Constant.goalTypeKey: goalType,
                    Constant.selectedDaysKey: selectedDays] as [String : Any]
        let childUpdates = ["\(key)": goal]
        
        ref.child("goals").updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Goal could not be saved: \(error).")
            } else {
                print("Goal saved successfully!")
                let goal = Goal(dateCreated: dateCreated, name: name, totalCompleted: totalCompleted, user: user, goalUUID: key, selectedDays: selectedDays, goalType: goalType)
                if self.checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: DateHelper.currentDate()) {
                    DayController.shared.createDay(withDate: DateHelper.currentDate(), completed: 1, goal: goal)
                }
                self.saveToPersistentStore()
            }
        }
    }
    
    func writeGoalToServer() {
        //MARK: If there is internet create goal on the server
    }
    
    func checkForInternetConnect() -> Bool {
        //MARK: If there is internet return Bool
    return true
    }
    
    func checkSelectedDaysBeforeCreatingDayObject(selectedDays: String, date: Date) -> Bool {
        let daysOfTheWeek = ["Su": 0, "Mo": 1, "Tu": 2, "We": 3, "Th": 4, "Fr": 5, "Sa": 6]
        let today = DateHelper.dayOfWeekLetter(date: date)
        guard let value = daysOfTheWeek[today] else { return false }
        guard let char:Int = Int(selectedDays[value]) else { return false }
        if char == 1 {
            return true
        } else {
            return false
        }
    }
    
    func fillMissingDays() {
        let moc = CoreDataStack.context
        let request = NSFetchRequest<Goal>(entityName: Constant.Goal)
        moc.perform {
            do {
                let fetchedGoals: [Goal] = try moc.fetch(request as! NSFetchRequest<NSFetchRequestResult>) as! [Goal]
                var tomorrow = DateHelper.currentDate()
                goalArr: for goal in fetchedGoals {
                    guard let selectedDays = goal.selectedDays, let dateCreated = goal.dateCreated else { return }
                    guard let daysNSSet = goal.days, let days: [Day] = Array(daysNSSet) as? [Day], let date = days.last?.date else {
                        var changingDateFromGoalCreationDate = dateCreated
                        if StaticFunction.compareDateWithCurrentDate(date: changingDateFromGoalCreationDate) { continue goalArr }
                        while (true) {
                            if self.checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: changingDateFromGoalCreationDate) {
                                DayController.shared.createDay(withDate: changingDateFromGoalCreationDate, completed: CompletedGoalForDay.failedToComplete.rawValue, goal: goal)
                                changingDateFromGoalCreationDate = Calendar.current.date(byAdding: .day, value: 1, to: changingDateFromGoalCreationDate)!
                                if StaticFunction.compareDateWithCurrentDate(date: changingDateFromGoalCreationDate) { continue goalArr }
                            } else {
                                changingDateFromGoalCreationDate = Calendar.current.date(byAdding: .day, value: 1, to: changingDateFromGoalCreationDate)!
                                if StaticFunction.compareDateWithCurrentDate(date: changingDateFromGoalCreationDate) { continue goalArr }
                            }
                        }
                    }
                    tomorrow = date
                    if StaticFunction.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
                    tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
                    while (true) {
                        if self.checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: tomorrow) {
                            if StaticFunction.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
                            DayController.shared.createDay(withDate: tomorrow, completed: CompletedGoalForDay.failedToComplete.rawValue, goal: goal)
                            tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
                        } else {
                            tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
                            if StaticFunction.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
                        }
                    }
                }
            } catch {
                fatalError("Failed to fetch goals: \(error.localizedDescription)")
            }
        }
    }
    
    func modifyGoal(goal: Goal) {
        let moc = CoreDataStack.context
        let request = NSFetchRequest<Goal>(entityName: Constant.Goal)
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

extension String {
    
    var length: Int {
        return count
    }
    
    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }
    
    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }
    
    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }
    
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
}
