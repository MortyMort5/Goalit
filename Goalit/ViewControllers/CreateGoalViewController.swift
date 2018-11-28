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
    
    var goal: Goal? {
        didSet {
            DispatchQueue.main.async {
                self.updateViews()
            }
        }
    }
    var goalType:Int32 = 0
    var selectedDays:String = "1111111";
    var sunday = 1
    var monday = 1
    var tuesday = 1
    var wednesday = 1
    var thursday = 1
    var friday = 1
    var saturday = 1
    let selectedColor:UIColor = UIColor.green
    let unselectedColor:UIColor = UIColor.red
    
    func updateViews() {
        guard let name = goal?.name, let selectedDays = goal?.selectedDays else { return }
        let daysSelectedArray: [UIButton] = [sundayButton, mondayButton, tuesdayButton, wednesdayButton, thursdayButton, fridayButton, saturdayButton]
        goalNameTextField.text = name
        var counter = 0
        for day in selectedDays {
            if day == "1" {
                let buttonTapped = daysSelectedArray[counter]
                buttonTapped.backgroundColor = selectedColor
            } else {
                let buttonTapped = daysSelectedArray[counter]
                buttonTapped.backgroundColor = unselectedColor
            }
            counter = counter + 1
        }
    }
    
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
    
    @IBAction func sundayButtonTapped(_ sender: Any) {
        sunday = sunday != 1 ? 1 : 0
        if sunday == 1 {
            sundayButton.backgroundColor = selectedColor
        } else {
            sundayButton.backgroundColor = unselectedColor
        }
    }
    
    @IBAction func mondayButtonTapped(_ sender: Any) {
        monday = monday != 1 ? 1 : 0
        if monday == 1 {
            mondayButton.backgroundColor = selectedColor
        } else {
            mondayButton.backgroundColor = unselectedColor
        }
    }
    
    @IBAction func tuesdayButtonTapped(_ sender: Any) {
        tuesday = tuesday != 1 ? 1 : 0
        if tuesday == 1 {
            tuesdayButton.backgroundColor = selectedColor
        } else {
            tuesdayButton.backgroundColor = unselectedColor
        }
    }
    
    @IBAction func wednesdayButtonTapped(_ sender: Any) {
        wednesday = wednesday != 1 ? 1 : 0
        if wednesday == 1 {
            wednesdayButton.backgroundColor = selectedColor
        } else {
            wednesdayButton.backgroundColor = unselectedColor
        }
    }
    
    @IBAction func thursdayButtonTapped(_ sender: Any) {
        thursday = thursday != 1 ? 1 : 0
        if thursday == 1 {
            thursdayButton.backgroundColor = selectedColor
        } else {
            thursdayButton.backgroundColor = unselectedColor
        }
    }
    
    @IBAction func fridayButtonTapped(_ sender: Any) {
        friday = friday != 1 ? 1 : 0
        if friday == 1 {
            fridayButton.backgroundColor = selectedColor
        } else {
            fridayButton.backgroundColor = unselectedColor
        }
    }
    
    @IBAction func saturdayButtonTapped(_ sender: Any) {
        saturday = saturday != 1 ? 1 : 0
        if saturday == 1 {
            saturdayButton.backgroundColor = selectedColor
        } else {
            saturdayButton.backgroundColor = unselectedColor
        }
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createGoalButtonTapped(_ sender: Any) {
        self.selectedDays = convertSelectedDaysToString()
        guard let name = goalNameTextField.text, !name.isEmpty else { self.missingFieldAlert(); return }
        if let goal = self.goal {
            goal.name = name
            GoalController.shared.modifyGoal(goal: goal)
            self.navigationController?.popViewController(animated: true)
        } else {
            GoalController.shared.createGoal(withName: name, dateCreated: DateHelper.currentDate(), totalCompleted: 1, goalType: self.goalType, selectedDays: self.selectedDays)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func convertSelectedDaysToString() -> String {
         return "\(sunday)\(monday)\(tuesday)\(wednesday)\(thursday)\(friday)\(saturday)"
    }
    
    func missingFieldAlert() {
        let alertController = UIAlertController(title: "Must enter a name.", message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
