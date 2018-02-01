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
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        dateComponents.setValue(0, for: .hour)
        dateComponents.setValue(0, for: .minute)
        dateComponents.setValue(0, for: .second)
        
        guard let midnightDate = calendar.date(from: dateComponents) else { return Date() }
        return midnightDate
    }
    
}
