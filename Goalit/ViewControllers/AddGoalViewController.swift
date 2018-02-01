//
//  AddGoalViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/19/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit

class AddGoalViewController: UIViewController {

    @IBOutlet weak var goalTextField: UITextField!
    
    @IBAction func createGoalButtonTapped(_ sender: Any) {
        guard let goal = goalTextField.text, !goal.isEmpty else { return }
        GoalController.shared.createGoal(withName: goal, dateCreated: DateHelper.currentDate(), totalCompleted: 0)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
