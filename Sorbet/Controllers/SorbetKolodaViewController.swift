//
//  SorbetKolodaViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 01.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit
import Koloda
import SDWebImage

class SorbetKolodaViewController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!
        
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var memesArray: [Meme] = Array()
    
    var page: Int = 1
    var limit: Int = 3
    var total: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kolodaView.dataSource = self
        kolodaView.delegate = self
        
        modalTransitionStyle = .flipHorizontal
        
        dislikeButton.setTitle("\u{1F4A9}", for: .normal)
        dislikeButton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        likeButton.setTitle("\u{1F44D}", for: .normal)
        likeButton.titleLabel?.font = UIFont.systemFont(ofSize: 50)
        
        NetworkManager.shared.getAllMemes(page: page, limit: limit) { (memes, total) in
            print(memes)
            print(total)
            self.total = total
            self.memesArray.append(contentsOf: memes)
            self.kolodaView.reloadData()
        }
    }

    
    @IBAction func actionKolodaUndo(_ sender: UIBarButtonItem) {
        kolodaView.revertAction()
    }
    
    @IBAction func actionDislike(_ sender: UIButton) {
        kolodaView.swipe(.left)
    }
    
    @IBAction func actionLike(_ sender: UIButton) {
        kolodaView.swipe(.right)
    }
}

extension SorbetKolodaViewController: KolodaViewDelegate, KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return memesArray.count
    }
    
    func kolodaSpeedThatCardShouldDrag(_ koloda: KolodaView) -> DragSpeed {
        return .fast
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        
        let imageView = UIImageView()
        
        let meme = memesArray[index]
        
        imageView.layer.cornerRadius = 20
        imageView.clipsToBounds = true
        
        guard let url = URL(string: meme.imageName!) else {return imageView}
        
        imageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "ice-cream-placeholder"))
                
        return imageView

    }
    
    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return Bundle.main.loadNibNamed("KolodaOverlayView", owner: self, options: nil)![0] as? OverlayView
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        print("did select card")
    }
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        
        if total! > memesArray.count {
            
            let position = kolodaView.currentCardIndex
            
            page = page + 1
  
            NetworkManager.shared.getAllMemes(page: page, limit: limit) { (memes, total) in
                self.memesArray.append(contentsOf: memes)
                self.kolodaView.insertCardAtIndexRange(position..<position + memes.count, animated: true)
            }
            
        } else {
            print("all memems has been loaded")
        }
    }
    
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
                
        if direction == .right {
            print("swipe right")
        }
        
        if direction == .left {
            print("swipe left")
        }
    }
}
