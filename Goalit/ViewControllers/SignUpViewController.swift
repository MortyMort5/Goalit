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
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func createUserButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty, let username = usernameTextField.text, !username.isEmpty, let password = passwordTextField.text, !password.isEmpty else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil && user == nil {
                print("Error on creating User \(error!.localizedDescription)")
            }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            changeRequest?.commitChanges(completion: { (error) in
                if error != nil {
                    print("Error on change request \(error!.localizedDescription)")
                }
                print("Created USER succesfully")
                UserController.shared.createUser(withUsername: username, email: email)
                self.performSegue(withIdentifier: Constant.signUpTOgoalSegue, sender: nil)
            })
        }
    }
}
