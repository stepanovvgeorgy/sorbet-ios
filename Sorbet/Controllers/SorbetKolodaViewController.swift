//
//  SorbetKolodaViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 01.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit
import Koloda

class SorbetKolodaViewController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!
    
    var images = ["3.jpg", "4.jpg", "1.png", "2.jpg", "5.jpg", "6.jpg"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        modalTransitionStyle = .flipHorizontal
    }
    
    @IBAction func actionKolodaUndo(_ sender: UIBarButtonItem) {
        kolodaView.revertAction()
    }
}

extension SorbetKolodaViewController: KolodaViewDelegate, KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return images.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        let view = UIImageView(image: UIImage(named: images[index]))
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        koloda.reloadData()
        
        print("kolodaDidRunOutOfCards")
    }
}
