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
    
    @IBOutlet weak var createUserButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createUserButtonTapped(_ sender: Any) {
        loadingIndicator.startAnimating()
        createUserButton.isEnabled = false
        guard let email = emailTextField.text, !email.isEmpty, let username = usernameTextField.text, !username.isEmpty, let password = passwordTextField.text, !password.isEmpty else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error on creating User \(error.localizedDescription)")
                self.createUserButton.isEnabled = true
                self.loadingIndicator.stopAnimating()
                StaticFunction.errorAlert(viewController: self, error: error)
            }
            guard let user = user else { return }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print("Error on change request \(error.localizedDescription)")
                    self.createUserButton.isEnabled = true
                    StaticFunction.errorAlert(viewController: self, error: error)
                }
                print("Created USER succesfully")
                let userID = user.user.uid
                UserController.shared.createUser(withUsername: username, userID: userID, completion: {
                    self.loadingIndicator.stopAnimating()
                    self.performSegue(withIdentifier: Constant.signUpTOgoalSegue, sender: nil)
                })
            })
        }
    }
}
