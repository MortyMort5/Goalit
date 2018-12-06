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
        
        let dateCreatedString = DateHelper.convertDateToString(date: dateCreated)

        guard let key = ref.child("goals").childByAutoId().key else { completion(); return }
        
        let goal = [Constant.userIDRefKey: userID,
                    Constant.goalNameKey: name,
                    Constant.goalDateCreatedKey: dateCreatedString,
                    Constant.goalUUIDKey: key,
                    Constant.totalCompletedKey: totalCompleted,
                    Constant.goalTypeKey: goalType,
                    Constant.selectedDaysKey: selectedDays] as [String : Any]
        
        let childUpdates = ["\(userID)/\(key)": goal]

        ref.child("goals").updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Goal could not be saved: \(error).")
                completion()
            } else {
                print("Goal saved successfully!")
                
                let goal = Goal(dateCreated: dateCreated, name: name, totalCompleted: totalCompleted, goalUUID: key, selectedDays: selectedDays, goalType: goalType)
                
                if self.checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: DateHelper.currentDate()) {
                    
                    DayController.shared.createDay(withDate: DateHelper.currentDate(), completed: 1, goal: goal, completion: { (day) in
                        guard let day = day else { completion(); return }
                        goal.days.append(day)
                        self.goals.append(goal)
                        completion()
                    })
                    
                } else {
                    completion()
                }
            }
        }
    }
    
    func fetchAllDataForUser(completion:@escaping() -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else { completion(); return }
        ref = Database.database().reference()
        let group = DispatchGroup()
        ref.child("goals").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            print(Thread.isMainThread)
            guard let snapshotValues = snapshot.value as? NSDictionary else { completion(); return }
            for snap in snapshotValues {
                guard let dict = snap.value as? [String: Any], let goal = Goal(dictionary: dict) else { completion(); return }
                self.goals.append(goal)
                group.enter()
                DayController.shared.fetchDaysForGoal(goal: goal, completion: {
                    group.leave()
                })
            }
            group.notify(queue: .main) {
                completion()
            }
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
        let group = DispatchGroup()
        
        goalArr: for goal in self.goals {
            let selectedDays = goal.selectedDays
            let dateCreated = goal.dateCreated
            let days = goal.days
            
            guard let date = days.last?.date else {
                var changingDateFromGoalCreationDate = dateCreated
                if DateHelper.compareDateWithCurrentDate(date: changingDateFromGoalCreationDate) { continue goalArr }
                
                while (true) {
                    if self.checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: changingDateFromGoalCreationDate) {
                        group.enter()
                        DayController.shared.createDay(withDate: changingDateFromGoalCreationDate, completed: CompletedGoalForDay.failedToComplete.rawValue, goal: goal) { (day) in
                            guard let newDay = day else { completion(); return }
                            let goalID = goal.goalUUID
                            self.goals.filter{ $0.goalUUID == goalID }.first?.days.append(newDay)
                            group.leave()
                        }
                        changingDateFromGoalCreationDate = Calendar.current.date(byAdding: .day, value: 1, to: changingDateFromGoalCreationDate)!
                        if DateHelper.compareDateWithCurrentDate(date: changingDateFromGoalCreationDate) { continue goalArr }
                    } else {
                        changingDateFromGoalCreationDate = Calendar.current.date(byAdding: .day, value: 1, to: changingDateFromGoalCreationDate)!
                        if DateHelper.compareDateWithCurrentDate(date: changingDateFromGoalCreationDate) { continue goalArr }
                    }
                }
            }
            tomorrow = date
            if DateHelper.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
            tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
            while (true) {
                if self.checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: tomorrow) {
                    if DateHelper.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
                    group.enter()
                    DayController.shared.createDay(withDate: tomorrow, completed: CompletedGoalForDay.failedToComplete.rawValue, goal: goal) { (day) in
                        guard let newDay = day else { completion(); return }
                        let goalID = goal.goalUUID
                        self.goals.filter{ $0.goalUUID == goalID }.first?.days.append(newDay)
                        group.leave()
                    }
                    tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
                } else {
                    tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: tomorrow)!
                    if DateHelper.compareDateWithCurrentDate(date: tomorrow) { continue goalArr }
                }
            }
        }
        group.notify(queue: .main) {
            completion()
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
