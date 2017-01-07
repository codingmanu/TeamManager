//
//  LoginViewController.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/25/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /////////////////////////////////////////////////////////////////
        // Sign out every time the app is launched
        /////////////////////////////////////////////////////////////////
        //do{
        //    try FIRAuth.auth()?.signOut()
        //}catch{
        //    handleError(error: error)
        //}
        /////////////////////////////////////////////////////////////////
        
        loginView.layer.cornerRadius = 5.0
        loginBtn.layer.cornerRadius = 3.0
        signUpBtn.layer.cornerRadius = 3.0
        
        emailTF.delegate = self
        
        if FIRAuth.auth()?.currentUser != nil {
            self.performSegue(withIdentifier: "loggedIn", sender: nil)
        }
    }
    
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        FIRAuth.auth()!.signIn(withEmail: emailTF.text!,
                               password: passwordTF.text!) { user, error in
                                if error == nil {
                                    self.performSegue(withIdentifier: "loggedIn", sender: nil)
                                }else{
                                    self.handleError(error: error!)
                                }
        }
        
        
    }
    
    @IBAction func signUpBtnTapped(_ sender: Any) {
        FIRAuth.auth()!.createUser(withEmail: emailTF.text!, password: passwordTF.text!) { user, error in
            if error == nil {
                FIRAuth.auth()!.signIn(withEmail: self.emailTF.text!,
                                       password: self.passwordTF.text!)
                self.performSegue(withIdentifier: "loggedIn", sender: nil)
            }else{
                self.handleError(error: error!)
            }
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loggedIn" {
            if let user = FIRAuth.auth()?.currentUser {
                if let destination =  segue.destination as? TaskListViewController {
                    destination.user = user
                }
            }
        }
    }
    
    //Function to jump to password field after hitting "enter"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTF.resignFirstResponder()
        passwordTF.becomeFirstResponder()
        return true
    }
    
    func handleError(error: Error){
        if let errCode = FIRAuthErrorCode(rawValue: error._code) {
            switch errCode {
            case .errorCodeInvalidEmail:
                self.createAlert(message: "Invalid email")
            case .errorCodeWrongPassword:
                self.createAlert(message: "Wrong password")
            case .errorCodeWeakPassword:
                self.createAlert(message: "Invalid password")
            case .errorCodeEmailAlreadyInUse:
                self.createAlert(message: "User already exists")
            default:
                self.createAlert(message: "Create User Error: \(error)")
            }
        }
    }
    
    func createAlert(message: String){
        let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
}
