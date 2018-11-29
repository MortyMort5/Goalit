//
//  SignUpViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 11/29/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func createUserButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty, let firstName = firstNameTextField.text, !firstName.isEmpty, let lastName = lastNameTextField.text, !lastName.isEmpty, let password = passwordTextField.text, !password.isEmpty else { return }
                Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                    if error != nil && user == nil {
                        print("Error on creating User \(error!.localizedDescription)")
                    } else {
                        print("Created USER \(String(describing: user))")
                    }
                }
    }
}
