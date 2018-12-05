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
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    weak var delegate: updateDayDelegate?
    
    var day: Day? {
        didSet {
            self.updateView()
        }
    }
    
    func updateView() {
        guard let day = self.day else { return }
        let dateDate = day.date
        let dateNum = dayOfWeekNumber(date: dateDate)
        let dateLetters = dayOfWeekLetter(date: dateDate)
        dayCompletedButton.setTitle("\(dateNum)", for: .normal)
        dayOfWeekLabel.text = dateLetters
        if day.completed == CompletedGoalForDay.failedToComplete.rawValue {
            dayCompletedButton.layer.backgroundColor = UIColor(red: 255/255, green: 86/255, blue: 106/255, alpha: 1.0).cgColor
        }
        else if day.completed == CompletedGoalForDay.completed.rawValue {
            dayCompletedButton.layer.backgroundColor = UIColor(red: 91/255, green: 214/255, blue: 111/255, alpha: 1.0).cgColor
        } else if day.completed == CompletedGoalForDay.excused.rawValue {
            dayCompletedButton.layer.backgroundColor = UIColor(red: 63/255, green: 130/255, blue: 255/255, alpha: 1.0).cgColor
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
