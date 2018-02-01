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
    
    @IBOutlet weak var completedGoalButton: UIButton!
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var totalCompletedLabel: UILabel!
    
    var goal: Goal? {
        didSet {
            self.updateView()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
    }
    
    func updateView() {
        guard let goal = self.goal, let daysNSSet = goal.days, let days = Array(daysNSSet) as? [Day] else { return }
        let total = totalCountCompleted(days: days)
        let totalInRow = totalCountCompletedInARow(days: days)
        goalNameLabel.text = goal.name
        totalCompletedLabel.text = "\(total)"
        completedGoalButton.setTitle("\(totalInRow)", for: .normal)
    }
    
    func totalCountCompleted(days: [Day]) -> Int {
        let totalDaysBool = days.flatMap({ $0.completed == 1 })
        let totalTrue = totalDaysBool.filter({ $0 }).count
        return totalTrue
    }
    
    func totalCountCompletedInARow(days: [Day]) -> Int {
        var count = 0
        let orderedDays = days.sorted(by: { $0.date! > $1.date! })
        for day in orderedDays {
            if day.completed == 1 {
                count = count + 1
            } else {
                return count
            }
        }
        return count
    }
    
    func checkForDuplicates(days: [Day]) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.calendar = NSCalendar.current
        let date1String = dateFormatter.string(from: Date())

        for day in days {
            guard let date = day.date else { return false }
            let date2String = dateFormatter.string(from: date)
            if date1String == date2String {
                return true
            }
        }
        return false
    }
    
    @IBAction func positiveButtonTapped(_ sender: Any) {
        guard let goal = self.goal, let daysNSSet = goal.days, let days = Array(daysNSSet) as? [Day] else { return }
        let alreadyHasCurrentDay = checkForDuplicates(days: days)
        if alreadyHasCurrentDay {
            print("Date Already Exists")
            return
        }
        DayController.shared.createDay(withDate: DateHelper.currentDate(), completed: 1, goal: goal)
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
