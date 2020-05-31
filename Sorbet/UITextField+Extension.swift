//
//  UITextField+Extension.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 01.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

extension UITextField {
    
    func borderBottom(height: CGFloat? = 1, color: UIColor? = .black) {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        let borderBottom = UIView.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        borderBottom.backgroundColor = color
        borderBottom.translatesAutoresizingMaskIntoConstraints = false
        addSubview(borderBottom)
        //Mark: Setup Anchors
        borderBottom.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        borderBottom.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        borderBottom.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        borderBottom.heightAnchor.constraint(equalToConstant: height!).isActive = true // Set Border-Strength
    }
}
