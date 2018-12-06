//
//  DateHelper.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation

class DateHelper {
    
    static func currentDate() -> Date {
        return Date()
    }
    
    static func dayOfWeekLetter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "EEEEEE"
        return dateFormatter.string(from: date).capitalized
    }
    
    static func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        let myString = formatter.string(from: date)
        return myString
    }
    
    static func convertStringToDate(stringDate: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "MM-dd-yyyy"
        if let date = dateFormatter.date(from: stringDate) {
            return date
        }
        return Date()
    }
    
    static func compareDateWithCurrentDate(date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date1String = dateFormatter.string(from: Date())
        let date2String = dateFormatter.string(from: date)
        if date1String == date2String {
            return true
        }
        return false
    }
    
    static func incrementDateByOne(date: Date) -> Date {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        return tomorrow
    }
}
