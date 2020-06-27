//
//  SignUpTableViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 01.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class SignUpTableViewController: UITableViewController {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRepeatTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = #colorLiteral(red: 0.5998017788, green: 0.2449732423, blue: 0.7006943822, alpha: 1)
        
        emailTextField.becomeFirstResponder()
                
        let fields = [usernameTextField, emailTextField, passwordTextField, passwordRepeatTextField]
        
        fields.forEach { (textField) in
            textField?.borderBottom(height: 2, color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
            textField?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        
        let insets = UIEdgeInsets(top: 40, left: 0, bottom: 40, right: 0)
        
        tableView.contentInset = insets
        tableView.scrollIndicatorInsets = insets
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.5998017788, green: 0.2449732423, blue: 0.7006943822, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        
        navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Назад", style: .plain, target: self, action: #selector(toSignInViewController(_:)))
        navigationItem.leftBarButtonItem = newBackButton
        
    }
    
    func signUp() {
        
        if let email = emailTextField.text,
            let username = usernameTextField.text,
            let password = passwordTextField.text,
            let passwordRepeat = passwordRepeatTextField.text,
            !username.isEmpty && !email.isEmpty && !password.isEmpty && !passwordRepeat.isEmpty {
            
            if password == passwordRepeat {
                
                print(username)
                
                let user = User(id: nil, token: nil, username: username, rating: nil, expiredDate: nil, avatar: nil, firstName: nil, lastName: nil, about: nil, password: password, email: email)
                
                NetworkManager.shared.signUp(user: user, { (userID, token) in
                    Helper.shared.authFinished(fromViewController: self, userID: userID, token: token)
                }) { (error) in
                    self.present(Helper.shared.showInfoAlert(title: "Упс...", message: error)!, animated: true, completion: nil)
                }
                
            } else {
                present(Helper.shared.showInfoAlert(title: "Миша, давай по новой!", message: "Пароли не совпадают!")!, animated: true, completion: nil)
            }
            
        } else {
            present(Helper.shared.showInfoAlert(title: "Миша, давай по новой!", message: "Заполни все поля!")!, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func actionSignUp(_ sender: UIBarButtonItem) {
        signUp()
    }
    
    @objc func toSignInViewController(_ sender: UIBarButtonItem) {
        
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9791200757, green: 0.7600466609, blue: 0, alpha: 1)
        navigationController?.navigationBar.tintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        navigationController?.popViewController(animated: true)
        
    }
}

extension SignUpTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(emailTextField) {
            usernameTextField.becomeFirstResponder()
        } else if textField.isEqual(usernameTextField) {
            passwordTextField.becomeFirstResponder()
        } else if textField.isEqual(passwordTextField) {
            passwordRepeatTextField.becomeFirstResponder()
        } else if textField.isEqual(passwordRepeatTextField) {
            signUp()
        }
        
        return true
    }
}
