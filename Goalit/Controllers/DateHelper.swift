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
        print("dateComingIN \(date)")
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date1String = dateFormatter.string(from: Date())
        print("current date \(date1String)")
        let date2String = dateFormatter.string(from: date)
        print("dateComingIN but now a string \(date2String)")
        if date1String == date2String {
            return true
        }
        return false
    }
}
