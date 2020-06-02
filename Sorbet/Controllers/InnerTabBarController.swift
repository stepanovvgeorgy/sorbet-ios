//
//  InnerTabBarController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 02.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class InnerTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if AppDelegate.iosVersion < 13.0 {
            
            self.tabBar.items?.forEach({ (item) in
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            })
            
        }
        
    }
}
