//
//  DayCollectionViewCell.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit

class DayCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var dayCompletedButton: UIButton!
    weak var delegate: updateDayDelegate?
    
    var day: Day? {
        didSet {
            self.updateView()
        }
    }
    
    func updateView() {
        dayCompletedButton.layer.cornerRadius = dayCompletedButton.frame.height/2
        guard let day = self.day else { return }
        if day.completed == CompletedGoalForDay.failedToComplete.rawValue {
            dayCompletedButton.layer.backgroundColor = Constant.failedToCompleteColor
        } else if day.completed == CompletedGoalForDay.completed.rawValue {
            dayCompletedButton.layer.backgroundColor = Constant.completedDayColor
        } else if day.completed == CompletedGoalForDay.excused.rawValue {
            dayCompletedButton.layer.backgroundColor = Constant.excusedColor
        }
    }
    
    @IBAction func dayCompletedButtonTapped(_ sender: Any) {
        delegate?.updateDayRecord(sender: self)
    }
    
    func dayOfWeekNumber(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "d"
        return dateFormatter.string(from: date).capitalized
    }
    
    func dayOfWeekLetter(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "EEEEEE"
        return dateFormatter.string(from: date).capitalized
    }
}

protocol updateDayDelegate: class {
    func updateDayRecord(sender: DayCollectionViewCell)
}
