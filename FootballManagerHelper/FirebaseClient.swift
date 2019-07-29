//
//  FirebaseClient.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 04/06/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseClient {
    
    static var db: Firestore {
        return Firestore.firestore()
    }
    
    private init() {
    }
    
    
    
    static func addPlayer(firstName: String!, lastName: String!, number: Int!, completion: @escaping (PlayerModel) -> ()){
        var ref: DocumentReference? = nil
        ref = db.collection("players").addDocument(data: [
            "first": firstName,
            "last": lastName,
            "number": number,
            "suspendedGames": 0,
            "yellowCards": 0
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                completion(PlayerModel(id: ref?.documentID, first: firstName, last: lastName, number: number, suspendedGames: 0, yellowCards: 0))
            }
        }
    }
    
    static func getAllPlayers(completion: @escaping ([PlayerModel]) -> ()){
        var playerList = [PlayerModel]()
        db.collection("players").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID as String
                    let firstName = document.get("first") as! String
                    let lastName = document.get("last") as! String
                    let number = document.get("number") as! Int
                    let suspendedGames = document.get("suspendedGames") as! Int
                    let yellowCards = document.get("yellowCards") as! Int
                    let playerModel = PlayerModel(id: id, first: firstName, last: lastName, number: number, suspendedGames: suspendedGames, yellowCards: yellowCards)
                    playerList.append(playerModel)
                }
                completion(playerList)
            }
        }
    }
    
    static func getPlayer(id: String!, completion: @escaping (PlayerModel) -> ()){
        db.collection("players").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    if id == document.documentID  {
                    let id = document.documentID as String
                    let firstName = document.get("first") as! String
                    let lastName = document.get("last") as! String
                    let number = document.get("number") as! Int
                    let suspendedGames = document.get("suspendedGames") as! Int
                    let yellowCards = document.get("yellowCards") as! Int
                    let playerModel = PlayerModel(id: id, first: firstName, last: lastName, number: number, suspendedGames: suspendedGames, yellowCards: yellowCards)
                    completion(playerModel)
                    }
                }
              
            }
        }
    }
    
    
    static func deletePlayer(id: String!) {
        deletePlayerFormationDetails(playerId: id)
        db.collection("players").document(id).delete()
    }

    static func updatePlayer(model: PlayerModel!) {
        let player = db.collection("players").document(model.id!)
        player.updateData([
            "first": model.first!,
            "last": model.last!,
            "number": model.number!,
            "suspendedGames": model.suspendedGames!,
            "yellowCards": model.yellowCards!
            ])
    }
    
    static func updateFormation(model: FormationModel!) {
        let formation = db.collection("formations").document(model.id!)
        formation.updateData([
            "name": model.name,
            "isSelected": model.isSelected
            ])
    }
    
    
    
    
    static func getAllFormations(completion: @escaping ([FormationModel]) -> ()){
        var formationList = [FormationModel]()
        db.collection("formations").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID as String
                    let name = document.get("name") as! String
                    let isSelected = document.get("isSelected") as! Bool
                    let formationModel = FormationModel(id: id, name: name, isSelected: isSelected)
                    formationList.append(formationModel)
                }
                completion(formationList)
            }
        }
    }
    
    static func getFormation(formationId: String!, completion: @escaping (FormationModel) -> ()){
        db.collection("formations").whereField("id", isEqualTo: formationId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID as String
                    let name = document.get("name") as! String
                    let isSelected = document.get("isSelected") as! Bool
                    let formationModel = FormationModel(id: id, name: name, isSelected: isSelected)
                    completion(formationModel)
                }
            }
        }
    }
    
    static func addFormation(name: String!, completion: @escaping (FormationModel) -> ()){
        var ref: DocumentReference? = nil
        ref = db.collection("formations").addDocument(data: [
            "name": name,
            "isSelected": false
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                completion(FormationModel(id: ref?.documentID, name: name, isSelected: false))
            }
        }
    }
    
    
    
    static func deleteFormation(id: String!) {
        deleteFormationDetails(formationId: id)
        db.collection("formations").document(id).delete()
    }
    
    
    
    
    
    
    
    
    
    static func getFormationDetails(formationId: String!, completion: @escaping ([FormationDetailModel]) -> ()){
        var formationDetailsList = [FormationDetailModel]()
        db.collection("formationDetails").whereField("formationId", isEqualTo: formationId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID as String
                    let playerId = document.get("playerId") as! String
                    let playerPosition = document.get("playerPosition") as! Int
                    let formationModel = FormationDetailModel(id: id, formationId: formationId, playerId: playerId, playerPosition: playerPosition)
                    formationDetailsList.append(formationModel)
                }
                completion(formationDetailsList)
            }
        }
    }
    
    static func addFormationDetail(formationId: String!, playerId: String!, playerPosition: Int!, completion: @escaping (FormationDetailModel) -> ()){
        var ref: DocumentReference? = nil
        ref = db.collection("formationDetails").addDocument(data: [
            "formationId": formationId,
            "playerId": playerId,
            "playerPosition": playerPosition
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                completion(FormationDetailModel(id: ref?.documentID, formationId: formationId, playerId: playerId, playerPosition: playerPosition))
            }
        }
    }
    
    static func deleteFormationDetails(id: String!){
          db.collection("formationDetails").document(id).delete()
    }
    
    static func deleteFormationDetails(formationId: String!){
        db.collection("formationDetails").whereField("formationId", isEqualTo: formationId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
    static func deletePlayerFormationDetails(playerId: String!){
        db.collection("formationDetails").whereField("playerId", isEqualTo: playerId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
    static func getSelectedFormation(completion: @escaping (FormationModel?) -> ()) {
        var selectedFormation: FormationModel?
        db.collection("formations").whereField("isSelected", isEqualTo: true).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot!.documents.count == 0 {
                    completion(selectedFormation)
                }
                for document in querySnapshot!.documents {
                    let id = document.documentID as String
                    let name = document.get("name") as! String
                    let isSelected = document.get("isSelected") as! Bool
                    let selectedFormation = FormationModel(id: id, name: name, isSelected: isSelected)
                    completion(selectedFormation)
                }
            }
        }
    }
    
    
    static func addUser(username: String?, password: String?, playerId: String?, isAdmin: Bool){
        var ref: DocumentReference? = nil
        ref = db.collection("users").addDocument(data: [
            "username": username,
            "password": password,
            "playerId": playerId,
            "isAdmin": isAdmin
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            }
        }
    }
    
    static func validUser(username: String?, password: String?, completion: @escaping (UserModel?) -> ()){
        var userModel: UserModel?
        db.collection("users").whereField("username", isEqualTo: username).whereField("password", isEqualTo: password).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if querySnapshot!.documents.count == 0 {
                    completion(userModel)
                }
                for document in querySnapshot!.documents {
                    let id = document.documentID as String
                    let username = document.get("username") as! String
                    let password = document.get("password") as! String
                    let playerId = document.get("playerId") as! String
                    let isAdmin = document.get("isAdmin") as! Bool
                    let userModel = UserModel(id: id, username: username, password: password, playerId: playerId, isAdmin: isAdmin)
                    completion(userModel)
                }
            }
        }
    }
    
    static func getUser(playerId: String?, completion: @escaping (UserModel) -> ()) {
        var userModel: UserModel?
        db.collection("users").whereField("playerId", isEqualTo: playerId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    let id = document.documentID as String
                    let username = document.get("username") as! String
                    let password = document.get("password") as! String
                    let playerId = document.get("playerId") as! String
                    let isAdmin = document.get("isAdmin") as! Bool
                    let userModel = UserModel(id: id, username: username, password: password, playerId: playerId, isAdmin: isAdmin)
                    completion(userModel)
                }
            }
        }
    }
    
    static func deleteUser(playerId: String!){
        db.collection("users").whereField("playerId", isEqualTo: playerId).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
    static func updateUser(model: UserModel!) {
        let userModel = db.collection("users").document(model.id!)
        userModel.updateData([
            "username": model.username!,
            "password": model.password!,
            "playerId": model.playerId!,
            "isAdmin": model.isAdmin
            ])
    }
    
    
    
    
    
    
    
    
    
    
}
