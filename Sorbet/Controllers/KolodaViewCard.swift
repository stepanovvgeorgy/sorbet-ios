//
//  KolodaViewCard.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 25.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class KolodaViewCard: UIView {
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var bottomView: UIControl!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userFullNameLabel: UILabel!
    
    override func draw(_ rect: CGRect) {
        
        bottomView.layer.shadowOpacity = 0.7
        bottomView.layer.shadowColor = UIColor.gray.cgColor
        
        avatarImageView.layer.cornerRadius = avatarImageView.frame.width / 2
    }
}
