//
//  UIColor+Extension.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 03.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

extension UIColor {
    
    static let color: UIColor = UIColor()
    
    func rgbColor(red: Double, green: Double, blue: Double, alpha: Double) -> UIColor {
        return UIColor(red: CGFloat(red)/255,
                       green: CGFloat(green)/255,
                       blue: CGFloat(blue)/255,
                       alpha: CGFloat(alpha))
    }
    
    var sunFlower: UIColor {
        get {
            self.rgbColor(red: 241, green: 196, blue: 15, alpha: 1)
        }
    }
    
}
