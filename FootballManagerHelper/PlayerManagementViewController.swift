//
//  PlayerManagementViewController.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 25/05/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import UIKit

class PlayerManagementViewController: UIViewController {
    
    //index path for the current and previous selcted player item cell
    var previousSelected : IndexPath?
    var currentSelected : Int?
   
    //The player collection view
    @IBOutlet weak var playerCollectionView: UICollectionView!
    var playerModelList = [PlayerModel]() //A list of all players in the team
    
    //Buttons associacted with the main view buttons for adding, viewing and deleting a player
    @IBOutlet weak var addPlayerButton: UIButton!
    @IBOutlet weak var viewPlayerButton: UIButton!
    @IBOutlet weak var deletePlayerUIButton: UIButton!
    
    //Objects associacted with the player panel view
    @IBOutlet var playerPanelView: UIView!
    @IBOutlet weak var firstNameUITextField: UITextField!
    @IBOutlet weak var lastNameUITextField: UITextField!
    @IBOutlet weak var numberUITextField: UITextField!
    @IBOutlet weak var yellowCardsUITextField: UITextField!
    @IBOutlet weak var suspendedGamesUITextField: UITextField!
    @IBOutlet weak var addYellowCardButton: UIButton!
    @IBOutlet weak var addSuspendedGameButton: UIButton!
    @IBOutlet weak var editPlayerUIButton: UIButton!
    @IBOutlet weak var cancelEditButton: UIButton!
    @IBOutlet weak var savePlayerButton: UIButton!
    
    
    //Objects associacted with the new player panel view
    @IBOutlet var newPlayerPanelView: UIView!
    @IBOutlet weak var newPlayerFirstTextField: UITextField!
    @IBOutlet weak var newPlayerLastTextField: UITextField!
    @IBOutlet weak var newPlayerNumberTextField: UITextField!
    @IBOutlet weak var addPlayerPanelButton: UIButton!
    
    //Loading view
    @IBOutlet var loadingDataView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Sets data for panels
        loadingDataView.layer.cornerRadius = 10
        newPlayerPanelView.layer.cornerRadius = 10
        playerPanelView.layer.cornerRadius = 10
        
        //Sets self as the delegate and datasource for the collection view. Extended at the end
        playerCollectionView.delegate = self
        playerCollectionView.dataSource = self
        
