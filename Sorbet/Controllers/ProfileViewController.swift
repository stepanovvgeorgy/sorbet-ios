//
//  ProfileViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 03.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit
import SDWebImage
import BSImagePicker
import Photos

fileprivate let profileCellReuseIdentifier = "ProfileCell"
fileprivate let headerCellReuseIdentifier = "HeaderCell"

class ProfileViewController: SorbetViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var user: User? {
        didSet {
            
            navigationItem.title = user?.username ?? "user"
            
            NetworkManager.shared.getSubscriptionsCountByUserID(self.userID) { (count) in
                self.subscriptionsCount = count!
            }
            
            self.getUserMemes()
        }
    }
    
    var subscriptionsCount = 0
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.indicator
    
    var bsImagePicker: ImagePickerController = {
        let imagePicker = ImagePickerController()
        imagePicker.settings.selection.max = 5
        imagePicker.settings.theme.selectionStyle = .numbered
        imagePicker.settings.fetch.assets.supportedMediaTypes = [.image]
        imagePicker.settings.selection.unselectOnReachingMax = true
        imagePicker.navigationBar.barTintColor = #colorLiteral(red: 0.1803680062, green: 0.180406034, blue: 0.1803655922, alpha: 1)
        imagePicker.navigationBar.isTranslucent = false
        imagePicker.navigationBar.tintColor = UIColor.color.sunFlower
        imagePicker.settings.theme.backgroundColor = #colorLiteral(red: 0.1803680062, green: 0.180406034, blue: 0.1803655922, alpha: 1)
        return imagePicker
    }()
    
    let refreshControl = UIRefreshControl()
    
    var userAvatarImage: UIImage?
    
    var cellsPerRow: Int = 3
    
    var userID: Int?
    
    var page: Int = 1
    var limit: Int = 20
    var total: Int?
    
    var memesArray = Array<Meme>()
    
    var selectedMemeImage: UIImage?
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let moreBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "more"), style: .plain, target: self, action: #selector(actionMore(_:)))
        moreBarButtonItem.tintColor = UIColor.color.sunFlower
        
        if userID == nil {
            userID = (UserDefaults.standard.value(forKey: "user_id") as! Int)
            navigationItem.setRightBarButton(moreBarButtonItem, animated: true)
        }
                        
        collectionView.isHidden = true
        
        collectionView.register(UINib(nibName: "SingleMemeCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: profileCellReuseIdentifier)
        collectionView.register(UINib(nibName: "ProfileHeaderCollectionViewCell", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerCellReuseIdentifier)
        
        view.addSubview(activityIndicator)
        
        activityIndicator.centerInView(view)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfileAfterUpdate(_:)), name: NSNotification.Name(rawValue: SorbetNotifications.userProfileUpdated.rawValue), object: nil)
        
        refreshControl.addTarget(self, action: #selector(refreshSelf), for: .valueChanged)
        
        collectionView.refreshControl = self.refreshControl
                
        getUserByID(userID!)
    }
    
    @objc func refreshSelf(_ sender: UIRefreshControl) {
        reloadCollectionViewData()
        sender.endRefreshing()
    }
    
    @objc func reloadCollectionViewData(_ notification: Notification? = nil) {
        
    }
    
    @objc func reloadProfileAfterUpdate(_ notification: Notification?) {
        user = nil
        getUserByID(userID!)
        collectionView.collectionViewLayout.invalidateLayout()
    }

    func getUserByID(_ id: Int) {
        NetworkManager.shared.getUserByID(id, { (user) in
            self.user = user
        }) { (error) in
            self.present(Helper.shared.showInfoAlert(title: "Ooops...", message: error)!, animated: true, completion: nil)
        }
    }
    
    func getUserMemes() {
        NetworkManager.shared.getMemesByUserID(user?.id, page: page, limit: limit) { (memes, total) in
            self.total = total
            self.memesArray.append(contentsOf: memes)
            self.collectionView.reloadData()
            self.collectionView.isHidden = false
            self.activityIndicator.stopAnimating()
        }
    }
    
    override func viewWillLayoutSubviews() {
        /* https://stackoverflow.com/questions/13191480/collectionviewviewforsupplementaryelementofkindatindexpath-called-only-with-u */
        super.viewWillLayoutSubviews()
        (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = CGSize(width: view.bounds.width, height: 200)
    }
    
    @objc private func presentEditProfileVC(_ sender: UIButton?) {
        let editProfileNavController = storyboard?.instantiateViewController(withIdentifier: "EditProfileNavController") as! UINavigationController
        let editProfileViewController = editProfileNavController.viewControllers[0] as! EditProfileViewController
        editProfileViewController.user = user
        
        if userAvatarImage != nil {
            editProfileViewController.userAvatarImage = userAvatarImage
        }
        
        present(editProfileNavController, animated: true, completion: nil)
    }
    
    @objc private func actionMore(_ sender: UIBarButtonItem) {
        
        let userName = "@" + (user?.username)!
        
        let actionSheet = UIAlertController(title: nil, message: userName, preferredStyle: .actionSheet)
                
        let editProfileAction = UIAlertAction(title: "Изменить профиль", style: .default) { (action) in
            self.presentEditProfileVC(nil)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        let logoutAction = UIAlertAction(title: "Выйти из аккаунта", style: .default) { (action) in
            
            let alert = UIAlertController(title: "Выход", message: "Ты точно хочешь выйти?", preferredStyle: .alert)
                        
            let okAction = UIAlertAction(title: "Да", style: .default) { (action) in
                Helper.shared.logout {
                    let signInNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "SignInNavigationController")
                    signInNavigationController?.modalPresentationStyle = .fullScreen
                    self.present(signInNavigationController!, animated: true)
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
    
    @objc private func showNewPostActionSheet(_ sender: UIButton?) {
        let actionSheet = UIAlertController(title: nil, message: "Что будем публиковать?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        let memeAction = UIAlertAction(title: "Мем", style: .default) { (action) in

            self.presentImagePicker(self.bsImagePicker, select: { (asset) in
                // User selected an asset. Do something with it. Perhaps begin processing/upload?
                print("User selected an asset")
            }, deselect: { (asset) in
                print("User deselected an asset")
            }, cancel: { (assets) in
                // User canceled selection.
                print("User canceled selection.")
            }, finish: { (assets) in
                
                if assets.count > 0 {
                    
                    let options = PHImageRequestOptions()
                    options.isSynchronous = true
                    
                       assets.forEach { (asset) in
                        
                           PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.default, options: options) { (image, info) in

                               let resize = CGSize(width: 1024, height: 768)
                               NetworkManager.shared.uploadImage(url: "/meme/single", image!, resize: resize) { (meme) in
                                   if let returnedMeme = meme {

                                       self.memesArray.insert(returnedMeme, at: 0)

                                       self.total = self.total! + 1

                                       self.collectionView.insertItems(at: [IndexPath(row: 0, section: 0)])

                                   } else {
                                       self.present(Helper.shared.showInfoAlert(title: "Ooops...", message: "Что-то пошло не так и мем не загрузился")!, animated: true, completion: nil)
                                   }
                               }

                           }
                       }
                }
                
            })
        }
        
        let jokeAction = UIAlertAction(title: "Каламбур", style: .default) { (action) in
            self.presentJokeEditor(action)
        }
        
        actionSheet.addAction(memeAction)
        actionSheet.addAction(jokeAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true, completion: nil)
    }
    
    @objc private func presentJokeEditor(_ sender: Any?) {
        let jokeEditorNavController = storyboard?.instantiateViewController(withIdentifier: "JokeEditorNavigationController")
        present(jokeEditorNavController!, animated: true, completion: nil)
    }
}

extension ProfileViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCellReuseIdentifier, for: indexPath) as! SingleMemeCollectionViewCell
        
        let meme = memesArray[indexPath.row]
        
        guard let memeImageURL = URL(string: "\(meme.imageName ?? "")") else {return cell}
        
        cell.memeImageView.sd_setImage(with: memeImageURL, placeholderImage: #imageLiteral(resourceName: "icecream"), options: .continueInBackground)
                    
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToPostViewController" {
            let postViewController = segue.destination as! PostViewController
            postViewController.memeImage = selectedMemeImage
            postViewController.user = user
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
                
        selectedMemeImage = (collectionView.cellForItem(at: indexPath) as! SingleMemeCollectionViewCell).memeImageView.image
        
        performSegue(withIdentifier: "SegueToPostViewController", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row > memesArray.count - 10 {
             if memesArray.count < total! {
                 page = page + 1
                 getUserMemes()
             }
         }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellReuseIdentifier, for: indexPath) as! ProfileHeaderCollectionViewCell
            
            let currentUserID = UserDefaults.standard.value(forKey: "user_id") as! Int
            
            headerCell.totalLabel.text = "\(total ?? 0)"
            
            headerCell.subscriptionsCountLabel.text = "\(subscriptionsCount)"
            
            let subsctiptionsTapGesture = UITapGestureRecognizer(target: self, action: #selector(actionShowSubscriptions))
            
            headerCell.subscriptionsCountLabel.addGestureRecognizer(subsctiptionsTapGesture)
            headerCell.subscriptionsLabel.addGestureRecognizer(subsctiptionsTapGesture)
            
            if user?.id == currentUserID {
                headerCell.subscribeButton.isHidden = true
                headerCell.newPostButton.isHidden = false
                headerCell.newPostButton.addTarget(self, action: #selector(showNewPostActionSheet(_:)), for: .touchUpInside)
            } else if user?.id != currentUserID  {
                headerCell.subscribeButton.isHidden = false
                headerCell.newPostButton.isHidden = true
            }

            headerCell.fullNameLabel.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")\n\(user?.about ?? "")"
                        
            guard let avatarURL = URL(string: user?.avatar ?? "") else {return headerCell}

            headerCell.avatarImageView.sd_setImage(with: avatarURL, placeholderImage: #imageLiteral(resourceName: "baby"), options: .highPriority) { (image, error, cache, url) in
                self.userAvatarImage = image
            }

            return headerCell
        default:
            return UICollectionReusableView()
        }

    }
    
    @objc func actionShowSubscriptions() {
        if let userID = self.userID {
            let subscriptionsViewController = storyboard?.instantiateViewController(withIdentifier: "SubscriptionsViewController") as! SubscriptionsViewController
            subscriptionsViewController.userID = userID
            navigationController?.pushViewController(subscriptionsViewController, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))

        return CGSize(width: size, height: size)
    }
    
}

