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

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var textFieldBackgroundView: UIView!
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        loadingIndicator.startAnimating()
        disableAllButtons()
        guard let email = emailTextField.text, !email.isEmpty, let password = passwordTextField.text, !password.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error on logging in \(error.localizedDescription)")
                self.enableAllButtons()
                self.loadingIndicator.stopAnimating()
                StaticFunction.errorAlert(viewController: self, error: error)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.layer.cornerRadius = Constant.buttonCornerRadius
        textFieldBackgroundView.layer.cornerRadius = Constant.viewCornerRadius
        emailTextField.setLeftPaddingPoints(Constant.paddingLeftAndRight)
        passwordTextField.setLeftPaddingPoints(Constant.paddingLeftAndRight)
        emailTextField.setRightPaddingPoints(Constant.paddingLeftAndRight)
        passwordTextField.setRightPaddingPoints(Constant.paddingLeftAndRight)
        emailTextField.setBottomBorder(withColor: Constant.grayMainColor)
    }
    
    func disableAllButtons() {
        loginButton.isEnabled = false
        signUpButton.isEnabled = false
    }
    
    func enableAllButtons() {
        loginButton.isEnabled = true
        signUpButton.isEnabled = true
    }
}
