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

    func createGoal(withName name: String, dateCreated: Date, totalCompleted: Int, goalType: Int, reminderTime: String, selectedDays: String, completion:@escaping() -> Void) {
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
        
        let goal = Goal(dateCreated: dateCreated, name: name, totalCompleted: totalCompleted, goalUUID: goalNodeKey, selectedDays: selectedDays, goalType: goalType, userIDRef: userID, reminderTime: reminderTime)
        
        goal.days.append(day)
        self.goals.append(goal)

        let dayDictionary = day.dictionaryRepresentaion
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
                    Constant.goalReminderTimeKey: goal.reminderTime,
                    Constant.goalDaysKey: day] as [String : Any]
        return goal
    }
    
    func modifyGoal(goal: Goal, completion:@escaping() -> Void) {
        let userID = goal.userIDRef
        let goalID = goal.goalUUID
        let goalDict = goal.dictionaryRepresentaion
        ref = Database.database().reference()
        ref.child("goals").child(userID).child(goalID).updateChildValues(goalDict) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Goal could not be saved: \(error.localizedDescription).")
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
        var goalsTemp: [Goal] = []
        ref.child("goals").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            print(Thread.isMainThread)
            guard let snapshotValues = snapshot.value as? NSDictionary else { completion(); return }
            for snap in snapshotValues {
                guard let dict = snap.value as? [String: Any],
                        let goal = Goal(dictionary: dict) else { completion(); return }
                
                guard let daysDict = dict[Constant.goalDaysKey] as? [String:[String: Any]] else { completion(); return }
                var days = daysDict.values.compactMap({ Day(dictionary: $0) })
                days.sort(by: { $0.date > $1.date })
                goal.days = days
                goalsTemp.append(goal)
            }
            self.goals = goalsTemp
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
    
    func deleteGoal(goal: Goal) {
        ref = Database.database().reference()
        ref.child("goals").child(goal.userIDRef).child(goal.goalUUID).removeValue()
        guard let goalIndex = self.goals.index(where: {$0.goalUUID == goal.goalUUID }) else { return }
        self.goals.remove(at: goalIndex)
        print("Deleted Goal")
    }
    
    func createMissingDays(completion:@escaping() -> Void) {
        var incrementedLastDayDate = Date()
        var completedDayOrExcused = 0
        
        goalArr: for goal in self.goals {
            let days = goal.days
            let userID = goal.userIDRef
            var daysCreated: [Day] = []
            let goalID = goal.goalUUID
            let selectedDays = goal.selectedDays
            
            // check if array is empty
            if days.isEmpty {
                incrementedLastDayDate = goal.dateCreated
            } else {
                // the array is sorted when fetched so we need to grab the first one which is the newest
                guard let lastDayDate = days.first?.date else { completion(); return }
                incrementedLastDayDate = lastDayDate
            }
            
            // check to see if the last day.date is equal to today's date
            if DateHelper.compareDateWithCurrentDate(date: incrementedLastDayDate) { continue goalArr } // Yes equals todays date
            
            while (true) {
                // if NO increment the date from the last day.date and create day
                incrementedLastDayDate = DateHelper.incrementDateByOne(date: incrementedLastDayDate)
                
                if self.checkSelectedDaysBeforeCreatingDayObject(selectedDays: selectedDays, date: incrementedLastDayDate) {
                    completedDayOrExcused = CompletedGoalForDay.failedToComplete.rawValue
                } else {
                    completedDayOrExcused = CompletedGoalForDay.excused.rawValue
                }
                
                guard let newDay = DayController.shared.createDay(date: incrementedLastDayDate,
                                                                  completed: completedDayOrExcused,
                                                                  dayUUID: NSUUID().uuidString,
                                                                  goalIDRef: goalID,
                                                                  selectedDays: selectedDays) else { completion(); return }
                
                // then append to daysCreated array
                daysCreated.append(newDay)
                
                // then check again if that date is equal to today's date and go until it does equal todays date
                if DateHelper.compareDateWithCurrentDate(date: incrementedLastDayDate) {
                    // then send up daysCreated to the server
                    guard let goalIndex = self.goals.index(where: {$0.goalUUID == goalID }) else { return }
                    self.goals[goalIndex].days.append(contentsOf: daysCreated)
                    self.writeNewDaysToServer(days: daysCreated, userID: userID, goalID: goalID)
                    continue goalArr
                }   
            }
        }
        completion()
    }
    
    func writeNewDaysToServer(days: [Day], userID: String, goalID: String) {
        ref = Database.database().reference()
        if userID.count == 0 || goalID.count == 0 {
            return
        }
        ref = Database.database().reference().child("goals/\(userID)/\(goalID)/days")
        print("Total days to write \(days.count)")
        for day in days {
            let data = day.dictionaryRepresentaion
            let childUpdate = [day.dayUUID: data]
            ref.updateChildValues(childUpdate)
        }
    }
}
