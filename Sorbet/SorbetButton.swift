//
//  SorbetButton.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 09.07.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class SorbetButton: UIButton {

    override func draw(_ rect: CGRect) {
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.color.sunFlower.cgColor
        self.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        self.titleLabel?.textColor = UIColor.color.sunFlower
        self.backgroundColor = .clear
    }
}
