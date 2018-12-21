//
//  GoalController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

class GoalController {
    
    static let shared = GoalController()
    var ref: DatabaseReference!

    var goals: [Goal] = []
    
    init() {
        loadFromPersistentStorage()
    }

    func createGoal(withName name: String, dateCreated: Date, totalCompleted: Int, goalType: Int, reminderTime: String, selectedDays: String, goalDescription: String, completion:@escaping() -> Void) {
        if Auth.auth().currentUser?.uid == nil {
            createGoalWithoutUser(withName: name,
                                  dateCreated: dateCreated,
                                  totalCompleted: totalCompleted,
                                  goalType: goalType,
                                  reminderTime: reminderTime,
                                  selectedDays: selectedDays,
                                  goalDescription: goalDescription)
            
            completion()
            return
        }
        
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
        
        let goal = Goal(dateCreated: dateCreated, name: name, totalCompleted: totalCompleted, goalUUID: goalNodeKey, selectedDays: selectedDays, goalType: goalType, userIDRef: userID, reminderTime: reminderTime, goalDescription: goalDescription)
        
        goal.days.append(day)
        goal.todayCompleted = true
        self.goals.append(goal)

//        let dayDictionary = day.dictionaryRepresentaion
//        let dayUpdate = [daysNodeKey: dayDictionary]
        
//        let goalDict = createGoalDictionary(goal: goal, day: dayDictionary)
        let goalDict = goal.dictionaryRepresentaion
        
        let childUpdates = ["\(userID)/\(goalNodeKey)": goalDict]

        ref.child("goals").updateChildValues(childUpdates) {
            (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Goal could not be saved: \(error).")
                completion()
            } else {
                print("Goal saved successfully!")
                self.scheduleUserNotification(goal: goal)
                completion()
            }
        }
    }
    
