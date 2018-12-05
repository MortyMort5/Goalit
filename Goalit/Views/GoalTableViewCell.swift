//
//  GoalTableViewCell.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit

class GoalTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: buttonTappedDelegate?
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var completedGoalButton: UIButton!
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var totalCompletedLabel: UILabel!
    
    var goal: Goal? {
        didSet {
            self.updateView()
        }
    }
    
    var recentDay: Day?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    func updateView() {
        guard let goal = self.goal else { return }
        let days = goal.days
        let total = totalCountCompleted(days: days)
        let totalInRow = totalCountCompletedInARow(days: days)
        goalNameLabel.text = goal.name
        totalCompletedLabel.text = "\(total)"
        completedGoalButton.setTitle("\(totalInRow.count)", for: .normal)
        monthLabel.text = totalInRow.month
    }
    
    func totalCountCompleted(days: [Day]) -> Int {
        let totalDaysBool = days.compactMap({ $0.completed == CompletedGoalForDay.completed.rawValue })
        let totalTrue = totalDaysBool.filter({ $0 }).count
        return totalTrue
    }
    
    func totalCountCompletedInARow(days: [Day]) -> (count: Int, month: String) {
        var count = 0
        let orderedDays = days.sorted(by: { $0.date > $1.date })
        recentDay = orderedDays.first
        let month = convertDateToStringOfMonth(date: orderedDays.first?.date ?? DateHelper.currentDate())
        for day in orderedDays {
            if day.completed == CompletedGoalForDay.completed.rawValue {
                count = count + 1
            } else if day.completed == CompletedGoalForDay.excused.rawValue {
                
            } else {
                return (count, month)
            }
        }
        return (count, month)
    }
    
    func convertDateToStringOfMonth(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.dateFormat = "LLLL"
        return dateFormatter.string(from: date)
    }
    

    
    @IBAction func positiveButtonTapped(_ sender: Any) {
        guard let day = self.recentDay else { return }
//        DayController.shared.modifyDay(day: day)
        delegate?.positiveButtonTapped(sender: self)
    }
}

extension GoalTableViewCell {
    /*
     Seting the dataSource for the collectionView that is inside each TableViewCell
     */
    func setCollectionViewDataSourceDelegate
        <D: UICollectionViewDataSource & UICollectionViewDelegate>
        (dataSourceDelegate: D, forRow row: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = row
        collectionView.reloadData()
    }
    
    var collectionViewOffset: CGFloat {
        set { collectionView.contentOffset.x = newValue }
        get { return collectionView.contentOffset.x }
    }
}

protocol buttonTappedDelegate: class {
    func positiveButtonTapped(sender: GoalTableViewCell)
}
