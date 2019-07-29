//
//  PlayerCollectionViewCell.swift
//  FootballManagerHelper
//
//  Created by Itzik Ben Zakai on 25/05/2019.
//  Copyright © 2019 Itzik Ben Zakai. All rights reserved.
//

import UIKit

class PlayerCollectionViewCell: UICollectionViewCell {
  
    @IBOutlet weak var playerNumberLabel: UILabel!
    @IBOutlet weak var cardImageView: UIImageView!
    
    func setCellData(player: PlayerModel) {
        playerNumberLabel.text = "\(player.number!)"
        if player.suspendedGames! > 0 {
            cardImageView.image = UIImage(named: "red_card.png")
        } else if player.yellowCards == 4 {
            cardImageView.image = UIImage(named: "yellow_card.png")
        } else {
            cardImageView.image = nil
        }
    }
}