    func createGoalWithoutUser(withName name: String, dateCreated: Date, totalCompleted: Int, goalType: Int, reminderTime: String, selectedDays: String, goalDescription: String) {
        
        let goalUUID = NSUUID().uuidString
        let dayUUID = NSUUID().uuidString
        let goal = Goal(dateCreated: dateCreated,
                        name: name,
                        totalCompleted: totalCompleted,
                        goalUUID: goalUUID,
                        selectedDays: selectedDays,
                        goalType: goalType,
                        reminderTime: reminderTime,
                        goalDescription: goalDescription)
        
        let dayOpt = DayController.shared.createDay(date: dateCreated,
                                                 completed: CompletedGoalForDay.completed.rawValue,
                                                 dayUUID: dayUUID,
                                                 goalIDRef: goalUUID,
                                                 selectedDays: selectedDays)
        
        guard let day = dayOpt else { return }
        goal.days.append(day)
        self.goals.append(goal)
        saveToPersistentStorage()
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
                    Constant.goalDescriptionKey: goal.goalDescription,
                    Constant.goalDaysKey: day] as [String : Any]
        return goal
    }
    
    func modifyGoal(goal: Goal, completion:@escaping() -> Void) {
        guard let goalIndex = self.goals.index(where: {$0.goalUUID == goal.goalUUID }) else { completion(); return }
        self.goals[goalIndex] = goal
        saveToPersistentStorage()
        if Auth.auth().currentUser == nil { completion(); return }
        
        let goalDict = goal.dictionaryRepresentaion
        ref = Database.database().reference()
        ref.child("goals").child(goal.userIDRef).child(goal.goalUUID).updateChildValues(goalDict) {
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
    
    func modifyDay(day: Day, completion:@escaping() -> Void) {
        let goalID = day.goalIDRef
        let dayID = day.dayUUID
        
        if day.completed == CompletedGoalForDay.completed.rawValue {
            day.completed = CompletedGoalForDay.failedToComplete.rawValue
        } else if day.completed == CompletedGoalForDay.failedToComplete.rawValue {
            day.completed = CompletedGoalForDay.completed.rawValue
        }
        
        guard let goalIndex = self.goals.index(where: {$0.goalUUID == goalID }) else { completion(); return }
        guard let dayIndex = self.goals[goalIndex].days.index(where: {$0.dayUUID == dayID }) else { completion(); return }
        self.goals[goalIndex].days[dayIndex] = day
        saveToPersistentStorage()
        
        guard let userID = Auth.auth().currentUser?.uid else { completion(); return }
        
        let dayDict = day.dictionaryRepresentaion
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
                goal.todayCompleted = self.completedGoalForToday(goal: goal)
                goalsTemp.append(goal)
            }
            goalsTemp.sort(by: { !$0.todayCompleted && $1.todayCompleted })
            self.goals = goalsTemp
            print("Fetched user's data successfully")
            completion()
        }) { (error) in
            print("Error fetching EVERYTHING \(error.localizedDescription)")
            completion()
        }
    }
    
    func completedGoalForToday(goal: Goal) -> Bool {
        if goal.days.first?.completed == CompletedGoalForDay.completed.rawValue {
            return true
        } else if goal.days.first?.completed == CompletedGoalForDay.excused.rawValue {
            return true
        } else if goal.days.first?.completed == CompletedGoalForDay.failedToComplete.rawValue {
            return false
        }
        return false
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
    
    func writeAllDataToServer(userID: String, completion:@escaping() -> Void) {
        ref = Database.database().reference()
        for goal in self.goals {
            goal.userIDRef = userID
            
            let goalDict = goal.dictionaryRepresentaion
            let childUpdates = ["\(userID)/\(goal.goalUUID)": goalDict]
            
            ref.child("goals").updateChildValues(childUpdates) {
                (error:Error?, ref:DatabaseReference) in
                if let error = error {
                    print("Goal could not be saved: \(error).")
                    completion()
                } else {
                    print("Goal saved successfully!")
                    self.scheduleUserNotification(goal: goal)
                    completion()
                }
            }
        }
        if self.goals.count == 0 {
            completion()
        }
    }
    
    func deleteGoal(goal: Goal) {
        guard let goalIndex = self.goals.index(where: {$0.goalUUID == goal.goalUUID }) else { return }
        self.goals.remove(at: goalIndex)
        cancelUserNotification(for: goal)
        saveToPersistentStorage()
        if Auth.auth().currentUser == nil { return }
        
        ref = Database.database().reference()
        ref.child("goals").child(goal.userIDRef).child(goal.goalUUID).removeValue()
        print("Deleted Goal")
    }
    
    func createMissingDays(completion:@escaping() -> Void) {
        var incrementedLastDayDate = Date()
        var completedDayOrExcused = 0
        
        goalArr: for goal in self.goals {
            let days = goal.days
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
                    guard let goalIndex = self.goals.index(where: {$0.goalUUID == goalID }) else { completion(); return }
                    self.goals[goalIndex].days.append(contentsOf: daysCreated)
                    self.saveToPersistentStorage()
                    self.writeNewDaysToServer(days: daysCreated, goal: goal)
                    continue goalArr
                }   
            }
        }
        completion()
    }
    
    func writeNewDaysToServer(days: [Day], goal: Goal) {
        if Auth.auth().currentUser == nil { return }
        if goal.userIDRef.count == 0 || goal.goalUUID.count == 0 {
            return
        }
        let dayDictArr = days.flatMap({ $0.dictionaryRepresentaion })
        ref = Database.database().reference().child("goals/\(goal.userIDRef)/\(goal.goalUUID)/days")
        print("Total days to write \(days.count)")
        for day in days {
            let data = day.dictionaryRepresentaion
            let childUpdate = [day.dayUUID: data]
            ref.updateChildValues(childUpdate)
        }
    }
    
    func logoutClearAllPersistedData() {
        UserController.shared.currentUser = nil
        self.goals = []
        saveToPersistentStorage()
    }
}

extension GoalController {
    
    func scheduleUserNotification(goal: Goal) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "hh:mm a"
        guard let reminderDate = dateFormatter.date(from: goal.reminderTime) else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Reminder"
        content.body = "\(goal.name)"
        content.sound = UNNotificationSound.default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: goal.goalUUID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error{
                print("Error scheduling local user notifications \(error.localizedDescription)  :  \(error)")
            }
            print("Saved user notification")
        }
    }
    
    func cancelUserNotification(for goal: Goal){
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [goal.goalUUID])
    }
    
    // MARK: - Persistence
    
    private func fileURL() -> URL {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let fileName = "goal.json"
        let documentsDirectoryURL = urls[0].appendingPathComponent(fileName)
        return documentsDirectoryURL
    }
    
    private func loadFromPersistentStorage() {
        let decoder = JSONDecoder()
        do {
            let data = try Data(contentsOf: fileURL())
            let goals = try decoder.decode([Goal].self, from: data)
            self.goals = goals
        } catch let error {
            print("There was an error saving to persistent storage: \(error)")
        }
    }
    
    private func saveToPersistentStorage() {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(goals)
            try data.write(to: fileURL())
        } catch let error {
            print("There was an error saving to persistent storage: \(error)")
        }
    }
}
