//
//  GoalsViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import CoreData

class GoalsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, buttonTappedDelegate, updateDayDelegate {

    @IBOutlet weak var tableView: UITableView!
    var storedOffsets = [Int: CGFloat]()
    var days: [Day] = []
    let cellSpacingHeight: CGFloat = 20
    let backgroundView = UIView()
    var addGoalView = UIView()
    let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
    var blurEffectView = UIVisualEffectView()
    let createGoalButton = UIButton()
    let nameTextField = UITextField()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        addGoalView = UIView(frame: CGRect(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2, width: UIScreen.main.bounds.width / 2 + 70, height: UIScreen.main.bounds.height / 2 + 70))
        addGoalView.center = view.center
        
        createGoalButton.addTarget(self, action: #selector(self.createGoalButtonTapped), for: .touchUpInside)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    @IBAction func menuButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        updateViewToAddNewGoal()
    }
    
    @objc func createGoalButtonTapped() {
        guard let name = nameTextField.text, !name.isEmpty else { return }
        GoalController.shared.createGoal(withName: name, dateCreated: DateHelper.currentDate(), totalCompleted: 1)
        nameTextField.text = ""
        self.tableView.reloadData()
        dismissSubViews()
    }
    
    func updateViewToAddNewGoal() {
        createGoalButton.layer.backgroundColor = UIColor.black.cgColor
        createGoalButton.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 110, y: 90, width: 80, height: 40)
//        createGoalButton.frame.size = CGSize(width: 80, height: 40)
//        createGoalButton.center = addGoalView.center
        createGoalButton.setTitle("Create", for: .normal)
        
        nameTextField.frame = CGRect(x: UIScreen.main.bounds.width / 2 - 165, y: 40, width: 200, height: 40)
//        nameTextField.frame.size = CGSize(width: 200, height: 40)
//        nameTextField.center = view.center - 50
//        nameTextField.layer.backgroundColor = UIColor.lightGray.cgColor
        nameTextField.tintColor = UIColor.black
        nameTextField.borderStyle = UITextBorderStyle.none
        nameTextField.layer.borderWidth = 1.0
        nameTextField.layer.borderColor = UIColor.gray.cgColor
        let spacerView = UIView(frame:CGRect(x:0, y:0, width:10, height:10))
        nameTextField.leftViewMode = UITextFieldViewMode.always
        nameTextField.leftView = spacerView
        
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addGoalView.layer.cornerRadius = 5
        addGoalView.layer.backgroundColor = UIColor.white.cgColor
        
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissSubViews))
        blurEffectView.addGestureRecognizer(tap)
        
        self.view.addSubview(blurEffectView)
        self.view.addSubview(addGoalView)
        addGoalView.addSubview(createGoalButton)
        addGoalView.addSubview(nameTextField)
    }
    
    @objc func dismissSubViews() {
        nameTextField.text = ""
        addGoalView.removeFromSuperview()
        blurEffectView.removeFromSuperview()
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
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let goal = GoalController.shared.goals[indexPath.row]
            GoalController.shared.deleteGoal(withGoal: goal)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? GoalTableViewCell else { return }
        cell.setCollectionViewDataSourceDelegate(dataSourceDelegate: self, forRow: indexPath.row)
        cell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? GoalTableViewCell else { return }
        storedOffsets[indexPath.row] = cell.collectionViewOffset
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
    
}

extension GoalsViewController {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dayCellIdentifier, for: indexPath) as? DayCollectionViewCell else { return UICollectionViewCell() }
//        print(collectionView.tag)
//        print(indexPath)
        cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        let orderedDays = self.days.sorted(by: { $0.date! > $1.date! })
        cell.day = orderedDays[indexPath.row]
        cell.delegate = self
        return cell
    }
}
