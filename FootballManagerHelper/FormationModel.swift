//
//  FormationDetailModel.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 05/06/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import Foundation

//A class which represents the formation model in firebase
class FormationModel{
    var id: String?
    var name: String?
    var isSelected: Bool

    init(id: String?, name: String?, isSelected: Bool){
        self.id = id
        self.isSelected = isSelected
        self.name = name
    }
    
}
