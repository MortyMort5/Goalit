//
//  GoalController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import Firebase

class GoalController {
    
    static let shared = GoalController()
    var ref: DatabaseReference!

    var goals: [Goal] = []

    func createGoal(withName name: String, dateCreated: Date, totalCompleted: Int, goalType: Int, selectedDays: String, completion:@escaping() -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { completion(); return }
        
        ref = Database.database().reference()
        guard let goalNodeKey = ref.child("goals").childByAutoId().key else { completion(); return }
        guard let daysNodeKey = ref.child("days").childByAutoId().key else { completion(); return }
        
        var optDay: Day?
        if checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: dateCreated) {
            optDay = DayController.shared.createDay(date: dateCreated,
                                                    completed: CompletedGoalForDay.completed.rawValue,
                                                    dayUUID: daysNodeKey,
                                                    goalIDRef: goalNodeKey,
                                                    selectedDays: selectedDays)
        } else {
            optDay = DayController.shared.createDay(date: dateCreated,
                                                    completed: CompletedGoalForDay.excused.rawValue,
                                                    dayUUID: daysNodeKey,
                                                    goalIDRef: goalNodeKey,
                                                    selectedDays: selectedDays)
        }
        
        guard let day = optDay else { completion(); return }
        
        let goal = Goal(dateCreated: dateCreated, name: name, totalCompleted: totalCompleted, goalUUID: goalNodeKey, selectedDays: selectedDays, goalType: goalType)
        
        goal.days.append(day)
        self.goals.append(goal)

        let dayDictionary = DayController.shared.createDayDictionary(day: day)
        let dayUpdate = [daysNodeKey: dayDictionary]
        
        let goalDict = createGoalDictionary(goal: goal, day: dayUpdate)
        
        let childUpdates = ["\(userID)/\(goalNodeKey)": goalDict]

        ref.child("goals").updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Goal could not be saved: \(error).")
                completion()
            } else {
                print("Goal saved successfully!")
                completion()
            }
        }
    }
    
    func createGoalDictionary(goal: Goal, day: [String: Any]) -> [String: Any] {
        let dateCreatedString = DateHelper.convertDateToString(date: goal.dateCreated)
        let goal = [Constant.userIDRefKey: goal.userIDRef,
                    Constant.goalNameKey: goal.name,
                    Constant.goalDateCreatedKey: dateCreatedString,
                    Constant.goalUUIDKey: goal.goalUUID,
                    Constant.totalCompletedKey: goal.totalCompleted,
                    Constant.goalTypeKey: goal.goalType,
                    Constant.selectedDaysKey: goal.selectedDays,
                    Constant.goalDaysKey: day] as [String : Any]
        return goal
    }
    
    func createGoalDictionary(goal: Goal) -> [String: Any] {
        let dateCreatedString = DateHelper.convertDateToString(date: goal.dateCreated)
        let goal = [Constant.userIDRefKey: goal.userIDRef,
                    Constant.goalNameKey: goal.name,
                    Constant.goalDateCreatedKey: dateCreatedString,
                    Constant.goalUUIDKey: goal.goalUUID,
                    Constant.totalCompletedKey: goal.totalCompleted,
                    Constant.goalTypeKey: goal.goalType,
                    Constant.selectedDaysKey: goal.selectedDays] as [String : Any]
        return goal
    }
    
    func modifyGoal(goal: Goal, completion:@escaping() -> Void) {
        let userID = goal.userIDRef
        let goalID = goal.goalUUID
        let goalDict = createGoalDictionary(goal: goal)
        ref.child("goals").child(userID).child(goalID).updateChildValues(goalDict) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Goal could not be saved: \(error).")
                completion()
            } else {
                print("Goal saved successfully!")
                completion()
            }
        }
    }
    
    func fetchDataForUser(completion:@escaping() -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { completion(); return }
        ref = Database.database().reference()
        ref.child("goals").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            print(Thread.isMainThread)
            guard let snapshotValues = snapshot.value as? NSDictionary else { completion(); return }
            for snap in snapshotValues {
                guard let dict = snap.value as? [String: Any],
                        let goal = Goal(dictionary: dict) else { completion(); return }
                
                guard let daysDict = dict[Constant.goalDaysKey] as? [String:[String: Any]] else { return }
                let days = daysDict.values.compactMap({ Day(dictionary: $0) })
                goal.days = days
                self.goals.append(goal)
            }
            print("Fetched user's data successfully")
            completion()
        }) { (error) in
            print("Error fetching EVERYTHING \(error.localizedDescription)")
            completion()
        }
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
    
    func fillMissingDays(completion:@escaping() -> Void) {
        var tomorrow = DateHelper.currentDate()
        
        goalArr: for goal in self.goals {
            let selectedDays = goal.selectedDays
            let dateCreated = goal.dateCreated
            let days = goal.days
            
            guard let date = days.last?.date else {
                var changingDateFromGoalCreationDate = dateCreated
                if DateHelper.compareDateWithCurrentDate(date: changingDateFromGoalCreationDate) { continue goalArr }
                
                while (true) {
                    if self.checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: changingDateFromGoalCreationDate) {
                        DayController.shared.addDayToGoal(goal: goal, dayDate: changingDateFromGoalCreationDate)
                        changingDateFromGoalCreationDate = DateHelper.incrementDateByOne(date: changingDateFromGoalCreationDate)
                        if DateHelper.compareDateWithCurrentDate(date: changingDateFromGoalCreationDate) { continue goalArr }
                    } else {
                        changingDateFromGoalCreationDate = DateHelper.incrementDateByOne(date: changingDateFromGoalCreationDate)
                        if DateHelper.compareDateWithCurrentDate(date: changingDateFromGoalCreationDate) { continue goalArr }
                    }
                }
            }
            tomorrow = date
            if DateHelper.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
            tomorrow = DateHelper.incrementDateByOne(date: tomorrow)
            while (true) {
                if self.checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: tomorrow) {
                    DayController.shared.addDayToGoal(goal: goal, dayDate: tomorrow)
                    if DateHelper.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
                    tomorrow = DateHelper.incrementDateByOne(date: tomorrow)
                } else {
                    tomorrow = DateHelper.incrementDateByOne(date: tomorrow)
                    if DateHelper.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
                }
            }
        }
        completion()
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