        //Animate in loading data view and then loads the initial data
        animateIn(view: loadingDataView)
        FirebaseClient.getAllPlayers { (playerModelList:[PlayerModel])  in
            self.playerModelList = playerModelList
            self.playerCollectionView.reloadData()
            self.animateOut(view: self.loadingDataView)
        }
    }
    
    
    //Animates a new view for adding a player
    @IBAction func addPlayerUIButton(_ sender: Any) {
        currentSelected = nil
        playerCollectionView.reloadData()
        addPlayerButton.isEnabled = false
        newPlayerFirstTextField.text = ""
        newPlayerLastTextField.text = ""
        newPlayerNumberTextField.text = ""
        currentSelected = nil
        animateIn(view: newPlayerPanelView)
    }
    
    //Adds the player and animates out the adding player view
    @IBAction func addPlayerPanelButtonAction(_ sender: Any) {
        let firstName = newPlayerFirstTextField.text
        let lastName = newPlayerLastTextField.text
        let number = newPlayerNumberTextField.text
        if checkInput(firstName: firstName!, lastName: lastName!, newNumber: number!, number: -1) {
            addPlayerButton.isEnabled = false
            firstNameUITextField.text = ""
            lastNameUITextField.text = ""
            numberUITextField.text = ""
            firstNameUITextField.isUserInteractionEnabled = false
            lastNameUITextField.isUserInteractionEnabled = false
            numberUITextField.isUserInteractionEnabled = false
            // Add a new document with a generated ID
            FirebaseClient.addPlayer(firstName: firstName, lastName: lastName, number: Int(number!)) { (playerModel:PlayerModel)  in
                self.playerModelList.append(playerModel)
                self.playerCollectionView.reloadData()
                //Add a user for the player
                FirebaseClient.addUser(username: "\(playerModel.last!)\(playerModel.number!)", password: "\(playerModel.first!)", playerId: playerModel.id, isAdmin: false)
                self.animateOut(view: self.newPlayerPanelView)
            }
            
        }
    }
    
    //Animates out the adding player view
    @IBAction func cancelNewPlayerPanelButtonAction(_ sender: Any) {
        animateOut(view: newPlayerPanelView)
    }
    
    
    //Animates a new view for viewing and editing the player
    @IBAction func viewPlayerButtonAction(_ sender: Any) {
        savePlayerButton.isEnabled = false
        editPlayerUIButton.isEnabled = true
        cancelEditButton.isEnabled = false
        addYellowCardButton.isEnabled = false
        addSuspendedGameButton.isEnabled = false
        animateIn(view: playerPanelView)
        firstNameUITextField.isUserInteractionEnabled = false
        lastNameUITextField.isUserInteractionEnabled = false
        numberUITextField.isUserInteractionEnabled = false
        yellowCardsUITextField.isUserInteractionEnabled = false
        suspendedGamesUITextField.isUserInteractionEnabled = false
        let player = playerModelList[currentSelected!]
        firstNameUITextField.text = player.first
        lastNameUITextField.text = player.last
        numberUITextField.text = "\(player.number!)"
        yellowCardsUITextField.text = "\(player.yellowCards!)"
        suspendedGamesUITextField.text = "\(player.suspendedGames!)"
    }
    
    
    //Allows editing the viewed player
    @IBAction func editPlayerButtonAction(_ sender: Any) {
        addYellowCardButton.isEnabled = true
        addSuspendedGameButton.isEnabled = true
        savePlayerButton.isEnabled = true
        self.editPlayerUIButton.isEnabled = false
        self.cancelEditButton.isEnabled = true
        firstNameUITextField.isUserInteractionEnabled = true
        lastNameUITextField.isUserInteractionEnabled = true
        numberUITextField.isUserInteractionEnabled = true
    }
    
    //Cancel editing the viewed player
    @IBAction func cancelEditButtonAction(_ sender: Any) {
        addYellowCardButton.isEnabled = false
        addSuspendedGameButton.isEnabled = false
        savePlayerButton.isEnabled = false
        savePlayerButton.isEnabled = false
        firstNameUITextField.isUserInteractionEnabled = false
        lastNameUITextField.isUserInteractionEnabled = false
        numberUITextField.isUserInteractionEnabled = false
        self.editPlayerUIButton.isEnabled = true
        self.cancelEditButton.isEnabled = false
        
        let player = playerModelList[currentSelected!]
        firstNameUITextField.text = player.first
        lastNameUITextField.text = player.last
        numberUITextField.text = "\(player.number!)"
        yellowCardsUITextField.text = "\(player.yellowCards!)"
        suspendedGamesUITextField.text = "\(player.suspendedGames!)"
    }
    
    //Add a yellow card to the edited player
    @IBAction func addYellowCardButtonAction(_ sender: Any) {
        let yellowCardsCount = Int(yellowCardsUITextField.text!)
        let suspendedGames = Int(suspendedGamesUITextField.text!)
        if yellowCardsCount! < 4 {
            yellowCardsUITextField.text = "\(yellowCardsCount! + 1)"
        } else {
            suspendedGamesUITextField.text = "\(suspendedGames! + 1)"
            yellowCardsUITextField.text = "0"
        }
    }
    
    //Add a red card/suspended game to the edited player
    @IBAction func addSuspendedGameButtonAction(_ sender: Any) {
        let suspendedGames = Int(suspendedGamesUITextField.text!)
        suspendedGamesUITextField.text = "\(suspendedGames! + 1)"
    }
    
    //Save the edited player
    @IBAction func savePlayerButtonAction(_ sender: Any) {
        let firstName = firstNameUITextField.text
        let lastName = lastNameUITextField.text
        let number = numberUITextField.text
        let yellowCards = yellowCardsUITextField.text
        let suspendedGames = suspendedGamesUITextField.text
        let player = playerModelList[currentSelected!]
        if checkInput(firstName: firstName!, lastName: lastName!, newNumber: number!, number: Int(player.number!)) {
            addYellowCardButton.isEnabled = false
            addSuspendedGameButton.isEnabled = false
            savePlayerButton.isEnabled = false
            savePlayerButton.isEnabled = false
            firstNameUITextField.isUserInteractionEnabled = false
            lastNameUITextField.isUserInteractionEnabled = false
            numberUITextField.isUserInteractionEnabled = false
            self.editPlayerUIButton.isEnabled = true
            self.cancelEditButton.isEnabled = false
            let player = playerModelList[currentSelected!]
            player.first = firstName
            player.last = lastName
            player.number = Int(number!)
            player.yellowCards = Int(yellowCards!)
            player.suspendedGames = Int(suspendedGames!)
            FirebaseClient.updatePlayer(model: player)
            //Change the user name of the player, password stays the same.
            FirebaseClient.getUser(playerId: player.id) { (userModel: UserModel) in
                userModel.username = "\(player.last!)\(player.number!)"
                FirebaseClient.updateUser(model: userModel)
            }
            playerCollectionView.reloadData()
        }
    }
    
    //Animated out the view/edit player view
    @IBAction func cancelPlayerPanelButtonAction(_ sender: Any) {
        animateOut(view: playerPanelView)
    }
    
    //Deleting the selected player
    @IBAction func deletePlayerUIButton(_ sender: Any) {
        deletePlayerUIButton.isEnabled = false
        viewPlayerButton.isEnabled = false
        playerCollectionView.reloadData()
        let playerModel = playerModelList[currentSelected!]
        //Delete player and user documents
        FirebaseClient.deletePlayer(id: playerModel.id)
        FirebaseClient.deleteUser(playerId: playerModel.id)
        playerModelList.remove(at: currentSelected!)
        firstNameUITextField.text = ""
        lastNameUITextField.text = ""
        numberUITextField.text = ""
        currentSelected = nil
    }
    
    //Checks input for editing/adding new player
    func checkInput(firstName: String, lastName: String, newNumber: String, number: Int) -> Bool {
        let error = validInput(firstName: firstName, lastName: lastName,  newNumber: newNumber, number: number)
        if nil != error {
            let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    //Valid input
    func validInput(firstName: String, lastName: String, newNumber: String, number: Int) -> String? {
        if firstName.isEmpty || lastName.isEmpty || newNumber.isEmpty {
            return "Cannot accept empty fields"
        }
        
        let num = Int(newNumber)
        if nil == num || num! < 1 || num! > 99 {
            return "Player Number accept only digits between 1-00"
        }
        if isNumberExist(playerNumber: number, newNumber: num!) {
            return "Player Number already exist"
        }
        
        return nil
    }
    
    //Checks if a new/edited player number already exist in the database
    func isNumberExist(playerNumber: Int, newNumber: Int) -> Bool {
        for player in playerModelList {
            if player.number == newNumber && player.number != playerNumber {
                return true
            }
        }
        return false
    }
    
    //Animates a new view
    func animateIn(view: UIView!) {
        addPlayerButton.isEnabled = false
        viewPlayerButton.isEnabled = false
        deletePlayerUIButton.isEnabled = false
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
        addPlayerButton.isEnabled = true
        if currentSelected != nil {
        viewPlayerButton.isEnabled = true
        deletePlayerUIButton.isEnabled = true
        }
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            view.alpha = 0
        }) { (success:Bool) in
            view.removeFromSuperview()
        }
    }
}


//An extension for implmenting delegate and datasource methods
extension PlayerManagementViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //size of the collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playerModelList.count
    }
    
    //the data of each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = playerCollectionView.dequeueReusableCell(withReuseIdentifier: "PlayerCell", for: indexPath) as! PlayerCollectionViewCell
        let player = playerModelList[indexPath.row]
        cell.setCellData(player: player)
        if currentSelected != nil && currentSelected == indexPath.row
        {
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.blue.cgColor
        } else {
            cell.layer.borderWidth = 0
            cell.layer.borderColor = nil
        }
        return cell
    }
    
    //Method call on cell click
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // For remove previously selection
        if previousSelected != nil{
            if let cell = collectionView.cellForItem(at: previousSelected!){
                cell.layer.borderWidth = 0
                cell.layer.borderColor = nil
            }
        }
        currentSelected = indexPath.row
        previousSelected = indexPath
        
        // For reload the selected cell
        self.playerCollectionView.reloadItems(at: [indexPath])
        self.viewPlayerButton.isEnabled = true
        self.editPlayerUIButton.isEnabled = true
        self.deletePlayerUIButton.isEnabled = true
        
    }
}
