//
//  FormationDetailModel.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 05/06/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import Foundation
class FormationDetailModel{
    var id: String?
    var formationId: String?
    var playerId: String?
    var playerPosition: Int?
    
    init(id: String?, formationId: String?, playerId: String?, playerPosition: Int?){
        self.id = id
        self.formationId = formationId
        self.playerId = playerId
        self.playerPosition = playerPosition
    }
    
}
