//
//  InnerTabBarController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 02.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class InnerTabBarController: UITabBarController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13.0, *) {
            if traitCollection.userInterfaceStyle == .light {
                return .darkContent
            } else {
                return .lightContent
            }
        } else {
            return .lightContent
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        delegate = self
        
        if AppDelegate.iosVersion < 13.0 {
            
            self.tabBar.items?.forEach({ (item) in
                item.title = ""
                item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            })
            
        }
        
    }
}


//extension InnerTabBarController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        if viewControllers!.firstIndex(of: viewController) == 1 {
//            return false
//        } else {
//            return true
//        }
//    }
//}

