//
//  LoginViewController.swift
//  TeamManager
//
//  Created by Manuel S. Gomez on 12/25/16.
//  Copyright © 2016 Manuel S. Gomez. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var signUpBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loginView.layer.cornerRadius = 5.0
        loginBtn.layer.cornerRadius = 3.0
        signUpBtn.layer.cornerRadius = 3.0
        
        emailTF.delegate = self

    }

    @IBAction func loginBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "loggedIn", sender: nil)
        
    }

    @IBAction func signUpBtnTapped(_ sender: Any) {
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "loggedIn" {
//            let destination =  segue.destination as? UIViewController
//        }
//    }
    
    //Function to jump to password field after hitting "enter"
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTF.resignFirstResponder()
        passwordTF.becomeFirstResponder()
        return true
    }

}
