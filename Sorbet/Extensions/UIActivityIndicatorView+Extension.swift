//
//  UIActivityIndicatorView+Extension.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 03.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

extension UIActivityIndicatorView {
    
    static var indicator: UIActivityIndicatorView = {
        
        var ai = UIActivityIndicatorView(style: .gray)
        
        if #available(iOS 13.0, *) {
            var ai = UIActivityIndicatorView(style: .large)
        }
        
        ai.startAnimating()
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.isHidden = false
        ai.color = UIColor.color.sunFlower
        
        return ai
    }()
    
    func centerInView(_ view: UIView) {
        self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}
