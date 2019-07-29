//
//  PositionCollectionViewCell.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 27/05/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import UIKit

class PositionCollectionViewCell: UICollectionViewCell {
    var player:PlayerModel?
    @IBOutlet weak var jerseyImageView: UIImageView!
    @IBOutlet weak var playerNumberLayer: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    
    func setCellData(player: PlayerModel?) {
        self.player = player
        if player != nil {
            jerseyImageView.image = UIImage(named: "jersey.png")
            playerNumberLayer.text = "\(player!.number!)"
            if player!.suspendedGames! > 0 {
                cardImageView.image = UIImage(named: "red_card.png")
            } else if player!.yellowCards == 4 {
                cardImageView.image = UIImage(named: "yellow_card.png")
            } else {
                cardImageView.image = nil
            }
        } else {
            jerseyImageView.image = nil
            cardImageView.image = nil
            playerNumberLayer.text = ""
            
        }
        
    }
    
}


