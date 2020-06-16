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
            self.getUserPosts(userID: user?.id)
        }
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.indicator
    
    var userAvatarImage: UIImage?
    
    var cellsPerRow: Int = 3
    
    var userID: Int?
    
    var page: Int = 1
    var limit: Int = 15
    var total: Int?
    var postsArray = Array<Post>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userID == nil {
            userID = (UserDefaults.standard.value(forKey: "user_id") as! Int)
        }
        
        collectionView.isHidden = true
        
        collectionView.register(UINib(nibName: "SingleMemeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: profileCellReuseIdentifier)
        collectionView.register(UINib(nibName: "ProfileHeaderCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellReuseIdentifier)
        
        view.addSubview(activityIndicator)
        
        activityIndicator.centerInView(view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadVC(_:)), name: NSNotification.Name(rawValue: "NotificationUserProfileUpdated"), object: nil)
        
        getUserByID(userID!)
    }
    
    @objc func reloadVC(_ notification: Notification) {
        user = nil
        activityIndicator.startAnimating()
        getUserByID(userID!)
    }

    func getUserByID(_ id: Int) {
        NetworkManager.shared.getUserByID(id, { (user) in
            self.user = user
        }) { (error) in
            self.present(Helper.shared.showInfoAlert(title: "Ooops...", message: error)!, animated: true, completion: nil)
        }
    }
    
    func getUserPosts(userID: Int?) {
        if let userID = userID {
            NetworkManager.shared.getUserPostsByID(userID, page: page, limit: limit) { (posts, total) in
                self.total = Int(total)
                self.postsArray.append(contentsOf: posts)
                self.collectionView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.collectionView.reloadData()
            }
        }
    
    }
    
    override func viewWillLayoutSubviews() {
        /* https://stackoverflow.com/questions/13191480/collectionviewviewforsupplementaryelementofkindatindexpath-called-only-with-u */
        super.viewWillLayoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: view.bounds.width, height: 200)
    }
    
    @objc func presentEditProfileVC(_ sender: UIButton?) {
        let editProfileNavController = storyboard?.instantiateViewController(withIdentifier: "EditProfileNavController") as! UINavigationController
        let editProfileViewController = editProfileNavController.viewControllers[0] as! EditProfileViewController
        editProfileViewController.user = user
        
        if userAvatarImage != nil {
            editProfileViewController.userAvatarImage = userAvatarImage
        }
        
        present(editProfileNavController, animated: true, completion: nil)
    }
    
    @IBAction func actionMore(_ sender: UIBarButtonItem) {
        
        let userName = (user?.firstName)! + " " + (user?.lastName)!
        
        let actionSheet = UIAlertController(title: nil, message: userName, preferredStyle: .actionSheet)
        
        actionSheet.view.tintColor = UIColor.black
        
        let editProfileAction = UIAlertAction(title: "Изменить профиль", style: .default) { (action) in
            self.presentEditProfileVC(nil)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        let logoutAction = UIAlertAction(title: "Выйти из аккаунта", style: .default) { (action) in
            
            let alert = UIAlertController(title: "Выход", message: "Ты точно хочешь выйти?", preferredStyle: .alert)
            
            alert.view.tintColor = .black
            
            let okAction = UIAlertAction(title: "Да", style: .default) { (action) in
                Helper.shared.logout {
                    let signInNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "SignInNavigationController")
                    signInNavigationController?.modalPresentationStyle = .fullScreen
                    self.present(signInNavigationController!, animated: true) {
                        print("logout has been done")
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (action) in
                
            }
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
     
        actionSheet.addAction(editProfileAction)
        actionSheet.addAction(logoutAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
        
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
        
        let post = postsArray[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCellReuseIdentifier, for: indexPath) as! SingleMemeCollectionViewCell
    
        
        if post.type == PostType.Single {

            let singleMeme = post.memes![0]

            guard let memeImageURL = URL(string: singleMeme.imageName!) else {return cell}

            cell.memeImageView.sd_setImage(with: memeImageURL, placeholderImage: #imageLiteral(resourceName: "ice-cream-placeholder"), options: .forceTransition) { (image, error, cache, url) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                }
            }

        }
                        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToPostViewController" {
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
                
        performSegue(withIdentifier: "SegueToPostViewController", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row > postsArray.count - 5 {
            if postsArray.count < total! {
                page = page + 1
                getUserPosts(userID: user?.id)
            } else {
                print("All posts loaded")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellReuseIdentifier, for: indexPath) as! ProfileHeaderCollectionViewCell

            headerCell.fullNameLabel.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")\n\(user?.about ?? "")"

            UIView.setAnimationsEnabled(false)
            if user?.id == userID {
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
        
//        let collectionViewFrame = collectionView.frame
//
//        let width = collectionViewFrame.width / CGFloat(cellsPerRow)
//        let height = width
//
//        let spacing = CGFloat((cellsPerRow + 1)) * offset / CGFloat(cellsPerRow)
//
//        return CGSize(width: width - spacing, height: height - (offset * 2))
        
    }
    
}
