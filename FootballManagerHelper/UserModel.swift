//
//  UserModel.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 08/06/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import Foundation
class UserModel{
    var id: String?
    var username: String?
    var password: String?
    var playerId: String?
    var isAdmin: Bool
    
    init(id: String?, username: String?, password: String?, playerId: String?, isAdmin: Bool){
        self.id = id
        self.username = username
        self.password = password
        self.playerId = playerId
        self.isAdmin = isAdmin
    }
    
}
