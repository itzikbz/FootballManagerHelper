//
//  PlayerFormationViewController.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 27/05/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import UIKit

class PlayerFormationViewController: UIViewController {
    
    //Player formation collection view objects
    @IBOutlet weak var playerFormationCollectionView: UICollectionView!
    var size = 56
    var rowSize = 7
    var keeper_position = 4
    var maximum_players = 11
    var selectedPlayerIndex: Int?
    var selectedFormation: FormationModel?
    var selectedFormationDetail = [FormationDetailModel]()
    
    var allPlayers = [PlayerModel]()
    var playersInFormation = [PlayerModel]()
    var playersOutOfFormation = [PlayerModel]()
    var allFormations = [FormationModel]()
    
    @IBOutlet weak var addFormationButton: UIButton!
    @IBOutlet weak var selectFormationButton: UIButton!
    @IBOutlet weak var deleteFormationButton: UIButton!
    @IBOutlet weak var formationNameLabel: UILabel!
    
    //Views and objects associated with them
    @IBOutlet var addFormationView: UIView!
    @IBOutlet weak var formationNameTextField: UITextField!
    
    @IBOutlet var selectFormationView: UIView!
    @IBOutlet weak var formationPickerView: UIPickerView!
    var formationPickerData = [String]()
    
    @IBOutlet var deleteFormationView: UIView!
    
    @IBOutlet var addPlayerToFormationView: UIView!
    @IBOutlet weak var playerPickerView: UIPickerView!
    var playerPickerData = [String]()
    
    @IBOutlet var deletePlayerView: UIView!
    
    @IBOutlet weak var setPrimaryButton: UIButton!
    
    @IBOutlet var loadingDataView: UIView!
    
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    var effect: UIVisualEffect!

    override func viewDidLoad() {
        super.viewDidLoad()
        //Getting and setting initial data
        animateIn(view: loadingDataView)
        FirebaseClient.getAllPlayers() { (playerList: [PlayerModel]) in
            self.allPlayers = playerList
            FirebaseClient.getAllFormations() { (formationList: [FormationModel]) in
                self.allFormations = formationList
                self.setCurrentFormation(formation: self.selectedFormation, fadeOutView: self.loadingDataView)
            }
        }
        
        playerFormationCollectionView.delegate = self
        playerFormationCollectionView.dataSource = self
        playerPickerView?.delegate = self
        playerPickerView?.dataSource = self
        visualEffectView.effect = nil
        addFormationView.layer.cornerRadius = 10
        addPlayerToFormationView.layer.cornerRadius = 10
        selectFormationView.layer.cornerRadius = 10
        deletePlayerView.layer.cornerRadius = 10
        deleteFormationView.layer.cornerRadius = 10
        loadingDataView.layer.cornerRadius = 10
        loadingDataView.layer.cornerRadius = 10
    }
    
    //Sets the current formation drived by the selected formation
    func setCurrentFormation(formation: FormationModel?, fadeOutView: UIView?) {
        if (allFormations.count) > 0 {
            if formation == nil {
                selectedFormation = allFormations[0]
            } else {
                selectedFormation = formation
            }
      
            if selectedFormation!.isSelected { //Check if the current formation is the primaty one
                formationNameLabel.text = selectedFormation!.name! + "(Primary)"
            } else {
                formationNameLabel.text = selectedFormation!.name!
            }
            
            //Get the formation details(players and their positions) from the selected formation
            FirebaseClient.getFormationDetails(formationId: selectedFormation?.id) { (formationDetailList: [FormationDetailModel]) in
                self.selectedFormationDetail = formationDetailList
                
                //Reset the players lists and setting them over again
                self.playersInFormation.removeAll()
                self.playersOutOfFormation.removeAll()
                for detail in formationDetailList {
                    self.playersInFormation.append(self.getPlayerByDetail(detail: detail)!)
                }
    
                for player in self.allPlayers {
                    var exist: Bool = false
                    for formationPlayer in self.playersInFormation {
                        if player.id == formationPlayer.id {
                            exist = true
                            break
                        }
                    }
                    if !exist {
                        self.playersOutOfFormation.append(player)
                    }
                    exist = false
                }
                self.formationNameLabel.isHidden = false
                self.playerFormationCollectionView.isHidden = false
                self.setPrimaryButton.isEnabled = true
                self.playerFormationCollectionView.reloadData()
                if fadeOutView != nil {
                    self.animateOut(view: fadeOutView)
                }
            }
        } else { //No formations avaiable
            selectedFormation = nil
            formationNameLabel.isHidden = true
            playerFormationCollectionView.isHidden = true
            setPrimaryButton.isEnabled = false
            playersInFormation.removeAll()
            playerFormationCollectionView.reloadData()
            
            if fadeOutView != nil {
                self.animateOut(view: fadeOutView)
            }
        }
    }
    
