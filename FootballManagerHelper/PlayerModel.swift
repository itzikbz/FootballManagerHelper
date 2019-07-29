//
//  PlayerModel.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 25/05/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import Foundation

//A class which represents the player model in firebase
class PlayerModel{
    var id: String?
    var first: String?
    var last: String?
    var number: Int?
    var suspendedGames: Int?
    var yellowCards: Int?
    
    init(id: String?, first: String?, last: String?, number: Int?, suspendedGames: Int?, yellowCards: Int?){
        self.id = id
        self.first = first
        self.last = last
        self.number = number
        self.suspendedGames = suspendedGames
        self.yellowCards = yellowCards
    }
    
}
