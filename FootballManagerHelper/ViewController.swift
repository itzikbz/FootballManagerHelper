//
//  ViewController.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 24/05/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    var user: UserModel?
    
    @IBOutlet weak var greetingsLabel: UILabel!
    @IBOutlet weak var logoutButton: UIButton!
    
    //All options avaiable
    @IBOutlet weak var manageFormationsButton: UIButton!
    @IBOutlet weak var managePlayersButton: UIButton!
    @IBOutlet weak var checkStatusButton: UIButton!
    @IBOutlet weak var changePasswordButton: UIButton!
    
    //Changes password popup view elements
    @IBOutlet var changePasswordView: UIView!
    @IBOutlet weak var newPasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    //Player status popup view elements
    @IBOutlet var playerStatusView: UIView!
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var playerNameLabel: UILabel!
    @IBOutlet weak var yellowCardsLabel: UILabel!
    @IBOutlet weak var redCardsLabel: UILabel!
    @IBOutlet weak var isInSelectedFormationLabel: UILabel!
    
    //Loading popupview 
    @IBOutlet var loadingDataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Sets data for panels and effect
        loadingDataView.layer.cornerRadius = 10
        loadingDataView.layer.borderWidth = 0.5
        changePasswordView.layer.cornerRadius = 10
        changePasswordView.layer.borderWidth = 0.5
        playerStatusView.layer.cornerRadius = 10
        playerStatusView.layer.borderWidth = 0.5
    }
    
    //The verification of the login information is occuring everytime they user is viewing the main screen
    override func viewDidAppear(_ animated: Bool) {
        //Checks if ths user is already logged in by getting userdefaults
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
        if isLoggedIn { //If user is remembered to be logged in - verify it with firebase client
            animateIn(view: loadingDataView)
            let username = UserDefaults.standard.string(forKey: "username")
            let password = UserDefaults.standard.string(forKey: "password")
            FirebaseClient.validUser(username: username, password: password) { (userModel: UserModel?) in
                if userModel != nil { //User avaiable, getting permissions and setting correct data
                    self.user = userModel
                    var definition = "Player"
                    if userModel!.isAdmin {
                        definition = "Manager"
                        self.managePlayersButton.isEnabled = true
                        self.manageFormationsButton.isEnabled = true
                        self.changePasswordButton.isEnabled = true
                        self.checkStatusButton.isEnabled = false
                    } else {
                        self.managePlayersButton.isEnabled = false
                        self.manageFormationsButton.isEnabled = false
                        self.changePasswordButton.isEnabled = true
                        self.checkStatusButton.isEnabled = true
                    }
                    self.greetingsLabel.text = "Hello \(userModel!.username!)(\(definition))"
                    self.greetingsLabel.isHidden = false
                    self.logoutButton.isHidden = false
                    self.animateOut(view: self.loadingDataView)
                } else { //User data might changed, logging out
                    self.logout()
                }
            }
        } else { //If no userdefaults are saved, directing to login screen
            logout()
        }
    }
    
    //Animates a new view
    func animateIn(view: UIView!) {
        self.view.addSubview(view)
        view.center = self.view.center
        view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        view.alpha = 0
        UIView.animate(withDuration: 0.4) {
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        }
    }
    
    //Animates out an existing view
    func animateOut (view: UIView!) {
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            view.alpha = 0
        }) { (success:Bool) in
            view.removeFromSuperview()
        }
    }
    
    //Directing to the login page
    func logout() {
        self.managePlayersButton.isEnabled = false
        self.manageFormationsButton.isEnabled = false
        self.changePasswordButton.isEnabled = false
        self.checkStatusButton.isEnabled = false
        self.greetingsLabel.isHidden = true
        self.logoutButton.isHidden = true
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        self.performSegue(withIdentifier: "loginView", sender: self)
    }
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        logout()
    }
    
    //Change password button action. animates a popout view
    @IBAction func changePasswordButtonAction(_ sender: Any) {
        newPasswordTextField.text = ""
        repeatPasswordTextField.text = ""
        animateIn(view: changePasswordView)
    }
    
    //Done change password button action. Chaning the password in firebase, dismisses the popout view
    @IBAction func doneChangePasswordAction(_ sender: Any) {
        let password = newPasswordTextField.text!
        let repeatPassword = repeatPasswordTextField.text!
        if password != repeatPassword || password.isEmpty {
            let alert = UIAlertController(title: "Error", message: "Passwords must be equal and not empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            user?.password = password
            FirebaseClient.updateUser(model: user)
            UserDefaults.standard.set(password, forKey: "password")
            animateOut(view: changePasswordView)
        }
    }
    
    //Cancel change password button action. dismisses the popout view
    @IBAction func cancelChangePasswordAction(_ sender: Any) {
        animateOut(view: changePasswordView)
    }
    
    
    //Button action for checking player status, getting logged in information from firbase and showing it
    @IBAction func checkStatusButtonAction(_ sender: Any) {
        FirebaseClient.getPlayer(id: user?.playerId!) { (playerModel: PlayerModel) in
            self.playerNameLabel.text = "\(playerModel.first!) \(playerModel.last!) \(playerModel.number!)"
            self.playerNumberLabel.text = "\(playerModel.number!)"
            self.yellowCardsLabel.text = "\(playerModel.yellowCards!)"
            self.redCardsLabel.text = "\(playerModel.suspendedGames!)"
            self.isInSelectedFormationLabel.text = "F"
            FirebaseClient.getSelectedFormation() { (formationModel: FormationModel?) in
                if formationModel != nil{
                    FirebaseClient.getFormationDetails(formationId: formationModel?.id!) { (details: [FormationDetailModel]) in
                        for detail in details {
                            if detail.playerId! == playerModel.id {
                                self.isInSelectedFormationLabel.text = "T"
                                break;
                            }
                        }
                        
                    }
                self.animateIn(view: self.playerStatusView)
            }
        }
    }
    }
    
    @IBAction func cancelPlayerStatusButtonAction(_ sender: Any) {
        animateOut(view: playerStatusView)
    }

}
