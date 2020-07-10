//
//  SubsViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 30.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "UserCell"

class SubscriptionsViewController: SorbetViewController {
    
    @IBOutlet weak var tableView: UITableView!

    var subscriptions = [User]()
    
    let activityIndicator = UIActivityIndicatorView.indicator
    
    var total: Int?
    var limit = 20
    var page = 1
    
    var users = [User]()
    
    var userID: Int? {
        
        didSet {
            
            NetworkManager.shared.getUserByID(self.userID, { (user) in
                
                self.navigationItem.title = "Подписки \(user?.username ?? "")"
            
                self.getSubscriptions()
                
            }) { (error) in
                print(error)
            }
        }
    }
    
    func getSubscriptions() {
        NetworkManager.shared.getSubscriptionsByUserID(self.userID, page: self.page, limit: self.limit, completion: { (users, total) in
            self.total = total
            self.users.append(contentsOf: users)
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }) { (error) in
            let alert = Helper.shared.showInfoAlert(title: "Error", message: error as? String)
            self.present(alert!, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        
        activityIndicator.startAnimating()
        
        view.addSubview(activityIndicator)
        
        activityIndicator.centerInView(view)
        
        navigationItem.title = ""
        
    }

}

extension SubscriptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! UserTableViewCell
        
        let user = users[indexPath.row]
        
        cell.usernameLabel.text = user.username
        
        guard let avatarURL = URL(string: user.avatar!) else {return cell}
        
        cell.avatarImageView.sd_setImage(with: avatarURL, placeholderImage: #imageLiteral(resourceName: "baby"), options: .continueInBackground, completed: nil)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let profileVC = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profileVC.userID = users[indexPath.row].id
        
        navigationController?.pushViewController(profileVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row > users.count - 5 {
            if users.count < total! {
                page = page + 1
                getSubscriptions()
            } else {
                print("all subscriptions")
            }
        }
    }
}
