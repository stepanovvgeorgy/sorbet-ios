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
            activityIndicator.stopAnimating()
            collectionView.reloadData()
            collectionView.isHidden = false
        }
    }
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView.indicator
    
    var imagePicker: UIImagePickerController = UIImagePickerController()
    
    var userAvatarImage: UIImage?
    
    var cellsPerRow: Int = 3
    
    var userID: Int?
    
    var page: Int = 1
    var limit: Int = 15
    var total: Int?
    
    var selectedMemeImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userID == nil {
            userID = (UserDefaults.standard.value(forKey: "user_id") as! Int)
        }
        
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
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
    
    @IBAction private func actionMore(_ sender: UIBarButtonItem) {
        
        let userName = (user?.firstName)! + " " + (user?.lastName)!
        
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
    
    @objc private func showNewPostActionSheet(_ sender: UIButton?) {
        let actionSheet = UIAlertController(title: nil, message: "Что будем публиковать?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Ничего", style: .cancel)
        
        let memeAction = UIAlertAction(title: "Just meme", style: .default) { (action) in
            self.present(self.imagePicker, animated: true, completion: nil)
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
                
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: profileCellReuseIdentifier, for: indexPath) as! SingleMemeCollectionViewCell
    
                        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SegueToPostViewController" {

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.deselectItem(at: indexPath, animated: true)
                
        selectedMemeImage = (collectionView.cellForItem(at: indexPath) as! SingleMemeCollectionViewCell).memeImageView.image
        
        performSegue(withIdentifier: "SegueToPostViewController", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerCellReuseIdentifier, for: indexPath) as! ProfileHeaderCollectionViewCell
            
            let currentUserID = UserDefaults.standard.value(forKey: "user_id") as! Int
            
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
                
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout

        let totalSpace = flowLayout.sectionInset.left + flowLayout.sectionInset.right + (flowLayout.minimumInteritemSpacing * CGFloat(cellsPerRow - 1))

        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsPerRow))

        return CGSize(width: size, height: size)
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
//        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage

    }
}
