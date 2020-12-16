//
//  UserTableViewCell.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 03.07.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class UserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        contentView.backgroundColor = .clear
        
        actionButton.layer.borderWidth = 1.5
        actionButton.layer.borderColor = UIColor.color.sunFlower.cgColor
        actionButton.layer.cornerRadius = 3
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
