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

fileprivate let segueToProfileViewControllerID = "SegueToProfileViewController"

class SorbetKolodaViewController: UIViewController {

    @IBOutlet weak var kolodaView: KolodaView!
        
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    
    var memesArray: [Meme] = Array()
    
    var page: Int = 1
    var limit: Int = 3
    var total: Int?
    
    var userIDForSegue: Int?
    
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
                
        let viewForCard = Bundle.main.loadNibNamed("KolodaViewCard", owner: self, options: nil)![0] as! KolodaViewCard
                
        let meme = memesArray[index]
        
        viewForCard.layer.cornerRadius = 20
        viewForCard.clipsToBounds = true
        
        viewForCard.userFullNameLabel.text = (meme.user?.firstName)!
        
        guard let memeURL = URL(string: meme.imageName!) else {return viewForCard}

        viewForCard.memeImageView.sd_setImage(with: memeURL, placeholderImage: #imageLiteral(resourceName: "ice-cream-placeholder"))
        
        guard let avatarURL = URL(string: meme.user?.avatar ?? "") else {return viewForCard}
        
        viewForCard.avatarImageView.sd_setImage(with: avatarURL)

        viewForCard.bottomView.tag = meme.userID!
        
        viewForCard.avatarImageView.tag = meme.userID!
        viewForCard.avatarImageView.isUserInteractionEnabled = true
        
        let avatarTapGesture = UITapGestureRecognizer(target: self, action: #selector(toProfileVC(_:)))
        
        viewForCard.avatarImageView.addGestureRecognizer(avatarTapGesture)
        
        return viewForCard

    }
    
    @objc private func toProfileVC(_ sender: UITapGestureRecognizer) {
        
        let profileViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        let senderView = sender.view
        
         profileViewController.userID = senderView!.tag
         
         navigationController?.pushViewController(profileViewController, animated: true)
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