    //Add Formation View Button Actions
    @IBAction func addFormationButtonAction(_ sender: Any) {
        formationNameTextField.text = ""
        animateIn(view: addFormationView)
    }
    
    @IBAction func addFormationViewButonAction(_ sender: Any) {
        if formationNameTextField.text == "" {
            showAlert(message: "Formation name must not be empty")
            return
        }
        FirebaseClient.addFormation(name: formationNameTextField.text) { (formation: FormationModel) in
            self.selectedFormation = formation
            self.allFormations.append(formation)
            self.setCurrentFormation(formation: self.selectedFormation, fadeOutView: self.addFormationView)
        }
    }
    
    @IBAction func cancelAddFormationViewButtonAction(_ sender: Any) {
        animateOut(view: addFormationView)
    }
    
    //Select Formation View Button Actions
    @IBAction func selectFormationButtonAction(_ sender: Any) {
        var formationNameList = [String]()
        if allFormations != nil {
            for formation in allFormations {
                formationNameList.append(formation.name!)
            }
        }
        formationPickerData = formationNameList
        formationPickerView?.delegate = self
        formationPickerView?.dataSource = self
        animateIn(view: selectFormationView)
    }
    
    @IBAction func selectFormationViewButtonAction(_ sender: Any) {
        for formation in allFormations {
            if formation.name == formationPickerData[formationPickerView!.selectedRow(inComponent: 0)] {
                selectedFormation = formation
            }
        }
        setCurrentFormation(formation: selectedFormation, fadeOutView: selectFormationView)
    }
    
    @IBAction func cancelChooseFormationViewButtonAction(_ sender: Any) {
        animateOut(view: selectFormationView)
    }
    
    //Delete Formation View Button Actions
    @IBAction func deleteFormationButtonAction(_ sender: Any) {
        animateIn(view: deleteFormationView)
    }
    
    @IBAction func deleteFormationViewButtonAction(_ sender: Any) {
        FirebaseClient.deleteFormation(id: selectedFormation?.id!)
        for i in 0..<allFormations.count {
            if allFormations[i].id == selectedFormation?.id {
                allFormations.remove(at: i)
                break
            }
        }
        self.setCurrentFormation(formation: nil, fadeOutView: deleteFormationView)
    }
    
    @IBAction func cancelDeleteFormationViewButtonAction(_ sender: Any) {
        animateOut(view: deleteFormationView)
    }
    
    //Set primary formation button action
    @IBAction func setPrimaryButtonAction(_ sender: Any) {
        if playersInFormation.count != 11 {
            showAlert(message: "A formation must include 11 players");
            return
        }
        for player in playersInFormation {
            if player.suspendedGames! > 0 {
                showAlert(message: "Player number \(player.number!) is suspended and can't play the next game");
                return
            }
        }
        animateIn(view: loadingDataView)
        FirebaseClient.getSelectedFormation() { (primaryFormation: FormationModel?) in
            if primaryFormation != nil {
                for formation in self.allFormations {
                    if formation.id == primaryFormation?.id {
                        formation.isSelected = false
                        FirebaseClient.updateFormation(model: formation)
                    }
                }
            }
            self.selectedFormation?.isSelected = true
            FirebaseClient.updateFormation(model: self.selectedFormation)
            self.setCurrentFormation(formation: self.selectedFormation, fadeOutView: self.loadingDataView)
            
            for player in self.allPlayers {
                if player.suspendedGames! > 0 {
                    player.suspendedGames! = player.suspendedGames! - 1
                    FirebaseClient.updatePlayer(model: player)
                }
            }
        }
    }
    
    //Add player to formation button actions
    @IBAction func addPlayerViewButonAction(_ sender: Any) {
        let player = playersOutOfFormation[playerPickerView!.selectedRow(inComponent: 0)]
        FirebaseClient.addFormationDetail(formationId: selectedFormation?.id , playerId: player.id, playerPosition: selectedPlayerIndex) { (detail: FormationDetailModel) in
            self.selectedFormationDetail.append(detail)
            self.playersOutOfFormation.remove(at: self.playerPickerView!.selectedRow(inComponent: 0))
            self.playersInFormation.append(player)
            self.playerFormationCollectionView.reloadData()
            self.animateOut(view: self.addPlayerToFormationView)
        }
    }
    
