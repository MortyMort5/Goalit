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
    @IBOutlet weak var dateLabel: UILabel!
    weak var delegate: updateDayDelegate?
    
    var day: Day? {
        didSet {
            self.updateView()
        }
    }
    
    func updateView() {
        guard let day = self.day, let dateDate = day.date else { return }
        let date = dayOfWeek(date: dateDate)
        dateLabel.text = date
        if day.completed == 0 {
            dayCompletedButton.layer.backgroundColor = UIColor.red.cgColor
        } else {
            dayCompletedButton.layer.backgroundColor = UIColor.green.cgColor
        }
    }
    
    @IBAction func dayCompletedButtonTapped(_ sender: Any) {
        delegate?.updateDayRecord(sender: self)
    }
    
    func dayOfWeek(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "EEEEEE"
        return dateFormatter.string(from: date).capitalized
    }
    
}

protocol updateDayDelegate: class {
    func updateDayRecord(sender: DayCollectionViewCell)
}
