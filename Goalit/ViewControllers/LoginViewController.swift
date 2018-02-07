//
//  LoginViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 2/1/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBAction func createAccountButtonTapped(_ sender: Any) {
        guard let lastN = lastNameTextField.text, !lastN.isEmpty, let firstN = firstNameTextField.text, !firstN.isEmpty else { return }
        UserController.shared.createUser(withFirstName: firstN, lastName: lastN)
        self.performSegue(withIdentifier: Constant.loginTOgoalSegue, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
