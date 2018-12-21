//
//  GoalsViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import Firebase
import AudioToolbox

class GoalsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, buttonTappedDelegate, updateDayDelegate {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var profileButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    var refreshControl = UIRefreshControl()
    var storedOffsets = [Int: CGFloat]()
    var days: [Day] = []
    var goal: Goal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        GoalController.shared.createMissingDays {
            self.tableView.reloadData()
        }
        
        refreshControl.attributedTitle = NSAttributedString(string: "Refreshing Data")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        tableView.addSubview(refreshControl)
        setUpProfileImageButton()
        
        if let user = Auth.auth().currentUser {
            self.usernameLabel.text = user.displayName
        } else {
            self.usernameLabel.text = "friend"
        }
    }
    
    func setUpProfileImageButton() {
        self.profileButton.layer.masksToBounds = false
        self.profileButton.layer.cornerRadius = self.profileButton.frame.height/2
        self.profileButton.clipsToBounds = true
        
        if Auth.auth().currentUser == nil { return }
        
        self.profileButton.setImage(UserController.shared.currentUser?.profileImage, for: .normal)
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
        if Auth.auth().currentUser == nil {
            guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController else { return }
            self.present(vc, animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: Constant.goalsTOprofileSegue, sender: nil)
        }
    }
    
    @objc func refresh(sender:AnyObject) {
        GoalController.shared.fetchDataForUser {
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
        }
    }
    
    @IBAction func addGoalButtonTapped(_ sender: Any) {
        if Auth.auth().currentUser == nil && GoalController.shared.goals.count == 1 {
            StaticFunction.createAccountAlert(viewController: self)
        } else {
            self.performSegue(withIdentifier: Constant.goalsTOcreateSegue, sender: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GoalController.shared.goals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.goalCellIdentifier, for: indexPath) as? GoalTableViewCell else { return GoalTableViewCell() }
        let goal = GoalController.shared.goals[indexPath.row]
        cell.goal = goal
        self.days = goal.days
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let goal = GoalController.shared.goals[indexPath.row]
            GoalController.shared.deleteGoal(goal: goal)
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
        if segue.identifier == Constant.goalsTOcreateSegue {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            guard let destinationViewController = segue.destination as? CreateGoalViewController else { return }
            let goal = GoalController.shared.goals[indexPath.row]
            destinationViewController.goal = goal
        }
    }
    
    func positiveButtonTapped(sender: GoalTableViewCell) {
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate)) 
        self.tableView.reloadData()
    }
    
    func updateDayRecord(sender: DayCollectionViewCell) {
        guard let day = sender.day else { return }
        GoalController.shared.modifyDay(day: day) {
            self.tableView.reloadData()
        }
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
        let days = GoalController.shared.goals[collectionView.tag].days
        return days.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.dayCellIdentifier, for: indexPath) as? DayCollectionViewCell else { return UICollectionViewCell() }
//        print(collectionView.tag)
//        print(indexPath)
        cell.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        let goal = GoalController.shared.goals[collectionView.tag]
        let days = goal.days
        cell.day = days[indexPath.row]
        cell.delegate = self
        return cell
    }
}
