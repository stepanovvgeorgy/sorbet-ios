//
//  PostViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 06.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

fileprivate let postHeaderReuseIdentifier = "PostHeaderCell"
fileprivate let postMemeReuseIdentifier = "PostMemeCell"
fileprivate let postCommentReuseIdentifier = "PostCommentCell"

class PostViewController: SorbetViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentFormView: UIView!
    @IBOutlet weak var commentFormViewBottomConstraint: NSLayoutConstraint!
    
    var user: User?
    var memeImage: UIImage?
    
    //https://stackoverflow.com/questions/41154784/how-to-resize-uiimageview-based-on-uiimages-size-ratio-in-swift-3
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 60
        
        let postHeaderTableViewCell = UINib(nibName: "PostHeaderTableViewCell", bundle: nil)
        
        tableView.register(postHeaderTableViewCell, forCellReuseIdentifier: postHeaderReuseIdentifier)
        
        tableView.register(UINib(nibName: "PostMemeTableViewCell", bundle: nil), forCellReuseIdentifier: postMemeReuseIdentifier)
        
        tableView.register(UINib(nibName: "CommentTableViewCell", bundle: nil), forCellReuseIdentifier: postCommentReuseIdentifier)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        
        view.addGestureRecognizer(tapGesture)
        
        setTableViewBottomInsets(commentFormView.frame.height)

        keyboardNotification()
        
        let postHeaderView = postHeaderTableViewCell.instantiate(withOwner: nil, options: nil)[0] as? PostHeaderTableViewCell
        
        postHeaderView?.fullNameLabel.text = "@" + (user?.username)!
        
        guard let avatarURL = URL(string: (user?.avatar)!) else {return}
        
        postHeaderView?.avatarImageView.sd_setImage(with: avatarURL, placeholderImage: #imageLiteral(resourceName: "baby"))
        
        
        navigationItem.titleView = postHeaderView?.contentView
        
        
        
        // in the future
        commentFormView.isHidden = true
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func keyboardNotification() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIApplication.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIApplication.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        UIView.animate(withDuration: 5,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                            let keyboardRectangle = keyboardFrame.cgRectValue
                            let keyboardHeight = keyboardRectangle.height
                            let tabBarHeight = (self.tabBarController?.tabBar.frame.height)
                            
                            let bottomValue = -keyboardHeight + tabBarHeight!
                            
                            self.commentFormViewBottomConstraint.constant = bottomValue
                            self.setTableViewBottomInsets(keyboardHeight + 10)
                                                        
                            self.view.layoutIfNeeded()
                        }
        }, completion: nil)
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        UIView.animate(withDuration: 5,
                       delay: 0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.commentFormViewBottomConstraint.constant = 0
                        self.setTableViewBottomInsets(self.commentFormView.frame.height)
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setTableViewBottomInsets(_ insets: CGFloat) {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: insets, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: insets, right: 0)
    }
    
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if section == 0 {
            return 1
        } else if section == 1 {
            return 0
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            
            if memeImage != nil {
                let imageRatio = memeImage?.getImageRatio()
                return tableView.frame.width / imageRatio!
            }
        }
        
        return UITableView.automaticDimension
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let commentCell = tableView.dequeueReusableCell(withIdentifier: postCommentReuseIdentifier) as! CommentTableViewCell
        
        let memeCell = tableView.dequeueReusableCell(withIdentifier: postMemeReuseIdentifier) as! PostMemeTableViewCell
        
        memeCell.selectionStyle = .none
        
        memeCell.memeImageView.image = memeImage
        
        if indexPath.section == 0 && indexPath.row == 0 {
        
            return memeCell
        }
                
        return commentCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
