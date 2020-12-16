//
//  ViewController.swift
//  Sorbet
//
//  Created by Georgy Stepanov on 01.06.2020.
//  Copyright © 2020 Georgy Stepanov. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextFeild: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.becomeFirstResponder()
        emailTextField.borderBottom(height: 2)
        passwordTextFeild.borderBottom(height: 2)
        
        navigationController?.navigationBar.barStyle = .default

    }
    
    @IBAction func actionSignIn(_ sender: Any) {
        signIn()
    }
    
    func signIn() {
        
        if let email = emailTextField.text,
            let password = passwordTextFeild.text,
            !email.isEmpty && !password.isEmpty {
            
            let user = User(id: nil, token: nil, username: email, rating: nil ,expiredDate: nil, avatar: nil, firstName: nil, lastName: nil, about: nil, password: password, email: email)
            
            NetworkManager.shared.signIn(user: user, { (userID, token) in
                Helper.shared.authFinished(fromViewController: self, userID: userID, token: token)
            }) { (error) in
                self.present(Helper.shared.showInfoAlert(title: "Ooops", message: error)!, animated: true, completion: nil)
            }
            
        }
    }
}

extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.isEqual(emailTextField) {
            passwordTextFeild.becomeFirstResponder()
        } else {
            signIn()
        }
        
        return true
    }
}
