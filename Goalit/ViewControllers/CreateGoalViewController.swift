//
//  CreateGoalViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 2/20/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit

class CreateGoalViewController: UIViewController {

    @IBOutlet weak var goalNameTextField: UITextField!
    @IBOutlet weak var goalTypeSegment: UISegmentedControl!
    @IBOutlet weak var saturdayButton: UIButton!
    @IBOutlet weak var fridayButton: UIButton!
    @IBOutlet weak var thursdayButton: UIButton!
    @IBOutlet weak var wednesdayButton: UIButton!
    @IBOutlet weak var tuesdayButton: UIButton!
    @IBOutlet weak var mondayButton: UIButton!
    @IBOutlet weak var sundayButton: UIButton!
    @IBOutlet weak var createGoalButton: UIButton!
    
    var goal: Goal?
    var goalType:Int32 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.goalNameTextField.becomeFirstResponder()
    }
    
    @IBAction func goalTypeSegmentAction(_ sender: Any) {
        switch goalTypeSegment.selectedSegmentIndex
        {
        case 0:
            self.goalType = 0
        case 1:
            self.goalType = 1
        default:
            break
        }
    }
    
    @IBAction func saturdayButtonTapped(_ sender: Any) {
    }
    
    @IBAction func fridayButtonTapped(_ sender: Any) {
    }
    
    @IBAction func thursdayButtonTapped(_ sender: Any) {
    }
    
    @IBAction func wednesdayButtonTapped(_ sender: Any) {
    }
    
    @IBAction func tuesdayButtonTapped(_ sender: Any) {
    }
    
    @IBAction func mondayButtonTapped(_ sender: Any) {
    }
    
    @IBAction func sundayButtonTapped(_ sender: Any) {
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createGoalButtonTapped(_ sender: Any) {
        guard let name = goalNameTextField.text, !name.isEmpty else { return }
        if let goal = self.goal {
            goal.name = name
            GoalController.shared.modifyGoal(goal: goal)
            self.navigationController?.popViewController(animated: true)
        } else {
            GoalController.shared.createGoal(withName: name, dateCreated: DateHelper.currentDate(), totalCompleted: 1, goalType: self.goalType)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
