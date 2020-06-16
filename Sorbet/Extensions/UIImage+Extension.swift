//
//  UIImage+Extension.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 16.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

extension UIImage {
    func getImageRatio() -> CGFloat {
        let imageRatio = CGFloat(self.size.width / self.size.height)
        return imageRatio
    }
}
