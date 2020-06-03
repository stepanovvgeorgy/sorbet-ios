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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.backgroundColor = .clear
        avatarImageView.layer.cornerRadius = 74/2
        
    }

}
