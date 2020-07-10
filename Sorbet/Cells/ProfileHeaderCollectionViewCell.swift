//
//  ProfileHeaderCollectionViewCell.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 03.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class ProfileHeaderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var subscribeButton: UIButton!
    @IBOutlet weak var newPostButton: UIButton!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var subscriptionsCountLabel: UILabel!
    @IBOutlet weak var subscriptionsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.backgroundColor = .clear
        avatarImageView.layer.cornerRadius = 74/2
        setButtonBorder(subscribeButton)
        setButtonBorder(newPostButton)
        subscriptionsCountLabel.isUserInteractionEnabled = true
        subscriptionsLabel.isUserInteractionEnabled = true
    }
    
    private func setButtonBorder(_ button: UIButton?) {
        if button != nil {
            button!.layer.borderWidth = 1.5
            button!.layer.borderColor = UIColor.color.sunFlower.cgColor
            button!.layer.cornerRadius = 4
        }
    }
    
}
