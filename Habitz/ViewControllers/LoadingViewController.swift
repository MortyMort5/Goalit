//
//  LoadingViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 2/1/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import Firebase

class LoadingViewController: UIViewController {

    @IBOutlet weak var loadingImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingImageView.alpha = 0.0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, animations: {
            self.loadingImageView.alpha = 1.0
        }) { (true) in
            if let userID = Auth.auth().currentUser?.uid {
                UserController.shared.fetchUser(userID: userID, completion: {
                    GoalController.shared.fetchDataForUser {
                        GoalController.shared.writeAllDataToServer(userID: userID, completion: {
                            
                            self.performSegue(withIdentifier: Constant.loadingTOgoalSegue, sender: nil)
                        })
                    }
                })
            } else {
                self.performSegue(withIdentifier: Constant.loadingTOgoalSegue, sender: nil)
            }
        }
    }
}
