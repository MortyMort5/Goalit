//
//  ProfileViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 12/17/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateView()
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        print("Signed Out")
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    func updateView() {
        let user = UserController.shared.currentUser
        self.emailTextField.text = user?.email
        self.usernameTextField.text = user?.username
        self.profileImageView.image = user?.profileImage
        
        self.emailTextField.backgroundColor = UIColor.clear
        self.emailTextField.borderStyle = .none
        self.emailTextField.isEnabled = false
        self.emailTextField.textAlignment = .center
        
        self.usernameTextField.backgroundColor = UIColor.clear
        self.usernameTextField.borderStyle = .none
        self.usernameTextField.isEnabled = false
        self.usernameTextField.textAlignment = .center
        
        self.profileImageView.layer.masksToBounds = false
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height/2
        self.profileImageView.clipsToBounds = true
    }
}
