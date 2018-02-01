//
//  StaticFunction.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/28/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation

class StaticFunction {
    static func compareDateWithCurrentDate(date: Date) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = NSCalendar.current
        let date1String = dateFormatter.string(from: Date())
        let date2String = dateFormatter.string(from: date)
        if date1String == date2String {
            return true
        }
        return false
    }
}
