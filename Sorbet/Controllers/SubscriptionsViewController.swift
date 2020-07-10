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
    
    var userID: Int? {
        didSet {
            NetworkManager.shared.getUserByID(self.userID, { (user) in
                self.navigationItem.title = "Подписки \(user?.username ?? "")"
            }) { (error) in
                print(error)
            }
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
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! UserTableViewCell
        cell.usernameLabel.text = "username"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
