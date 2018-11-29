//
//  LoginViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 2/1/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {


    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil && user == nil {
                print("Error on logging in \(error!.localizedDescription)")
            }
            self.performSegue(withIdentifier: Constant.loginTOgoalSegue, sender: nil)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func continueWithoutLoginButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: Constant.loginTOgoalSegue, sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}