    @IBAction func cancelPlayerViewButtonAction(_ sender: Any) {
        animateOut(view: addPlayerToFormationView)
    }
    
    //Delete player from formation button actions
    @IBAction func deletePlayerViewButtonAction(_ sender: Any) {
        var deletedDetail =  getDetailInPosition(position: selectedPlayerIndex!)
        let player = getPlayerByDetail(detail: deletedDetail)
        playersOutOfFormation.append(player!)
        for i in 0..<playersInFormation.count {
            if playersInFormation[i].id == player!.id {
                playersInFormation.remove(at: i)
                break
            }
        }
        
        FirebaseClient.deleteFormationDetails(id:  getDetailInPosition(position: selectedPlayerIndex!)?.id)
        for i in 0..<selectedFormationDetail.count {
            if selectedFormationDetail[i].id == deletedDetail?.id {
                selectedFormationDetail.remove(at: i)
                break
            }
        }
        
        playerFormationCollectionView.reloadData()
        animateOut(view: deletePlayerView)
    }
    
    @IBAction func cancelDeletePlayerViewButtonAction(_ sender: Any) {
        animateOut(view: deletePlayerView)
    }
    
    func getPlayerByDetail(detail: FormationDetailModel?) -> PlayerModel? {
        var player: PlayerModel?
        if detail == nil {
            return player
        }
        for playerNode in allPlayers {
            if playerNode.id == detail!.playerId {
                player = playerNode
            }
        }
        return player
    }
    
    func getDetailInPosition(position: Int) -> FormationDetailModel? {
        for detail in selectedFormationDetail {
            if detail.playerPosition == position {
                return detail
            }
        }
        return nil
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func animateIn(view: UIView!) {
        self.view.addSubview(view)
        addFormationButton.isEnabled = false
        selectFormationButton.isEnabled = false
        deleteFormationButton.isEnabled = false
        setPrimaryButton.isEnabled = false
        view.center = self.view.center
        
        view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        view.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.visualEffectView.effect = self.effect
            view.alpha = 1
            view.transform = CGAffineTransform.identity
        }
    }
    
    func animateOut (view: UIView!) {
        addFormationButton.isEnabled = true
        if selectedFormation != nil {
        selectFormationButton.isEnabled = true
        deleteFormationButton.isEnabled = true
            setPrimaryButton.isEnabled = true
        }
        UIView.animate(withDuration: 0.3, animations: {
            view.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            view.alpha = 0
            
            self.visualEffectView.effect = nil
            
        }) { (success:Bool) in
            view.removeFromSuperview()
        }
    }
}

//An extension for implmenting delegate and datasource methods
extension PlayerFormationViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //size of the collection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return size
    }
    
    //the data of each cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = playerFormationCollectionView.dequeueReusableCell(withReuseIdentifier: "PositionCell", for: indexPath) as! PositionCollectionViewCell
        if selectedFormation != nil {
            let detail = getDetailInPosition(position: indexPath.row)
            cell.setCellData(player: getPlayerByDetail(detail: detail))
        }
        return cell
    }
    
    //Method call on cell click
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedPlayerIndex = indexPath.row
        let cell = playerFormationCollectionView.cellForItem(at: indexPath) as! PositionCollectionViewCell
        if cell.player != nil {
            animateIn(view: deletePlayerView)
            return
        }
        
        if selectedFormationDetail.count == maximum_players {
            showAlert(message: "Can't add more than 11 players to a formation")
            return
        }
        var playerNameList = [String]()
        for player in playersOutOfFormation {
            playerNameList.append("\(player.last!) \(player.number!)")
        }
        playerPickerData = playerNameList
        playerPickerView?.delegate = self
        playerPickerView?.dataSource = self
        animateIn(view: addPlayerToFormationView)
    }
    
    //Spliting the cell into fixed number of rows - I got help rom stackOverFlow implmenting this
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let noOfCellsInRow = self.rowSize
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(noOfCellsInRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(noOfCellsInRow))
        
        return CGSize(width: size, height: size)
    }
}

//extends the class for the implemented delegate and data source functions
extension PlayerFormationViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == formationPickerView {
            return formationPickerData.count
        }
        return playerPickerData.count
    }
    
    // The data itself
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == formationPickerView {
            return formationPickerData[row]
        }
        return playerPickerData[row]
    }
}
