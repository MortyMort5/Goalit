//
//  StaticFunction.swift
//  Goalit
//
//  Created by Sterling Mortensen on 1/28/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import Foundation
import UIKit

class StaticFunction {
    static func errorAlert(viewController: UIViewController, error: Error) {
        let alertController = UIAlertController(title: "Error", message: "\(error.localizedDescription)", preferredStyle: .alert)
        let travelAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(travelAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func missingFieldAlert(viewController: UIViewController, message: String) {
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    static func createAccountAlert(viewController: UIViewController) {
        let alertController = UIAlertController(title: "Not a User!", message: "Create an account to create more goals.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
}
