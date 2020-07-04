//
//  SearchViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 03.07.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

fileprivate let reuseIdentifier = "UserCell"

class SearchViewController: SorbetViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let activityIndicator = UIActivityIndicatorView.indicator
    
    var searchTextField: UITextField?
    
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Поиск"
        
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        
        let searchTextField = UITextField(frame: CGRect(x: 0, y: 0, width: (navigationController?.view.bounds.size.width)!, height: 50))
        
        searchTextField.placeholder = "@username"
        searchTextField.autocapitalizationType = .none
        searchTextField.textColor = .white
        searchTextField.clearButtonMode = .whileEditing
        searchTextField.autocorrectionType = .no
        searchTextField.keyboardAppearance = .dark
        searchTextField.delegate = self
        searchTextField.addTarget(self, action: #selector(request(_:)), for: .editingChanged)
        self.searchTextField = searchTextField
        
        navigationItem.titleView = searchTextField
        
        view.addSubview(activityIndicator)
        
        activityIndicator.centerInView(view)
        
        activityIndicator.stopAnimating()
        
        searchTextField.becomeFirstResponder()
        
    }
    
    @objc private func request(_ sender: UITextField) {
        makeSearchWithQuery(sender.text!)
    }
    
    private func makeSearchWithQuery(_ query: String) {
        users.removeAll()
        activityIndicator.startAnimating()
        NetworkManager.shared.searchUserByUsername(query, { (users) in
            self.users.append(contentsOf: users)
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            print("success")
        }) {
            self.users.removeAll()
            self.tableView.reloadData()
            self.activityIndicator.stopAnimating()
            print("failure")
        }
        
    }
}


extension SearchViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let searchTextField = self.searchTextField {
            if textField.isEqual(searchTextField) {
                searchTextField.resignFirstResponder()
            }
        }
        return true
    }
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! UserTableViewCell
        
        let user = users[indexPath.row]
        
        cell.usernameLabel.text = "@" + user.username!
        
        guard let avatarURL = URL(string: user.avatar!) else {return cell}
        
        cell.avatarImageView.sd_setImage(with: avatarURL, placeholderImage: #imageLiteral(resourceName: "baby"), options: .continueInBackground)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let profileViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        
        profileViewController.userID = users[indexPath.row].id
        
        navigationController?.pushViewController(profileViewController, animated: true)
    }
}
