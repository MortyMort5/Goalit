//
//  LoadingViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 2/1/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit

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
            let hasAccount = UserController.shared.checkIfUserExists()
            if hasAccount {
                self.performSegue(withIdentifier: Constant.loadingTOgoalSegue, sender: nil)
            } else {
                self.performSegue(withIdentifier: Constant.loadingTOloginSegue, sender: nil)
            }
        }
    }
}
