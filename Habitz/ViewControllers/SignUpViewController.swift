//
//  SignUpViewController.swift
//  Goalit
//
//  Created by Sterling Mortensen on 11/29/18.
//  Copyright © 2018 Sterling Mortensen. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
        
        usernameTextField.setBottomBorder(withColor: Constant.grayMainColor)
        usernameTextField.setLeftPaddingPoints(Constant.paddingLeftAndRight)
        usernameTextField.setRightPaddingPoints(Constant.paddingLeftAndRight)
        
        emailTextField.setLeftPaddingPoints(Constant.paddingLeftAndRight)
        emailTextField.setRightPaddingPoints(Constant.paddingLeftAndRight)
        emailTextField.setBottomBorder(withColor: Constant.grayMainColor)
        
        passwordTextField.setLeftPaddingPoints(Constant.paddingLeftAndRight)
        passwordTextField.setRightPaddingPoints(Constant.paddingLeftAndRight)
        
        textFieldBackgroundView.layer.cornerRadius = Constant.viewCornerRadius
        
        let defaultImage = #imageLiteral(resourceName: "app_profile_icon")
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(tapGestureRecognizer)
        profileImageView.image = defaultImage
        profileImageView.contentMode = .center
        profileImageView.layer.masksToBounds = false
        profileImageView.layer.cornerRadius = profileImageView.frame.height/2
        profileImageView.clipsToBounds = true
        createUserButton.layer.cornerRadius = Constant.buttonCornerRadius
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.addPhotoActionSheet()
    }
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var createUserButton: UIButton!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var textFieldBackgroundView: UIView!
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameTextField {
            textField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        } else if textField == emailTextField {
            textField.resignFirstResponder()
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func disableButtons() {
        loadingIndicator.startAnimating()
        createUserButton.isEnabled = false
        backButton.isEnabled = false
    }
    
    func enableButtons() {
        loadingIndicator.stopAnimating()
        createUserButton.isEnabled = true
        backButton.isEnabled = true
    }
    
    @IBAction func createUserButtonTapped(_ sender: Any) {
        self.disableButtons()
        guard let email = emailTextField.text, !email.isEmpty,
            let username = usernameTextField.text, !username.isEmpty,
            let password = passwordTextField.text, !password.isEmpty else { return }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print("Error on creating User \(error.localizedDescription)")
                self.enableButtons()
                StaticFunction.errorAlert(viewController: self, error: error)
                return
            }
            // Successfully Authorized User
            // Now add username to account
            guard let user = user else { return }
            let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
            changeRequest?.displayName = username
            
            changeRequest?.commitChanges(completion: { (error) in
                if let error = error {
                    print("Error on change request \(error.localizedDescription)")
                    self.createUserButton.isEnabled = true
                    StaticFunction.errorAlert(viewController: self, error: error)
                    return
                }
                // Successfully add username
                // Now save image to storage
                let userID = user.user.uid
                
                let imageDataID = NSUUID().uuidString
                let storageRef = Storage.storage().reference().child("\(imageDataID).png")
                guard let imageData = self.profileImageView.image?.pngData() else { return }
                storageRef.putData(imageData, metadata: nil, completion: { (metaData, error) in
                    if let error = error {
                        print("error uploading image data to storage \(error.localizedDescription)")
                        StaticFunction.errorAlert(viewController: self, error: error)
                        self.enableButtons()
                        return
                    }
                    // Successfully Saved Profile image to Storage
                    // Now download Profile image URL
                    storageRef.downloadURL(completion: { (url, error) in
                        if let error = error {
                            print("Error downloading image url: \(error.localizedDescription)")
                            StaticFunction.errorAlert(viewController: self, error: error)
                            return
                        }
                        // Successfully Downloaded URL
                        // Now Create User in Realtime Database
                        guard let downloadURL = url else { return }
                        UserController.shared.createUser(withUsername: username,
                                                         userID: userID,
                                                         email: email,
                                                         imageURL: downloadURL.absoluteString,
                                                         profileImageData: imageData,
                                                         completion: {
                            // Successfully Saved User to Realtime Database
                            // Now save any goals that were already created
                            GoalController.shared.writeAllDataToServer(userID: userID, completion: {
                                self.loadingIndicator.stopAnimating()
                                self.dismiss(animated: true, completion: nil)
                            })
                        })
                    })
                    
                })
            })
        }
    }
}

extension SignUpViewController {
    
    // Image Picker Functions
    func addPhotoActionSheet() {
        let actionController = UIAlertController(title: "Upload Photo", message: nil, preferredStyle: .actionSheet)
        let uploadAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.uploadButton()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.cameraButton()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)  &&  UIImagePickerController.isSourceTypeAvailable(.camera){
            actionController.addAction(uploadAction)
            actionController.addAction(cameraAction)
        } else if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionController.addAction(cameraAction)
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            actionController.addAction(uploadAction)
        }
        actionController.addAction(cancelAction)
        present(actionController, animated: true, completion: nil)
    }
    
    func uploadButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func cameraButton() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func addPhotoAlert() {
        let alertController = UIAlertController(title: "WARNING!", message: "Must add photo", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel) { (_) in
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        let smallerImage = selectedImage.resizeImage(200.0, opaque: true)
        profileImageView.image = smallerImage
        dismiss(animated: true, completion: nil)
    }
}