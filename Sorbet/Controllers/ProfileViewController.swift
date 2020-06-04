//
//  ProfileViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 03.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit
import SDWebImage

fileprivate let profileCellReuseIdentifier = "ProfileCell"
fileprivate let headerCellReuseIdentifier = "HeaderCell"

class ProfileViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User? {
        didSet {
            navigationItem.title = "id\(user?.id ?? 0)"
            collectionView.isHidden = false
            activityIndicator.stopAnimating()
            collectionView.reloadData()
        }
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.indicator
    
    var userAvatarImage: UIImage?
    
    var cellsPerRow: Int = 3
    
    var currentUserID = UserDefaults.standard.value(forKey: "user_id") as! Int
    
    var page: Int = 1
    var limit: Int = 15
    var total: Int?
    var postsArray = Array<Post>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.isHidden = true
        
        collectionView.register(UINib(nibName: "ProfileCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: profileCellReuseIdentifier)
        collectionView.register(UINib(nibName: "ProfileHeaderCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellReuseIdentifier)
        
        view.addSubview(activityIndicator)
        
        activityIndicator.centerInView(view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadVC(_:)), name: NSNotification.Name(rawValue: "NotificationUserProfileUpdated"), object: nil)
                
        getUserByID(currentUserID)
        getUserPosts()
    }
    
    @objc func reloadVC(_ notification: Notification) {
        user = nil
        activityIndicator.startAnimating()
        getUserByID(currentUserID)
    }

    func getUserByID(_ id: Int) {
        NetworkManager.shared.getUserByID(id, { (user) in
            self.user = user
        }) { (error) in
            self.present(Helper.shared.showInfoAlert(title: "Ooops...", message: error)!, animated: true, completion: nil)
        }
    }
    
    func getUserPosts() {
        NetworkManager.shared.getUserPostsByID(currentUserID, page: page, limit: limit) { (posts, total) in
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        /* https://stackoverflow.com/questions/13191480/collectionviewviewforsupplementaryelementofkindatindexpath-called-only-with-u */
        super.viewWillLayoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: view.bounds.width, height: 200)
    }
    
    @objc func presentEditProfileVC(_ sender: UIButton) {
        let editProfileNavController = storyboard?.instantiateViewController(withIdentifier: "EditProfileNavController") as! UINavigationController
        let editProfileViewController = editProfileNavController.viewControllers[0] as! EditProfileViewController
        editProfileViewController.user = user
        
        if userAvatarImage != nil {
            editProfileViewController.userAvatarImage = userAvatarImage
        }
        
        present(editProfileNavController, animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCellReuseIdentifier, for: indexPath) as! ProfileCollectionViewCell
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellReuseIdentifier, for: indexPath) as! ProfileHeaderCollectionViewCell
                        
            headerCell.fullNameLabel.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")\n\(user?.about ?? "")"
            
            UIView.setAnimationsEnabled(false)
            if user?.id == currentUserID {
                headerCell.actionProfileButton.addTarget(self, action: #selector(presentEditProfileVC(_:)), for: .touchUpInside)
                headerCell.actionProfileButton.setTitle("Редактировать профиль", for: .normal)
            } else {
                headerCell.actionProfileButton.setTitle("Подписаться", for: .normal)
            }
            headerCell.actionProfileButton.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)

            headerCell.setNeedsLayout()
            
            guard let avatarURL = URL(string: user?.avatar ?? "") else {return headerCell}
            
            headerCell.avatarImageView.sd_setImage(with: avatarURL, placeholderImage: #imageLiteral(resourceName: "baby"), options: .highPriority) { (image, error, cache, url) in
                self.userAvatarImage = image
            }
            
            return headerCell
        default:
            return UICollectionReusableView()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        
        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))
        
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))
        
        return CGSize(width: size, height: size)
        
    }
    
}
