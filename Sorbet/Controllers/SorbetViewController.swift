//
//  SorbetViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 01.07.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class SorbetViewController: UIViewController {

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
        navigationController?.navigationBar.barStyle = .black
    }
}
