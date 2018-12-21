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
    @IBOutlet weak var backButton: UIButton!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
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
                        self.dismiss(animated: true, completion: nil)
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
        backButton.layer.cornerRadius = Constant.buttonCornerRadius
        textFieldBackgroundView.layer.cornerRadius = Constant.viewCornerRadius
        
        emailTextField.setLeftPaddingPoints(Constant.paddingLeftAndRight)
        emailTextField.setRightPaddingPoints(Constant.paddingLeftAndRight)
        emailTextField.setBottomBorder(withColor: Constant.grayMainColor)
        
        passwordTextField.setLeftPaddingPoints(Constant.paddingLeftAndRight)
        passwordTextField.setRightPaddingPoints(Constant.paddingLeftAndRight)
    }
    
    func disableAllButtons() {
        loginButton.isEnabled = false
        signUpButton.isEnabled = false
        backButton.isEnabled = false
    }
    
    func enableAllButtons() {
        backButton.isEnabled = true
        loginButton.isEnabled = true
        signUpButton.isEnabled = true
    }
}
