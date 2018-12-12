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


    @IBOutlet weak var withoutLoginButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        loadingIndicator.startAnimating()
        disableAllButtons()
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil && user == nil {
                print("Error on logging in \(error!.localizedDescription)")
                self.enableAllButtons()
            }
            if let userID = user?.user.uid {
                UserController.shared.fetchUser(userID: userID, completion: {
                    GoalController.shared.fetchDataForUser {
                        self.loadingIndicator.stopAnimating()
                        self.performSegue(withIdentifier: Constant.loginTOgoalSegue, sender: nil)
                    }
                })
            }
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
    
    func disableAllButtons() {
        withoutLoginButton.isEnabled = false
        loginButton.isEnabled = false
        signUpButton.isEnabled = false
    }
    
    func enableAllButtons() {
        withoutLoginButton.isEnabled = true
        loginButton.isEnabled = true
        signUpButton.isEnabled = true
    }
}
