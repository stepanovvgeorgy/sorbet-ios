//
//  NewPostCollectionViewCell.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 04.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class NewPostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var typeNameLabel: UILabel!
    @IBOutlet weak var view: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderWidth = 8.5
        layer.borderColor = UIColor.color.sunFlower.cgColor
    }

}
