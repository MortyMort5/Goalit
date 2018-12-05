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
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        guard let date = dateFormatter.date(from: stringDate) else { return Date() }
        return date
        
    }
    
}
