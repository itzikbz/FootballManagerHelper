//
//  LoginViewController.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 08/06/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import UIKit
import Foundation

class LoginViewController: UIViewController {

    let userDefault = UserDefaults.standard
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Checks input for editing/adding new player
    func checkInput(username: String, password: String) -> Bool {
        let error = validInput(username: username, password: password)
        if nil != error {
            showAlert(message: error!)
            return false
        }
        return true
    }
    
    //Valid input
    func validInput(username: String, password: String) -> String? {
        if username.isEmpty || password.isEmpty {
            return "Cannot accept empty fields"
        }
        return nil
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    //Valids the login information with the firebase client
    @IBAction func loginButtonAction(_ sender: Any) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        if checkInput(username: username, password: password) {
            FirebaseClient.validUser(username: username, password: password) { (userModel: UserModel?) in
                //if user-password combination does not exist
                if userModel == nil {
                    self.showAlert(message: "Username or Password are incorrect")
                } else { //if the information is valid - sets the userdefaults and dismisses the view
                    UserDefaults.standard.set(true, forKey: "isLoggedIn")
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(password, forKey: "password")
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}
