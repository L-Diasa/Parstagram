//
//  LoginViewController.swift
//  Instagram
//
//  Created by lika on 3/15/22.
//  Copyright © 2022 lika. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var headsUp: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.isSecureTextEntry = true
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        
        PFUser.logInWithUsername(inBackground: username, password: password) {
            (user, error) in
            if user != nil {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.headsUp.text = "Invalid username or password."
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    
    @IBAction func onSignup(_ sender: Any) {
        let user = PFUser()
        user.username = usernameField.text
        user.password = passwordField.text
        user.signUpInBackground { (success, error) in
            if success {
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            } else {
                self.headsUp.text = "Account already exists for this username"
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
}
