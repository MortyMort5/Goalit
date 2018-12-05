//
//  GoalsViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class GoalsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, buttonTappedDelegate, updateDayDelegate {

    @IBOutlet weak var tableView: UITableView!
    var storedOffsets = [Int: CGFloat]()
    var days: [Day] = []
    var goal: Goal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setBackgroundImageWhenTableViewEmpty()
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        signOut()
    }
    
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        print("Signed Out")
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GoalController.shared.goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.goalCellIdentifier, for: indexPath) as? GoalTableViewCell else { return GoalTableViewCell() }
        let goal = GoalController.shared.goals[indexPath.row]
        cell.goal = goal
        guard let daysNSSet = goal.days else { return cell }
        guard let days: [Day] = Array(daysNSSet) as? [Day] else { return cell }
        self.days = days
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let goal = GoalController.shared.goals[indexPath.row]
            GoalController.shared.deleteGoal(withGoal: goal)
            tableView.deleteRows(at: [indexPath], with: .fade)
            setBackgroundImageWhenTableViewEmpty()
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? GoalTableViewCell else { return }
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? GoalTableViewCell else { return }
        storedOffsets[indexPath.row] = cell.collectionViewOffset
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let goal = GoalController.shared.goals[indexPath.row]
        self.goal = goal
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == Constant.goalTOcreateSegue {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let destinationViewController = segue.destination as? CreateGoalViewController else {return}
            let goal = GoalController.shared.goals[indexPath.row]
            destinationViewController.goal = goal
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .delete:
            guard let indexPath = indexPath else { return }
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            tableView.moveRow(at: indexPath, to: newIndexPath)
        case .update:
            guard let indexPath = indexPath else { return }
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
    
    func positiveButtonTapped(sender: GoalTableViewCell) {
        self.tableView.reloadData()
    }
    
    func updateDayRecord(sender: DayCollectionViewCell) {
        guard let day = sender.day else { return }
        DayController.shared.modifyDay(day: day)
        self.tableView.reloadData()
    }
    
    func setBackgroundImageWhenTableViewEmpty() {
        if GoalController.shared.goals.count == 0 {
            let backgroundImage = UIImage(named: "emptyTableView.png")
            let imageView = UIImageView(image: backgroundImage)
            self.tableView.backgroundView = imageView
            imageView.contentMode = .scaleAspectFit
        } else {
            self.tableView.backgroundView = nil
        }
    }
}

extension GoalsViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let days = GoalController.shared.goals[collectionView.tag].days else { return 0 }
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dayCellIdentifier, for: indexPath) as? DayCollectionViewCell else { return UICollectionViewCell() }
//        print(collectionView.tag)
//        print(indexPath)
        cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        let goal = GoalController.shared.goals[collectionView.tag]
        guard let daysNSSet = goal.days else { return cell }
        guard let days: [Day] = Array(daysNSSet) as? [Day] else { return cell }
        let orderedDays = days.sorted(by: { $0.date! > $1.date! })
        cell.day = orderedDays[indexPath.row]
        cell.delegate = self
        return cell
    }
}
